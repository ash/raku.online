#!/usr/bin/env raku
# typerun.raku — run every extracted documentation example on both interpreters
# and classify the result three ways.
#
#   rakupp tools/typerun.raku --rakupp=PATH --oracle=raku
#
# Each example carries the output the official documentation ASSERTS. Running it
# gives two more answers, and the interesting information is in how the three
# relate:
#
#   ok             doc == Rakudo == Raku++         nothing to see
#   rakupp-differs doc == Rakudo, Raku++ differs   a Raku++ defect
#   doc-drift      Rakudo == Raku++, doc differs   the documentation is stale
#   rakudo-differs doc == Raku++, Rakudo differs   usually means Raku++ was
#                                                  implemented FROM the docs and
#                                                  inherited a stale assertion
#   all-differ     three different answers         needs a human
#   not-runnable   neither engine can compile it   example depends on context
#
# The doc-drift class is why this exists: tuning Raku++ against the documented
# output alone would tune it toward answers Rakudo does not produce.
#
# Output: src/data/typerun.raku

sub rk-str($v --> Str) {
    my $s = $v.defined ?? ~$v !! '';
    "'" ~ $s.subst('\\', '\\\\', :g).subst("'", "\\'", :g) ~ "'"
}

# No `timeout(1)` on this platform, so the guard is a Perl one-liner that alarms
# and kills its child. Documentation examples include a few that block on input
# or spin, and one of those would otherwise stall the whole run.
# Documentation examples are arbitrary programs: some of them write files, and
# a few write files named `test` or `foo`. Run them somewhere disposable so the
# repository does not collect the debris.
sub run-guarded(Str $exe, Str $code, Int $secs = 10, Str $cwd = '.') {
    my $p = run('perl', '-e', Q[
        my ($secs, $exe, $code, $cwd) = @ARGV;
        my $pid = fork();
        if (!$pid) { chdir($cwd); open(STDIN, '<', '/dev/null'); exec($exe, '-e', $code); exit 127 }
        local $SIG{ALRM} = sub { kill 'KILL', $pid; waitpid($pid, 0); exit 124 };
        alarm($secs);
        waitpid($pid, 0);
        alarm(0);
        exit($? >> 8);
    ], $secs.Str, $exe, $code, $cwd, :out, :err);
    my $out = $p.out.slurp(:close);
    my $err = $p.err.slurp(:close);
    my $rc  = $p.exitcode;
    %( out => $out, err => $err, rc => $rc )
}

# Compare on exact text, then forgive a single trailing newline: the docs are
# inconsistent about whether the final ␤ is written.
sub same(Str $a, Str $b --> Bool) {
    return True if $a eq $b;
    $a.trim-trailing eq $b.trim-trailing
}

sub MAIN(
    Str :$rakupp = 'rakupp',
    Str :$oracle = 'raku',
    Str :$typedoc = 'src/data/typedoc.raku',
    Str :$out = 'src/data/typerun.raku',
    Int :$limit = 0,
) {
    my %td = EVAL slurp $typedoc;

    # A scratch directory for the examples to scribble in.
    my $sandbox = '/tmp/typerun-sandbox';
    mkdir $sandbox unless $sandbox.IO.d;

    my @jobs;
    for @(%td<types>) -> %t {
        for @(%t<examples>).kv -> $idx, %e {
            next unless %e<expect>.chars;
            # `:lang<text>` is not Raku; `:skip-test` is the doc authors telling
            # us the example is not meant to run.
            next if %e<opts>.contains('skip-test') || %e<opts>.contains('lang<text>');
            # `:preamble<…>` is setup the page does not show but the example
            # needs; without it the snippet cannot run standalone.
            my $pre = (%e<preamble> // '');
            my $code = $pre.chars ?? $pre ~ "\n" ~ %e<code> !! %e<code>;
            @jobs.push([ %t<name>, $idx, $code, %e<expect> ]);
        }
    }
    @jobs = @jobs[0 ..^ $limit] if $limit > 0 && $limit < @jobs.elems;
    note "examples to run: {@jobs.elems}";

    my @recs;
    my %tally;
    for @jobs.kv -> $i, @j {
        my ($type, $idx, $code, $expect) = @j[0], @j[1], @j[2], @j[3];
        my %a = run-guarded($rakupp, $code, 10, $sandbox);
        my %b = run-guarded($oracle, $code, 10, $sandbox);

        my $ku = %a<out>;
        my $ra = %b<out>;
        my $ku-broke = %a<rc> != 0;
        my $ra-broke = %b<rc> != 0;

        # Order matters. Without the rakudo-differs arm, "Raku++ matches the
        # documentation but Rakudo does not" falls through to all-differ, which
        # buries the most diagnostic case of the lot.
        my $verdict = do if $ku-broke && $ra-broke { 'not-runnable' }
                      elsif same($ku, $expect) && same($ra, $expect) { 'ok' }
                      elsif same($ra, $expect) { 'rakupp-differs' }
                      elsif same($ku, $expect) { 'rakudo-differs' }
                      elsif same($ku, $ra)     { 'doc-drift' }
                      else                     { 'all-differ' };
        %tally{$verdict}++;
        @recs.push([ $type, $idx, $verdict, $ku, $ra,
                     (%a<err>.lines[0] // ''), (%b<err>.lines[0] // '') ]);
        note "  {$i + 1}/{@jobs.elems}" if ($i + 1) %% 100;
    }

    my @l;
    @l.push('# Generated by tools/typerun.raku — do not edit.');
    @l.push('# [type, example index, verdict, raku++ stdout, rakudo stdout, r++ err, rakudo err]');
    @l.push("\{");
    @l.push("  'runs' => [");
    for @recs -> @r {
        @l.push('    [ ' ~ (^7).map({ rk-str(@r[$_]) }).join(', ') ~ ' ],');
    }
    @l.push('  ],');
    @l.push('}');
    spurt $out, @l.join("\n") ~ "\n";

    say "";
    for %tally.sort({ -.value }) -> $p { say $p.value.fmt('%5d') ~ '  ' ~ $p.key }
    say "wrote $out";
}
