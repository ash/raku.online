#!/usr/bin/env raku
# Times ONE installed Rakudo in BOTH of its compilation backends and writes
# rows in src/data/rakudo-eras.tsv's format.
#
#   legacy   — the historical compiler (`raku prog.raku`)
#   rakuast  — the RakuAST backend (`RAKUDO_RAKUAST=1 raku prog.raku`)
#
# Rakudo 2026.09 makes RakuAST the default and keeps the old one reachable as
# RAKUDO_LEGACY=1, so from that release on this tool's two lanes swap which
# environment variable is the interesting one. Only the lane TABLE below needs
# editing then; nothing else here knows which backend is the default.
#
# METHOD — the one rakudo-eras.tsv's header documents, because the numbers this
# writes sit in the same column as the ones measured under it:
#
#   * one warm-up run per lane per kernel, discarded;
#   * $ROUNDS timed rounds, and every lane runs ONCE INSIDE EACH ROUND, back to
#     back — so a load spike lands on both lanes rather than on one;
#   * $PASSES such passes, and the reported value is the MINIMUM across all
#     $ROUNDS*$PASSES runs;
#   * convergence is CHECKED, not assumed: the first half of the passes and the
#     second half are minimised separately and the two are compared. Sequential
#     blocks had disagreed by up to 10% on this machine because each block
#     tracked the machine's drift; interleaving inside the round removes it, and
#     this check is what says so.
#
# BOTH lanes are spawned through `env`, including the one that needs no variable
# set. The wrapper costs one extra exec — about a millisecond — which is noise
# against a 200 ms kernel but not against `startup`, a 76 ms one whose whole
# subject IS process startup. Paying it on both sides keeps the comparison
# honest there.
#
# Run it with Raku++ (dogfooding, matches the other tools here):
#
#     rakupp tools/measure-rakudo-modes.raku --era=2026.08 --released=2026-08-22
#
# Options:
#     --rakudo=PATH     the Rakudo to time            (default: raku on PATH)
#     --bench=DIR       the kernel directory          (default: ../raku++/tools/bench,
#                                                      resolved from this file)
#     --era=X           the Rakudo release, e.g. 2026.08          (required)
#     --released=DATE   that release's ship date, ISO             (required)
#     --rounds=N        timed rounds per pass         (default: 20)
#     --passes=N        passes                        (default: 4)
#     --only=a,b        just these kernels
#     --out=PATH        write the TSV rows here       (default: stdout only)

constant @KERNELS = <arrayops arraypush bigint fib hash hashfill loopsum
                     objects rats regex sortby sortnums startup strcat streq
                     textsplit>;

# lane => the env assignments its `env` invocation carries. An empty list still
# goes through `env` (see the note above); `-u` clears an ambient setting so a
# shell that already exported the variable cannot silently merge the two lanes.
constant @LANES = ('legacy'  => ['-u', 'RAKUDO_RAKUAST'],
                   'rakuast' => ['RAKUDO_RAKUAST=1']);

sub median(@n) { my @s = @n.sort; @s.elems %% 2 ?? (@s[@s.elems div 2 - 1] + @s[@s.elems div 2]) / 2 !! @s[@s.elems div 2] }

