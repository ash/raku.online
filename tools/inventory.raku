#!/usr/bin/env raku
# inventory.raku — build the operator inventory the Rules site is checked against.
#
#   rakupp tools/inventory.raku --doc=/Users/ash/doc --rakupp=PATH
#
# TWO sources, and deliberately not a third.
#
#   1. The official documentation (doc/Language/operators.rakudoc). It carries
#      the canonical precedence ladder as a table — 26 levels, high to low, with
#      each level's associativity — and it is *organised* by that ladder: every
#      operator is documented under a `=head1 <Level> precedence` section, so a
#      heading like `=head2 infix C<+>` inherits its level from the document's
#      own structure. That is the mapping, stated by the language's own
#      documentation rather than inferred.
#
#   2. Raku++ itself, probed. Each construct is fed to the interpreter in a
#      minimal use and classified by whether it PARSES. A type error still means
#      the spelling is known; only a parse error means it is not.
#
# What this deliberately does NOT read is Rakudo's src/Perl6/Grammar.nqp. An
# earlier version did, and it was seductive: the grammar has exact precedence
# letters and internal flags the documentation never mentions. But those are
# facts about one implementation's parser, not about Raku, and documenting them
# here would quietly turn this site into a description of Rakudo's internals.
# Where the grammar declares something the documentation does not describe, the
# right conclusion is that it is not part of the documented language.
#
# Output: src/data/inventory.raku (+ a .json twin for the browser)

sub rk-str($v --> Str) {
    my $s = $v.defined ?? ~$v !! '';
    "'" ~ $s.subst('\\', '\\\\', :g).subst("'", "\\'", :g) ~ "'"
}
sub json-str($v --> Str) {
    my $s = $v.defined ?? ~$v !! '';
    '"' ~ $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
            .subst("\n", '\\n', :g).subst("\t", ' ', :g) ~ '"'
}

# ---------------------------------------------------------------------------
# The ladder
# ---------------------------------------------------------------------------

# The `=head1` titles in operators.rakudoc, mapped onto the level names used by
# the precedence table at the top of that same file. The document spells a few
# of them differently in the two places ("Nonchaining binary" in the body is
# "Structural" in the table); this is the only place that has to know.
my %HEAD-LEVEL =
    'Method postfix precedence'      => 'method call',
    'Autoincrement precedence'       => 'autoincrement',
    'Exponentiation precedence'      => 'exponentiation',
    'Symbolic unary precedence'      => 'symbolic unary',
    'Dotty infix precedence'         => 'dotty infix',
    'Multiplicative precedence'      => 'multiplicative',
    'Additive precedence'            => 'additive',
    'Replication precedence'         => 'replication',
    'Concatenation'                  => 'concatenation',
    'Junctive AND (all) precedence'  => 'junctive and',
    'Junctive OR (any) precedence'   => 'junctive or',
    'Named unary precedence'         => 'named unary',
    'Nonchaining binary precedence'  => 'structural',
    'Chaining binary precedence'     => 'chaining',
    'Tight AND precedence'           => 'tight and',
    'Tight OR precedence'            => 'tight or',
    'Conditional operator precedence' => 'conditional',
    'Item assignment precedence'     => 'item assignment',
    'Loose unary precedence'         => 'loose unary',
    'Comma operator precedence'      => 'comma',
    'List infix precedence'          => 'list infix',
    'List prefix precedence'         => 'list prefix',
    'Loose AND precedence'           => 'loose and',
    'Loose OR precedence'            => 'loose or',
    'Sequencer precedence'           => 'sequencer',
    'Term precedence'                => 'term',
    'Assignment operators'           => 'item assignment',
    'Substitution operators'         => 'term',
    'Metaoperators'                  => 'metaoperators',
    'Identity'                       => 'chaining',
    'Terms'                          => 'term';

