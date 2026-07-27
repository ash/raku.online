#!/usr/bin/env raku
# matrix.raku — build the differential behaviour matrix the Rules site shows on
# every operator page.
#
#   rakupp tools/matrix.raku --rakupp=PATH --oracle=raku
#
# For each operator the inventory knows about, the same battery of operand types
# is run through BOTH interpreters and the result type and value recorded. Three
# things come out of it, none of them hand-written:
#
#   * A behaviour table per operator — what `+` does to two lists, what `~` does
#     to an undefined value — which is exactly the "less obvious" material a
#     rules page needs, established rather than remembered.
#   * Divergences, flagged automatically wherever the two engines disagree.
#   * Errors, captured as the diagnostic each engine actually produces.
#
# Output: src/data/matrix.raku, keyed by "<cat>|<sym>".

sub rk-str(Str $s --> Str) {
    "'" ~ $s.subst('\\', '\\\\', :g).subst("'", "\\'", :g) ~ "'"
}

# Operand pairs, as Raku source. Chosen to cover the coercions that actually
# surprise people: string/number crossing, a list where a scalar was meant,
# Bool-as-Int, an undefined value, and exact rationals.
# Square brackets, not parens: a bare list of lists flattens on assignment and
# each pair would arrive as two separate operands.
my @PAIRS = [
    ['1', '2'],
    ['"a"', '"b"'],
    ['1', '"2"'],
    ['(1, 2)', '(3, 4, 5)'],
    ['True', 'False'],
    ['Nil', '1'],
    ['1/2', '1/3'],
];

my @SINGLES = '1', '"a"', '(1, 2)', 'True', 'Nil', '1/2';

# Operators whose whole point is to mutate or bind their left operand: a matrix
# of literal operands would say nothing useful, and some would not even parse.
sub skip-op(Str $cat, Str $sym --> Bool) {
    return True if $sym.contains(' ');
    return True if $sym eq '=' | ':=' | '::=' | '.=';
    # compound assignment: ends in `=` but is not a comparison
    my $cmp = $sym eq '==' | '!=' | '<=' | '>=' | '===' | '!==' | '=:=' | '!=:='
            | '=~=' | '!===' | '<=>' | '≠' | '≤' | '≥' | '(<=)' | '(>=)' | '(==)' | '(!=)';
    return True if $sym.ends-with('=') && !$cmp;
    # `,` and `;` build structure rather than compute a value
    return True if $sym eq ',' | ';';
    # Mutators need an lvalue; a matrix over literals would only ever show
    # "not assignable" and teaches nothing.
    return True if $sym eq '++' | '--' | '++⚛' | '--⚛' | '⚛++' | '⚛--' | '⚛';
    False
}

sub expr-for(Str $cat, Str $sym, @operands --> Str) {
    given $cat {
        when 'infix'  { "@operands[0] $sym @operands[1]" }
        when 'prefix' { "$sym (@operands[0])" }
        # parenthesised: `Truei` would otherwise lex as one identifier
        when 'postfix' { "(@operands[0])$sym" }
        default       { Str }
    }
}

# Run one expression and reduce it to a single comparable line: either
# "Type | gist" or "ERR <first line of the diagnostic>".
sub probe(Str $exe, Str $expr --> Str) {
    my $code = "my \$r = ($expr); say \$r.^name ~ ' | ' ~ \$r.gist;";
    my $p = run($exe, '-e', $code, :out, :err);
    my $out = $p.out.slurp(:close).trim;
    my $err = $p.err.slurp(:close).trim;
    return $out if $out.chars && !$out.contains('===SORRY!===');
    my $first = ($err.lines[0] // 'failed').trim;
    # Normalise the noise that differs between engines without differing in
    # meaning: line/column markers and the "in block <unit>" trailer.
    $first = $first.subst(/ ' at ' \N* $ /, '');
    $first = $first.subst(/ ^ '===SORRY!===' \s* /, '');
    'ERR ' ~ ($first.chars ?? $first !! 'failed')
}

sub MAIN(
    Str  :$rakupp = 'rakupp',
    Str  :$oracle = 'raku',
    Str  :$inv    = 'src/data/inventory.raku',
    Str  :$out    = 'src/data/matrix.raku',
    Int  :$limit  = 0,
) {
    my %INV = EVAL slurp $inv;
    my @ops = @(%INV<ops>).grep({
        !(.<alias>:exists) && !(.<placeholder>:exists)
        && (.<rakupp>:exists) && .<rakupp>
        && (.<cat> eq 'infix' || .<cat> eq 'prefix' || .<cat> eq 'postfix')
    });
    @ops = @ops[0 ..^ $limit] if $limit > 0 && $limit < @ops.elems;

    # NB: an array literal [ $key, @recs ] flattens @recs into it here, so the
    # key list and the record map are kept separate.
    my @keys;
    my %bykey;
    my $rows = 0;
    my $diffs = 0;
    for @ops.kv -> $i, %op {
        my $sym = %op<sym>;
        next if skip-op(%op<cat>, $sym);
        my @battery = %op<cat> eq 'infix' ?? @PAIRS !! @SINGLES.map({ [$_] });
        my @recs;
        for @battery -> @operands {
            my $expr = expr-for(%op<cat>, $sym, @operands);
            next unless $expr.defined;
            my $a = probe($rakupp, $expr);
            my $b = probe($oracle, $expr);
            $rows++;
            # Both engines rejecting the expression is agreement, however
            # differently they word the diagnostic. Only a value-vs-value
            # disagreement, or one accepting what the other rejects, is real.
            my $verdict = do if $a.starts-with('ERR') && $b.starts-with('ERR') { 'both-reject' }
                          elsif $a eq $b { 'agree' }
                          else { 'differ' };
            $diffs++ if $verdict eq 'differ';
            @recs.push([$expr, $a, $b, $verdict]);
        }
        next unless @recs;
        my $key = %op<cat> ~ '|' ~ $sym;
        @keys.push($key);
        %bykey{$key} = @recs;
        note "  {$i + 1}/{@ops.elems}  {%op<cat>}:$sym" if ($i + 1) %% 20;
    }

    my @lines;
    for @keys -> $key {
        @lines.push('  ' ~ rk-str($key) ~ ' => [');
        for @(%bykey{$key}) -> @r {
            @lines.push('    [ ' ~ rk-str(@r[0]) ~ ', ' ~ rk-str(@r[1]) ~ ', ' ~
                        rk-str(@r[2]) ~ ', ' ~ rk-str(@r[3]) ~ ' ],');
        }
        @lines.push('  ],');
    }
    spurt $out,
        "# Generated by tools/matrix.raku — do not edit.\n" ~
        "# key => [ [expression, raku++ result, rakudo result, agree|differ|both-reject], … ]\n" ~
        "\{\n" ~ @lines.join("\n") ~ "\n}\n";

    say "";
    say "operators probed : {@keys.elems}";
    say "expressions      : $rows";
    say "real divergences : $diffs";
    say "wrote $out";
}