sub MAIN(Str :$rakudo = 'raku', Str :$bench, Str :$era!, Str :$released!,
         Int :$rounds = 20, Int :$passes = 4, Str :$only, Str :$out) {

    # tools -> spec -> sites -> raku.online -> the directory holding both repos
    my $here     = $*PROGRAM.absolute.IO.parent;          # sites/spec/tools
    my $bench-d  = ($bench // $here.parent.parent.parent.parent.add('raku++/tools/bench').Str).IO;
    die "bench directory not found: $bench-d (pass --bench=DIR)" unless $bench-d.d;
    die "--released must be an ISO date (YYYY-MM-DD), got '$released'"
        unless $released ~~ /^ \d**4 '-' \d**2 '-' \d**2 $/;

    my @want = $only ?? $only.split(',')>>.trim !! @KERNELS;
    my @kernels = @want.grep({ $bench-d.add("$_.raku").e });
    for @want -> $k {
        note "  skipping $k — no $k.raku in $bench-d" unless $bench-d.add("$k.raku").e;
    }
    die "no kernels to run" unless @kernels;

    say "Rakudo modes, era $era (released $released)";
    say "  rakudo:  $rakudo";
    say "  bench:   $bench-d";
    say "  kernels: {@kernels.elems}   lanes: {@LANES.map(*.key).join(', ')}";
    say "  method:  $rounds timed rounds x $passes passes, lanes interleaved, warm-up discarded";
    say '';

    # Correctness before speed: a lane that prints something else is not a
    # faster lane, it is a different program. This is the same rule run-bench
    # applies to its own engines.
    my sub capture(@cmd) {
        my $p = run('/usr/bin/env', |@cmd, :out, :err);
        my $o = $p.out.slurp(:close);
        $p.err.slurp(:close);
        $p.exitcode == 0 ?? $o !! Str
    }

    my %lane-env = @LANES;
    my sub lane-cmd(Str $lane, Str $path) { (|%lane-env{$lane}, $rakudo, $path) }

    my %bad;
    for @kernels -> $k {
        my $path = $bench-d.add("$k.raku").Str;
        my $ref;
        for @LANES -> $lane {
            my $o = capture(lane-cmd($lane.key, $path));
            if !$o.defined {
                %bad{$k}.push("{$lane.key} did not run");
            }
            elsif $ref.defined && $o ne $ref {
                %bad{$k}.push("{$lane.key} output differs from {@LANES[0].key}");
            }
            $ref //= $o;
        }
    }
    if %bad {
        note "REFUSING to time — the lanes are not running the same program:";
        note "  $_: {%bad{$_}.join('; ')}" for %bad.keys.sort;
        exit 2;
    }
    say "correctness: all {@kernels.elems} kernels print the same in both lanes";
    say '';

    # kernel => lane => pass => [ms]
    my %t;
    for ^$passes -> $pass {
        say "pass {$pass + 1}/$passes";
        for @kernels -> $k {
            my $path = $bench-d.add("$k.raku").Str;
            for ^($rounds + 1) -> $i {
                for @LANES -> $lane {
                    my @cmd = lane-cmd($lane.key, $path);
                    my $t0 = now;
                    run('/usr/bin/env', |@cmd, :out).out.slurp(:close);
                    %t{$k}{$lane.key}{$pass}.push((now - $t0) * 1000) if $i > 0;
                }
            }
            my @cells = @LANES.map({
                sprintf('%s %.1f', $_.key, %t{$k}{$_.key}{$pass}.min)
            });
            say "  {$k.fmt('%-10s')} {@cells.join('   ')}";
        }
    }
    say '';

    # Convergence: the first half of the passes against the second half. Both
    # halves are minima over the same number of runs, so a real difference here
    # means the sitting had not settled and the total is not a stable minimum.
    my $half = $passes div 2;
    my $worst = 0.0;
    my @drift;
    if $half >= 1 {
        for @kernels -> $k {
            for @LANES -> $lane {
                my @a = (^$half).map({ |%t{$k}{$lane.key}{$_} });
                my @b = ($half ..^ $passes).map({ |%t{$k}{$lane.key}{$_} });
                next unless @a && @b;
                my ($x, $y) = @a.min, @b.min;
                my $pct = 100 * abs($x - $y) / min($x, $y);
                $worst max= $pct;
                @drift.push("$k/{$lane.key}: {$x.fmt('%.1f')} vs {$y.fmt('%.1f')} ({$pct.fmt('%.1f')}%)")
                    if $pct > 2;
            }
        }
        say "convergence: first $half pass(es) vs last {$passes - $half}, worst {$worst.fmt('%.1f')}%";
        say "  over 2%: $_" for @drift;
        say "  (none over 2%)" unless @drift;
        say '';
    }

    my @rows;
    say "{'kernel'.fmt('%-10s')} {@LANES.map({ $_.key.fmt('%9s') }).join} {'ratio'.fmt('%9s')}";
    for @kernels -> $k {
        my @ms = @LANES.map(-> $lane {
            (^$passes).map({ |%t{$k}{$lane.key}{$_} }).min
        });
        for @LANES.kv -> $i, $lane {
            @rows.push(($era, $released, $k, @ms[$i].fmt('%.1f'), $lane.key).join("\t"));
        }
        my $ratio = @ms[0] > 0 ?? @ms[1] / @ms[0] !! Inf;
        say "{$k.fmt('%-10s')} {@ms.map({ $_.fmt('%9.1f') }).join} {$ratio.fmt('%8.2f')}x";
    }

    if $out {
        $out.IO.spurt(@rows.join("\n") ~ "\n");
        say '';
        say "wrote {@rows.elems} rows to $out";
    }
}