# The precedence table itself: level name, associativity, in ladder order.
# Rows look like
#     Multiplicative   | left | * × / ÷ % %% \+& …
# with Pod escaping on the operators, which is not needed here — only the level
# name and associativity are taken from the table; membership comes from the
# document structure, which is exhaustive where the table's examples are not.
sub parse-ladder(Str $src) {
    my @ladder;
    my $in = False;
    for $src.lines -> $line {
        if $line.starts-with('=begin table') { $in = True; next }
        if $line.starts-with('=end table')   { last if $in }
        next unless $in;
        next unless $line.contains('|');
        # The separator row is `=====+=====`; detect it by its FIRST CELL being
        # nothing but '=' signs. A blanket "contains ===" test also throws away
        # the Chaining row, whose examples legitimately include `===` — which
        # silently cost the largest precedence level its place on the ladder.
        next if $line.contains('Associativity');
        next if $line.split('|')[0].trim.subst('=', '', :g).trim.chars == 0
                && $line.split('|')[0].contains('=');
        my @cells = $line.split('|').map(*.trim);
        next unless @cells.elems >= 2 && @cells[0].chars;
        my $level = @cells[0].subst(/ <[¹²³]> /, '', :g).trim.lc;
        next unless $level.chars;
        @ladder.push: %( level => $level, assoc => @cells[1] );
    }
    @ladder
}

# ---------------------------------------------------------------------------
# The operators
# ---------------------------------------------------------------------------

my %DOC-CATS = infix => 1, prefix => 1, postfix => 1, circumfix => 1,
               postcircumfix => 1, term => 1, listop => 1, methodop => 1;

# Reduce a Pod heading to the text the site renders, which is also what the
# docs.raku.org anchor is built from: X<A|index> keeps A, C«x»/C<x> unwrap.
sub render-heading(Str $line is copy --> Str) {
    $line = $line.subst(/ ^ '=head' \d \s+ /, '');
    $line = $line.subst(/ 'X<' (<-[<>|]>*) '|' <-[<>]>* '>' /, { ~$0 }, :g);
    $line = $line.subst(/ 'X«' (<-[«»|]>*) '|' <-[«»]>* '»' /, { ~$0 }, :g);
    $line = $line.subst(/ 'C«' (<-[«»]>*) '»' /, { ~$0 }, :g);
    $line = $line.subst(/ 'C<' (<-[<>]>*) '>' /, { ~$0 }, :g);
    $line = $line.subst(/ 'Z<>' /, '', :g);
    $line.trim
}

sub parse-operators(Str $dir) {
    my @ops;
    my %seen;
    my $ldir = "$dir/doc/Language";
    return @ops unless $ldir.IO.d;
    for dir($ldir).grep({ .IO.f && .Str.ends-with('.rakudoc') }).sort -> $f {
        my $page = $f.IO.basename.subst(/ '.rakudoc' $ /, '');
        my $level = '';
        for slurp($f.Str).lines -> $line {
            next unless $line.starts-with('=head');
            my $rendered = render-heading($line);
            next unless $rendered.chars;

            if $line.starts-with('=head1') {
                $level = %HEAD-LEVEL{$rendered} // '';
                next;
            }
            my $anchor = $rendered.subst(' ', '_', :g);
            my $url = 'https://docs.raku.org/language/' ~ $page ~ '#' ~ $anchor;
            # One heading can document several spellings:
            # `infix (&), infix ∩` — both belong at the same level and anchor.
            for $rendered.split(',') -> $piece {
                my @w = $piece.trim.words;
                next unless @w.elems >= 2 && %DOC-CATS{ @w[0] }:exists;
                my $cat = @w[0];
                my $sym = @w[1 .. *].join(' ');
                # Disambiguating parentheticals are prose, not part of the
                # spelling: `infix = (item assignment)`.
                $sym = $sym.subst(/ \s* '(' <-[)]>* ')' \s* $ /, '').trim;
                next unless $sym.chars;
                my $key = "$cat|$sym";
                next if %seen{$key}:exists;
                %seen{$key} = True;
                @ops.push: %( cat => $cat, sym => $sym, level => $level,
                              doc => $url, page => $page );
            }
        }
    }
    @ops
}

