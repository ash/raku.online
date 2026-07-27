#!/usr/bin/env raku
# snapshot.raku — append the current state of the dots map to the history.
#
#   rakupp tools/snapshot.raku --rakupp=PATH --oracle=raku
#
# Every regeneration of the behaviour matrix and the three-way example run
# overwrites its predecessor, so the *trend* — which is the interesting part
# once Raku++ starts getting fixed — was being thrown away each time. This walks
# the current data and appends one line to src/data/history.jsonl: aggregate
# counts, plus per-type counts so a later timeline can show which areas moved
# rather than only that the total did.
#
# The file is append-only JSON Lines: one self-contained object per run, in
# chronological order, trivially readable from JavaScript for an interactive
# chart or from here for a static one. Nothing ever rewrites an earlier line.
#
# CAVEAT, and it matters for reading the trend: the run is not perfectly
# deterministic. Two consecutive runs over identical data have differed by
# roughly 1-2% of examples — some documentation examples print members of
# unordered collections, sample randomness, or report timings. So a movement of
# a handful of examples between snapshots is noise, not progress; only tens of
# examples mean something. The fix, if the jitter becomes annoying, is to
# re-run any non-`ok` verdict once in typerun.raku and keep it only if it
# reproduces.

sub json-str($v --> Str) {
    my $s = $v.defined ?? ~$v !! '';
    '"' ~ $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
            .subst("\n", ' ', :g).subst("\t", ' ', :g) ~ '"'
}

sub version-of(Str $exe --> Str) {
    my $p = run($exe, '--version', :out, :err);
    my $out = $p.out.slurp(:close);
    $p.err.slurp(:close);
    ($out.lines[0] // '').trim
}

sub MAIN(
    Str :$rakupp  = 'rakupp',
    Str :$oracle  = 'raku',
    Str :$runs    = 'src/data/typerun.raku',
    Str :$matrix  = 'src/data/matrix.raku',
    Str :$inv     = 'src/data/inventory.raku',
    Str :$out     = 'src/data/history.jsonl',
    Str :$label   = '',
) {
    my %tally;
    my %bytype;
    if $runs.IO.e {
        my %r = EVAL slurp $runs;
        for @(%r<runs>) -> @x {
            %tally{ @x[2] }++;
            %bytype{ @x[0] } //= %();
            %bytype{ @x[0] }{ @x[2] }++;
        }
    }

    my %mx;
    if $matrix.IO.e {
        my %m = EVAL slurp $matrix;
        for %m.values -> @rows {
            for @rows -> @r { %mx{ @r[3] }++ }
        }
    }

    my $ops = 0;
    my $parsed = 0;
    if $inv.IO.e {
        my %i = EVAL slurp $inv;
        $ops = @(%i<ops>).elems;
        $parsed = @(%i<ops>).grep({ $_<rakupp>:exists && $_<rakupp> }).elems;
    }

    # Per-type counts, compact: only the four verdicts a timeline would plot,
    # and only for types that have at least one example.
    my @bt;
    for %bytype.keys.sort -> $t {
        my %v = %(%bytype{$t});
        @bt.push(json-str($t) ~ ':[' ~
            <ok rakupp-differs rakudo-differs doc-drift all-differ not-runnable>
            .map({ %v{$_} // 0 }).join(',') ~ ']');
    }

    my @kv;
    @kv.push('"date":' ~ json-str(DateTime.now.yyyy-mm-dd));
    @kv.push('"stamp":' ~ now.Int);
    @kv.push('"label":' ~ json-str($label)) if $label.chars;
    @kv.push('"rakupp":' ~ json-str(version-of($rakupp)));
    @kv.push('"rakudo":' ~ json-str(version-of($oracle)));
    @kv.push('"examples":{' ~
        <ok rakupp-differs rakudo-differs doc-drift all-differ not-runnable>
        .map({ json-str($_) ~ ':' ~ (%tally{$_} // 0) }).join(',') ~ '}');
    @kv.push('"matrix":{' ~
        <agree differ both-reject>.map({ json-str($_) ~ ':' ~ (%mx{$_} // 0) }).join(',') ~ '}');
    @kv.push('"operators":{"total":' ~ $ops ~ ',"parsed":' ~ $parsed ~ '}');
    # Key order matches the examples array above, so a reader needs no schema.
    @kv.push('"byTypeKeys":["ok","rakupp-differs","rakudo-differs","doc-drift","all-differ","not-runnable"]');
    @kv.push('"byType":{' ~ @bt.join(',') ~ '}');

    my $line = '{' ~ @kv.join(',') ~ '}';
    my $prev = $out.IO.e ?? slurp($out) !! '';
    spurt $out, $prev ~ $line ~ "\n";

    my $n = $prev.lines.grep({ .trim.chars }).elems + 1;
    say "appended snapshot $n to $out";
    say "  examples : " ~ <ok rakupp-differs rakudo-differs doc-drift all-differ not-runnable>
        .map({ $_ ~ '=' ~ (%tally{$_} // 0) }).join('  ');
    say "  matrix   : " ~ <agree differ both-reject>.map({ $_ ~ '=' ~ (%mx{$_} // 0) }).join('  ');
    say "  operators: $parsed of $ops parse";
}