# ---------------------------------------------------------------------------
# Raku++, probed
# ---------------------------------------------------------------------------

# Constructs the generic templates below cannot express. Without these the
# generic form produces nonsense — `sink(@a<> 0 )`, `sink($a ! $b)` — which then
# fails to parse and gets reported as a MISSING OPERATOR. A false gap is worse
# than no answer: it tells a reader that `%h<a>` or `!` does not work.
my %SPECIAL-PROBE =
    'infix|?? !!'       => 'my $a = 6; sink($a ?? 1 !! 2)',
    'infix|ff'          => 'my $a = 6; sink($a ff $a)',
    'infix|fff'         => 'my $a = 6; sink($a fff $a)',
    'postcircumfix|( )' => 'sub f { 1 }; sink(&f())',
    # `<>` and `« »` are single subscript delimiters, not space-separated pairs
    'postcircumfix|<>'  => 'my %h = a => 1; sink(%h<a>)',
    'postcircumfix|« »' => 'my %h = a => 1; my $k = "a"; sink(%h«$k»)',
    # `!` is documented as an infix but is the negation METAOPERATOR: it glues
    # onto another infix (`!==`, `!eq`) and never stands between two operands.
    'infix|!'           => 'my $a = 6; my $b = 3; sink($a !== $b)';

# Constructs with no probe that would mean anything. These are recorded as
# "not probed" rather than as gaps.
my %NO-PROBE = 'prefix|//' => 1;

sub probe-template(Str $cat, Str $sym) {
    my $key = "$cat|$sym";
    return %SPECIAL-PROBE{$key} if %SPECIAL-PROBE{$key}:exists;
    return Str if %NO-PROBE{$key}:exists;
    return Str if $cat eq 'infix' | 'prefix' | 'postfix' && $sym.contains(' ');
    return Str if $cat eq 'listop' || $cat eq 'methodop';

    my @parts = $sym.words;
    my ($open, $close) = @parts.elems == 2 ?? (@parts[0], @parts[1]) !! ($sym, '');
    given $cat {
        when 'infix'         { "my \$a = 6; my \$b = 3; sink(\$a $sym \$b)" }
        when 'prefix'        { "my \$a = 6; sink($sym \$a)" }
        when 'postfix'       { "my \$a = 6; sink((\$a)$sym)" }
        when 'circumfix'     { "sink($open 1 $close)" }
        when 'postcircumfix' { "my \@a = 1, 2, 3; sink(\@a$open 0 $close)" }
        default              { Str }
    }
}

sub probe-rakupp(Str $exe, Str $code --> Bool) {
    my $p = run($exe, '-e', $code, :out, :err);
    my $err = $p.err.slurp(:close);
    $p.out.slurp(:close);
    !($err.contains('Parse error') || $err.contains('Unsupported') ||
      $err.contains('Unexpected'))
}

# ---------------------------------------------------------------------------
# Raku++ sources — the routine inventories only
# ---------------------------------------------------------------------------

sub builtin-subs(Str $dir) {
    my $path = "$dir/Builtins.cpp";
    return [] unless $path.IO.e;
    my %seen;
    for slurp($path) ~~ m:g/ 'B[' <[\x22]> (<-[\x22]>+) <[\x22]> ']' \s* '=' / -> $m {
        %seen{ ~$m[0] } = True;
    }
    %seen.keys.sort
}

sub builtin-methods(Str $dir) {
    my %seen;
    for <Builtins.cpp Interpreter.cpp> -> $f {
        my $path = "$dir/$f";
        next unless $path.IO.e;
        for slurp($path) ~~ m:g/ ['m' || 'meth' || 'name'] \s* '==' \s* <[\x22]> (<-[\x22]>+) <[\x22]> / -> $m {
            %seen{ ~$m[0] } = True if (~$m[0]).chars;
        }
    }
    %seen.keys.sort
}

# ---------------------------------------------------------------------------

sub MAIN(
    Str :$doc        = '/Users/ash/doc',
    Str :$rakupp-src = '/Users/ash/raku++/src',
    Str :$rakupp     = 'rakupp',
    Str :$out        = 'src/data/inventory.raku',
) {
    my $opsrc = "$doc/doc/Language/operators.rakudoc";
    die "no operators.rakudoc at $opsrc" unless $opsrc.IO.e;

    my @ladder = parse-ladder(slurp $opsrc);
    my @ops    = parse-operators($doc);
    my @subs   = builtin-subs($rakupp-src);
    my @meths  = builtin-methods($rakupp-src);

    # Ladder position, so a page can say how tightly something binds without
    # quoting an implementation's internal precedence letter.
    my %rank;
    for @ladder.kv -> $i, %l { %rank{ %l<level> } = $i }
    for @ops -> %o {
        %o<rank>  = %rank{ %o<level> } if %o<level>.chars && (%rank{ %o<level> }:exists);
        %o<assoc> = @ladder[ %o<rank> ]<assoc> if %o<rank>:exists;
    }

    my $probed = 0;
    for @ops -> %o {
        my $code = probe-template(%o<cat>, %o<sym>);
        if $code.defined {
            %o<rakupp> = probe-rakupp($rakupp, $code);
            %o<probe>  = $code;
            $probed++;
        }
    }

    my @l;
    @l.push('# Generated by tools/inventory.raku — do not edit.');
    @l.push("\{");
    @l.push("  'ladder' => [");
    for @ladder -> %x {
        @l.push('    { ' ~ rk-str('level') ~ ' => ' ~ rk-str(%x<level>) ~ ', ' ~
                rk-str('assoc') ~ ' => ' ~ rk-str(%x<assoc>) ~ ' },');
    }
    @l.push('  ],');
    @l.push("  'ops' => [");
    for @ops -> %o {
        my @kv;
        for <cat sym level assoc doc page probe> -> $k {
            @kv.push(rk-str($k) ~ ' => ' ~ rk-str(%o{$k})) if (%o{$k} // '').chars;
        }
        @kv.push(rk-str('rank') ~ ' => ' ~ %o<rank>) if %o<rank>:exists;
        @kv.push(rk-str('rakupp') ~ ' => ' ~ (%o<rakupp> ?? 'True' !! 'False')) if %o<rakupp>:exists;
        @l.push('    { ' ~ @kv.join(', ') ~ ' },');
    }
    @l.push('  ],');
    @l.push("  'subs' => [" ~ @subs.map({ rk-str($_) }).join(', ') ~ '],');
    @l.push("  'methods' => [" ~ @meths.map({ rk-str($_) }).join(', ') ~ '],');
    @l.push('}');
    spurt $out, @l.join("\n") ~ "\n";

    my @j;
    for @ops -> %o {
        my @kv;
        for <cat sym level assoc doc> -> $k {
            @kv.push(json-str($k) ~ ':' ~ json-str(%o{$k})) if (%o{$k} // '').chars;
        }
        @kv.push('"rakupp":' ~ (%o<rakupp> ?? 'true' !! 'false')) if %o<rakupp>:exists;
        @j.push('{' ~ @kv.join(',') ~ '}');
    }
    spurt $out.subst(/ '.raku' $ /, '.json'),
        '{"ops":[' ~ @j.join(",\n") ~ "]}\n";

    my $known = @ops.grep({ $_<rakupp>:exists && $_<rakupp> }).elems;
    my $levelled = @ops.grep({ $_<rank>:exists }).elems;
    say "precedence levels : {@ladder.elems}";
    say "operators         : {@ops.elems}  ($levelled placed on the ladder)";
    say "probed            : $probed  (parsed by Raku++: $known)";
    say "builtin subs      : {@subs.elems}";
    say "method names      : {@meths.elems}";
    say "wrote $out";
}
