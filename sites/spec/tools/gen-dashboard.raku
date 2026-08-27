#!/usr/bin/env raku
# gen-dashboard.raku — mine the Raku++ release history into src/data/dashboard.json.
#
#   rakupp tools/gen-dashboard.raku [--rakupp-repo=PATH] [--battery=PATH]
#
# Three time series, all from data that already exists elsewhere — this script
# only collects, it never measures:
#   releases  one entry per v* tag of the rakupp repo (plus current main),
#             carrying the Roast standing (docs/status/ROAST.md) and the
#             benchmark kernels (docs/status/BENCHMARKS.md) as committed at that
#             tag — see status-doc() for why the path is not hardcoded;
#   modules   the module-battery standing over time, read straight off the
#             battery repo's commit subjects — "Tier-2: N/50 …" (the probe
#             bar, through Aug 2026) then "battery: N/59 …" (each dist's own
#             test suite vs a Rakudo reference run). The denominator is the
#             battery's size at that sitting, so it may grow between points.
#
# The output is a committed snapshot (like roast-map.json): the site build
# never needs the other repos present. Re-run at each release (runbook step).

sub run-lines(*@cmd --> Seq) {
    my $p = run(|@cmd, :out);
    $p.out.slurp(:close).lines
}

sub show-file(Str $repo, Str $ref, Str $path --> Str) {
    my $p = run('git', '-C', $repo, 'show', "$ref:$path", :out, :err);
    my $text = $p.out.slurp(:close);
    $p.err.slurp(:close);
    $text
}

sub ref-date(Str $repo, Str $ref --> Str) {
    run-lines('git', '-C', $repo, 'log', '-1', '--format=%as', $ref).head // ''
}

#| The same ref as a unix timestamp, used to ORDER the releases series.
#|
#| Sorting the tag list as STRINGS is what this used to do, and it is wrong the
#| moment a version component reaches two digits: "v3.14.0" sorts between
#| "v3.1.0" and "v3.5.0" because "1" < "5" character by character. That happened
#| to be the right slot — v3.14.0 is a pi joke tagged 2026-08-11, genuinely
#| between v3.1.0 and v3.5.0 — so nothing looked broken. A "v3.20.0" would not
#| be so lucky: it string-sorts before v3.5.0 and would draw the newest release
#| in the MIDDLE of every chart, three releases back.
#|
#| Ordering by the ref's own commit timestamp cannot drift from the x-axis,
#| because `ref-date` plots that same commit. It also needs no tiebreak: two
#| tags in one day (v3.0.0/v3.0.1, v3.1.0/v3.14.0, v3.5.0/v3.5.1) are distinct
#| commits and order correctly, where a date-only sort would leave them
#| arbitrary.
sub ref-stamp(Str $repo, Str $ref --> Int) {
    (run-lines('git', '-C', $repo, 'log', '-1', '--format=%ct', $ref).head // '0').Int
}

#| Tiebreak for two tags on ONE commit, where the timestamp cannot separate
#| them. Compared component by component as INTEGERS, which is the comparison
#| the tag string fails at: (3,20,0) sorts above (3,7,0), and (3,14,0) above
#| both — correct here, because within a single commit the higher version is
#| the later release. Never the primary key: across commits v3.14.0 really is
#| older than v3.7.0, and only the timestamp knows that.
sub ver-key(Str $ref --> List) {
    $ref.subst(/^ 'v'/, '').split('.').map({ (try .Int) // 0 }).List
}

#| A status document, wherever it lived at that ref. The docs were filed into
#| subdirectories after v1.7.0, so one hardcoded path silently drops every
#| release on the far side of that move — and since this script only collects
#| and never measures, nothing fails: the release is simply absent from the
#| timeline, which is exactly what happened to v1.8.0.
#| Only the two `docs/` spellings. The bare root `ROAST.md` of the pre-v0.5.0
#| era is deliberately NOT searched here: those refs predate the first tagged
#| release and belong to dev-series(), which has its own root fallback. Adding
#| it turns ten pre-release daily points into three early release entries and
#| silently changes the shape of the chart.
#| `main` is the repo AS IT STANDS, so at HEAD the working tree wins over
#| `git show HEAD:` — a sitting measured and written up but not yet committed
#| is still the current reading, and mining the committed blob instead drew
#| the previous sitting's numbers under today's label.
sub status-doc(Str $repo, Str $ref, Str $name --> Str) {
    for "docs/status/$name", "docs/$name" -> $path {
        if $ref eq 'HEAD' && "$repo/$path".IO.e {
            my $text = "$repo/$path".IO.slurp;
            return $text if $text;
        }
        my $text = show-file($repo, $ref, $path);
        return $text if $text;
    }
    ''
}

# "157,293" -> 157293
sub denum(Str $s --> Int) { $s.subst(',', '', :g).subst(/ <-[0..9]> /, '', :g).Int }

# The release's OWN published figures, from the CHANGELOG row it ships with.
# ROAST.md is a living document and can lag a release by a missed edit — v3.5.0
# and v3.5.1 were both tagged with the file-count TABLE still reading v3.14.0's
# 594 while every other place said 630, which drew a dip that never happened.
# The CHANGELOG row is what the release stands behind, so it wins where it
# exists; ROAST.md remains the source for everything else and for `main`.
sub changelog-at(Str $repo, Str $ref --> Hash) {
    my $md = show-file($repo, $ref, 'CHANGELOG.md');
    return {} unless $md;
    my %r;
    for $md.lines -> $line {
        last if %r<files-pass>:exists && %r<tests-pass>:exists;
        next unless $line.trim.starts-with('|');
        my @cells = $line.split('|').map(*.trim);
        next unless @cells.elems > 3;
        my $label = @cells[1].lc;
        # the entry's own column is the LAST one: "| | v3.14.0 | v3.5.0 |"
        my $cell = @cells[*-2].subst('*', '', :g);
        # v3.6.0's entry writes the files row with its denominator
        # ("633 / 1,464"); take the numerator. A plain number still matches
        # whole — without this, the row was skipped and the parser fell
        # through to the PREVIOUS release's table and mined 630.
        if $cell ~~ / ^ (<[0..9,]>+) \s* '/' /
        {
            $cell = ~$0;
        }
        next unless $cell ~~ / ^ <[0..9,]>+ $ /;
        %r<files-pass> = denum($cell) if $label.contains('files fully passing');
        %r<tests-pass> = denum($cell) if $label.contains('assertions');
    }
    %r
}

# ---------------------------------------------------------------------------
# Roast standing out of ROAST.md at a given ref
# ---------------------------------------------------------------------------

sub roast-at(Str $repo, Str $ref --> Hash) {
    my $md = status-doc($repo, $ref, 'ROAST.md');
    return {} unless $md;
    my %r;
    for $md.lines -> $line {
        if $line.contains('Headline:') && $line.contains('(') {
            my $inside = $line.substr($line.index('(') + 1);
            $inside = $inside.substr(0, $inside.index(')')) if $inside.contains(')');
            my ($a, $b) = $inside.split('/');
            if $a.defined && $b.defined {
                %r<tests-pass>  = denum($a);
                %r<tests-total> = denum($b);
            }
        }
        elsif $line.trim.starts-with('| **Fully passing**') {
            my @cells = $line.split('|');
            %r<files-pass> = denum(@cells[2]) if @cells.elems > 2;
        }
        elsif $line.contains('Full suite') && $line.contains('files') {
            my $flat = $line.subst(',', '', :g);
            if $flat ~~ / (\d+) ' files' / {
                %r<files-total> = (~$0).Int;
            }
        }
    }
    %r
}

# ---------------------------------------------------------------------------
# Benchmark kernels out of BENCHMARKS.md at a given ref
# ---------------------------------------------------------------------------

# Every kernel BENCHMARKS.md tables, not a hand-picked three: the file has
# carried nine since the interpreter/native tables were split, and the dashboard
# was drawing a third of what we measure. A kernel missing from an older release's
# table is simply absent from that point — bench-at only records what it finds.
constant @KERNELS = <fib loopsum strcat hash hashfill bigint sortnums regex arrayops streq startup
                     sortby textsplit arraypush rats objects>;

#| The revision BENCHMARKS.md says the sitting was taken at, out of its own
#| methodology line ("re-measured 2026-08-22 at `v3.6.0-8-g56de2be`"). That is
#| the rev the numbers BELONG to, which is not the rev the doc was committed at
#| — the tables are typically written up a commit or two later. Returns '' when
#| the line is absent (every revision before the wording settled).
#|
#| Write that line with the last CODE commit measured, never the doc commit
#| that records it. A write-up commit gets rewritten whenever the branch is
#| rebased, and one already has: a sitting logged as `v3.6.0-19-g4c0e80b`
#| named a SHA that no longer exists in main a day later, while the code it
#| measured (`d1e9082`, lexical pads) kept its own SHA throughout.
sub bench-rev-at(Str $repo, Str $ref --> Str) {
    my $md = status-doc($repo, $ref, 'BENCHMARKS.md');
    return '' unless $md;
    # the line wraps, so match across the newline the paragraph may carry
    $md ~~ / 're-measured' \s+ \d**4 '-' \d**2 '-' \d**2 \s+ 'at' \s+
             '`'? <( 'v' <[0..9.]>+ ['-' \d+ '-g' <[0..9a..f]>+ ]? )> '`'? /
        ?? ~$/ !! ''
}

#| The short commit of a `git describe` rev, or '' when the rev IS a tag —
#| a tagged release is named by its tag, so the hash would only be noise.
sub rev-commit(Str $rev --> Str) {
    $rev ~~ / '-g' <( <[0..9a..f]>+ )> $ / ?? ~$/ !! ''
}

# Each kernel row appears twice: first in the interpreter table
# (| fib | <rakupp ms> | <rakudo ms> | …), then in the native --exe table
# (| fib | <native ms> | <rakudo ms> | …). Collect in encounter order.
sub bench-at(Str $repo, Str $ref --> Hash) {
    my $md = status-doc($repo, $ref, 'BENCHMARKS.md');
    return {} unless $md;
    my %seen;   # kernel => number of rows met so far
    my %out;
    for $md.lines -> $line {
        next unless $line.trim.starts-with('|');
        my @cells = $line.split('|').map(-> $c { $c.trim });
        next unless @cells.elems > 3;
        my $kernel = @cells[1];
        next unless $kernel eq any(@KERNELS);
        next unless @cells[2].ends-with('ms');
        my $ms = @cells[2].words[0];
        next unless $ms ~~ / ^ \d+ ['.' \d+]? $ /;
        %seen{$kernel} = (%seen{$kernel} // 0) + 1;
        if %seen{$kernel} == 1 {
            %out{$kernel}<interp> = $ms.Num;
            my $rk = @cells[3].words[0];
            %out{$kernel}<rakudo> = $rk.Num if $rk ~~ / ^ \d+ ['.' \d+]? $ /;
        }
        elsif %seen{$kernel} == 2 {
            %out{$kernel}<native> = $ms.Num;
        }
    }
    # hashfill carries a fourth engine: the same program timed as the `perl`
    # binary, from the "vs Perl 5" table's own row. First encounter wins (the
    # four-engine table precedes the mode ladder in the doc).
    for $md.lines -> $line {
        last if %out<hashfill><perl>:exists;
        next unless $line.trim.starts-with('|');
        my @cells = $line.split('|').map(-> $c { $c.trim });
        next unless @cells.elems > 3;
        next unless @cells[1] eq 'Perl 5';
        next unless @cells[2].ends-with('ms');
        my $ms = @cells[2].words[0];
        next unless $ms ~~ / ^ \d+ ['.' \d+]? $ /;
        %out<hashfill><perl> = $ms.Num if %out<hashfill>:exists;
    }
    %out
}

#| `startup` is the eleventh bench program and the only one whose table is a
#| MODE ladder rather than a kernel row, so bench-at's two-encounters rule
#| cannot read it. Shape: | Raku++ native `--exe` | 2.4 ms | ... |, one row per
#| mode. Charted as an ordinary kernel once assembled.
sub startup-at(Str $repo, Str $ref --> Hash) {
    my $md = status-doc($repo, $ref, 'BENCHMARKS.md');
    return {} unless $md;
    my %out;
    for $md.lines -> $line {
        next unless $line.trim.starts-with('|');
        my @cells = $line.split('|').map(-> $c { $c.trim.subst('`', '', :g) });
        next unless @cells.elems > 2;
        my $ms = @cells[2].ends-with('ms') ?? @cells[2].words[0] !! '';
        next unless $ms ~~ / ^ \d+ ['.' \d+]? $ /;
        my $mode = @cells[1];
        %out<native> = $ms.Num if $mode eq 'Raku++ native --exe' && !(%out<native>:exists);
        %out<interp> = $ms.Num if $mode eq 'Raku++ interp'       && !(%out<interp>:exists);
        %out<rakudo> = $ms.Num if $mode eq 'Rakudo'              && !(%out<rakudo>:exists);
    }
    %out<interp>:exists && %out<native>:exists ?? %out !! {}
}

# ---------------------------------------------------------------------------
# The `-O` optimizer table out of BENCHMARKS.md at a given ref
# ---------------------------------------------------------------------------

# A DIFFERENT comparison from the kernel tables above: same program compiled
# two ways, `--exe` against `--exe -O`, with Rakudo alongside as the reference.
# The interpreter does not appear — `-O` is a codegen flag — so these get their
# own series rather than extra lanes on the kernel charts.
constant @OPTKERNELS = <sieve powmod intsum fibcalls stringbuild arrayidx nummath methodcalls>;

# Row shape: | name | <exe ms> | **<opt ms>** | **<n>x** | <rakudo ms> | note |
# The `-O` cell is bolded in the doc, so strip the markers before numifying.
sub optbench-at(Str $repo, Str $ref --> Hash) {
    my $md = status-doc($repo, $ref, 'BENCHMARKS.md');
    return {} unless $md;
    my %out;
    for $md.lines -> $line {
        next unless $line.trim.starts-with('|');
        my @cells = $line.split('|').map(-> $c { $c.trim.subst('**', '', :g) });
        next unless @cells.elems > 5;
        my $kernel = @cells[1];
        next unless $kernel eq any(@OPTKERNELS);
        next if %out{$kernel}:exists;          # first table wins
        my @ms = @cells[2, 3, 5].map(-> $c {
            $c.ends-with('ms') && $c.words[0] ~~ / ^ \d+ ['.' \d+]? $ /
                ?? $c.words[0].Num !! Nil
        });
        next unless @ms[0].defined && @ms[1].defined;
        %out{$kernel}<exe> = @ms[0];
        %out{$kernel}<opt> = @ms[1];
        %out{$kernel}<rakudo> = @ms[2] if @ms[2].defined;
    }
    %out
}

# ---------------------------------------------------------------------------
# Pre-release history: one point per day from ROAST.md's own git history
# before the first tag. The file-count series is comparable all the way back;
# the declared-% is only taken where the modern denominator applies (the
# "declared" methodology was introduced 2026-07-09 with a ~231k denominator
# and redefined 2026-07-10 to the current plan-read form — points from the
# 231k era would fake a +16pt jump, so they are excluded from the % series).
# ---------------------------------------------------------------------------

constant OLD-DENOMINATOR-CUTOFF = 220_000;

constant @MONTHS = <? Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;

sub short-date(Str $iso --> Str) {
    my @p = $iso.split('-');
    @MONTHS[@p[1].Int] ~ ' ' ~ @p[2].Int
}

sub dev-series(Str $repo, Str $first-tag --> Array) {
    my @points;
    my %seen-date;
    # Reverse-chronological; the first commit met on a date is that day's last.
    for run-lines('git', '-C', $repo, 'log', '--format=%H %as', '--follow',
                  $first-tag, '--', 'docs/ROAST.md') -> $line {
        my ($sha, $date) = $line.words;
        next unless $date.defined;
        next if %seen-date{$date};
        %seen-date{$date} = True;
        my $md = status-doc($repo, $sha, 'ROAST.md')
              || show-file($repo, $sha, 'ROAST.md');   # the pre-v0.5.0 root spelling
        next unless $md;
        my %r;
        for $md.lines -> $l {
            if $l.trim.starts-with('| **Fully passing**') {
                my @cells = $l.split('|');
                %r<files-pass> = denum(@cells[2]) if @cells.elems > 2;
            }
            elsif $l.contains('Headline:') && $l.contains('(') {
                my $inside = $l.substr($l.index('(') + 1);
                $inside = $inside.substr(0, $inside.index(')')) if $inside.contains(')');
                my ($a, $b) = $inside.split('/');
                if $a.defined && $b.defined {
                    %r<tests-pass>  = denum($a);
                    %r<tests-total> = denum($b);
                    # The 2026-07-09 "declared" figure used a wider ~231k denominator,
                    # redefined the next day. We now surface that point too, but flag it
                    # so the chart marks the re-baseline step instead of implying a real
                    # +16pt jump between it and the 2026-07-10 point.
                    %r<rebaselined> = True if denum($b) > OLD-DENOMINATOR-CUTOFF;
                }
            }
        }
        next unless %r<files-pass>:exists;
        %r<date> = $date;
        @points.push(%r);
    }
    @points.sort(-> %p { %p<date> }).Array
}

# ---------------------------------------------------------------------------
# Tier-2 battery standing out of the battery repo's commit subjects
# ---------------------------------------------------------------------------

sub battery-series(Str $repo --> Array) {
    my @points;
    for run-lines('git', '-C', $repo, 'log', '--reverse', '--format=%as %s') -> $line {
        # Two commit-subject conventions, one per era of the campaign:
        # "Tier-2: N/50" was the probe bar; "battery: N/59" is the zef bar
        # (a dist counts only when its own install-time suite passes). Each
        # point carries its own total, so the bar change shows honestly.
        if $line ~~ / ^ (\d+ '-' \d+ '-' \d+) ' ' .* [ 'Tier-2:' | 'battery:' ] \s* (\d+) '/' (\d+) / {
            my %p = date => ~$0, n => (~$1).Int, total => (~$2).Int;
            # The fix-batch number is the natural x-axis (the campaign can land
            # several batches in one day, so dates alone don't order it).
            if $line ~~ / 'batch' \s+ (\d+) / {
                %p<batch> = (~$0).Int;
            }
            @points.push(%p);
        }
    }
    @points
}

# ---------------------------------------------------------------------------
# JSON writing (same minimal escaping as build.raku)
# ---------------------------------------------------------------------------

sub json-esc(Str $s --> Str) {
    my $e = $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g)
             .subst("\r", '\\r', :g).subst("\n", '\\n', :g).subst("\t", '\\t', :g);
    '"' ~ $e ~ '"'
}

sub optbench-json(%o --> Str) {
    my @k;
    for @OPTKERNELS -> $k {
        next unless %o{$k}:exists;
        my %b = %o{$k};
        @k.push(json-esc($k) ~ ':{' ~
            <exe opt rakudo>.grep({ %b{$_}:exists })
                            .map({ json-esc($_) ~ ':' ~ %b{$_} }).join(',') ~ '}');
    }
    '{' ~ @k.join(',') ~ '}'
}

sub bench-json(%bench --> Str) {
    my @parts;
    for @KERNELS -> $k {
        next unless %bench{$k}:exists;
        my %b = %bench{$k};
        my @f;
        @f.push('"interp":' ~ %b<interp>) if %b<interp>:exists;
        @f.push('"native":' ~ %b<native>) if %b<native>:exists;
        @f.push('"rakudo":' ~ %b<rakudo>) if %b<rakudo>:exists;
        @f.push('"perl":'   ~ %b<perl>)   if %b<perl>:exists;   # hashfill's second reference
        @parts.push(json-esc($k) ~ ':{' ~ @f.join(',') ~ '}');
    }
    '{' ~ @parts.join(',') ~ '}'
}

# ---------------------------------------------------------------------------
# Past `main` sittings
# ---------------------------------------------------------------------------
# `main` is a MOVING point: re-measuring the kernels on a newer commit rewrites
# the numbers the previous run drew, so a re-measure silently replaced the last
# reading instead of adding to it. Every generated main entry is therefore
# logged here, one JSON object per line, labelled by its date; on the next run
# each sitting older than the current main is charted as its own point. The log
# is append-only and the entries are literal chart entries — a sitting is never
# recomputed, because the commit it measured is gone from `main` by then.
constant SITTINGS = 'src/data/bench-sittings.jsonl';

sub sitting-date(Str $line --> Str) {
    $line ~~ / '"date":"' <( <-["]>+ )> '"' / ?? ~$/ !! ''
}

#| The rev a logged sitting was measured at, when it carries one. This is the
#| identity a re-measure is recognised by: two sittings can share a DATE (a
#| second measurement the same day is exactly what a same-day fix produces),
#| and matching on the date alone made the newer reading overwrite the older
#| one instead of joining it.
sub sitting-rev(Str $line --> Str) {
    $line ~~ / '"rev":"' <( <-["]>+ )> '"' / ?? ~$/ !! ''
}

#| The kernel numbers alone, so a logged sitting can be recognised as the one
#| `main` is still drawing. Date is not enough: BENCHMARKS.md is often committed
#| a day after the sitting it records, and then main's date no longer matches
#| the logged one while the numbers are still the very same measurement.
sub sitting-bench(Str $line --> Str) {
    $line ~~ / '"bench":' <( .* )> $ / ?? ~$/ !! ''
}

sub MAIN(Str :$rakupp-repo = '../raku++', Str :$battery = '../raku-module-battery') {
    die "rakupp repo not found at $rakupp-repo (pass --rakupp-repo=PATH)"
        unless "$rakupp-repo/.git".IO.e;
    die "battery repo not found at $battery (pass --battery=PATH)"
        unless "$battery/.git".IO.e;

    # By commit timestamp, NOT by tag string — see ref-stamp. HEAD is appended
    # after the sort because it is always the last point and the splice of past
    # bench sittings below relies on it staying there.
    my @refs = run-lines('git', '-C', $rakupp-repo, 'tag', '--list', 'v*')
                   .sort({ (ref-stamp($rakupp-repo, $_), ver-key($_)) });
    @refs.push('HEAD');

    # Retrospective bench points: tagged artifacts re-run on ONE machine in
    # one sitting (src/data/bench-backfill.tsv says when and how). Gap-fill
    # only — a kernel a tag's own committed tables carry keeps its mined
    # numbers; the backfill exists precisely because those tables were
    # measured on whatever machine each release had.
    my %backfill;
    my $bf = 'src/data/bench-backfill.tsv'.IO;
    if $bf.e {
        for $bf.lines -> $line {
            next if $line.starts-with('#') || !$line.trim;
            my @p = $line.words;
            next unless @p.elems == 4;
            %backfill{@p[0]}{@p[1]}{@p[2]} = @p[3].Num;
        }
    }

    my @entries;
    # The `-O` table is re-measured RARELY — written once and carried forward
    # verbatim across a dozen tags. Mining it per ref therefore yields the same
    # reading over and over, and charting those would draw a flat line that
    # looks like a dozen sittings agreeing when it is one sitting repeated. A
    # ref emits its optbench block only when the table CHANGED there, so the
    # series has a point exactly where a measurement happened and a gap
    # elsewhere (the chart already skips nulls).
    my $last-opt = '';
    my $first-charted = '';
    my $main-date = '';
    my $main-log  = '';
    for @refs -> $ref {
        my %roast = roast-at($rakupp-repo, $ref);
        next unless %roast<tests-pass>:exists;
        # a TAGGED release's own CHANGELOG row wins over ROAST.md (see above)
        if $ref ne 'HEAD' {
            my %cl = changelog-at($rakupp-repo, $ref);
            %roast<files-pass> = %cl<files-pass> if %cl<files-pass>:exists;
        }
        $first-charted = $ref unless $first-charted;
        my %bench = bench-at($rakupp-repo, $ref);
        # startup lives in a mode ladder of its own (see startup-at)
        my %su = startup-at($rakupp-repo, $ref);
        %bench<startup> = %su if %su;
        my %opt = optbench-at($rakupp-repo, $ref);
        my $label = $ref eq 'HEAD' ?? 'main' !! $ref;
        if %backfill{$label}:exists {
            for %backfill{$label}.kv -> $kernel, %engines {
                next if %bench{$kernel}:exists;   # the tag's own tables win
                %bench{$kernel} = %engines;
            }
        }
        my $date = ref-date($rakupp-repo, $ref);
        # The rev the numbers were measured at, and its short commit. Only an
        # UNTAGGED point needs the hash: a release point is named by its tag,
        # while `main` and every past sitting are just "a day", and a day can
        # hold two readings.
        my $rev    = $ref eq 'HEAD' ?? bench-rev-at($rakupp-repo, $ref) !! '';
        my $commit = $rev ?? rev-commit($rev) !! '';
        # No methodology line to read (an older doc): fall back to the commit
        # main is sitting on, which is at least the code the numbers came from.
        if $ref eq 'HEAD' && !$rev {
            $commit = run-lines('git', '-C', $rakupp-repo, 'log', '-1',
                                '--format=%h', 'HEAD').head // '';
        }
        my @f;
        @f.push('"tag":' ~ json-esc($label));
        @f.push('"date":' ~ json-esc($date));
        @f.push('"rev":' ~ json-esc($rev))       if $rev;
        @f.push('"commit":' ~ json-esc($commit)) if $commit;
        @f.push('"tests_pass":' ~ %roast<tests-pass>);
        @f.push('"tests_total":' ~ %roast<tests-total>);
        @f.push('"files_pass":' ~ %roast<files-pass>)   if %roast<files-pass>:exists;
        @f.push('"files_total":' ~ %roast<files-total>) if %roast<files-total>:exists;
        @f.push('"bench":' ~ bench-json(%bench));
        my $opt-here = False;
        if %opt {
            my $oj = optbench-json(%opt);
            if $oj ne $last-opt {
                @f.push('"optbench":' ~ $oj);
                $last-opt = $oj;
                $opt-here = True;
            }
        }
        @entries.push('{' ~ @f.join(',') ~ '}');
        # the same entry, labelled by its date, is what the log keeps once
        # `main` has moved on to a newer commit
        if $ref eq 'HEAD' {
            $main-date = $date;
            @f[0] = '"tag":' ~ json-esc(short-date($date));
            $main-log = '{' ~ @f.join(',') ~ '}';
        }
        say "  $label: {%roast<tests-pass>}/{%roast<tests-total>} tests, " ~
            "{%roast<files-pass> // '?'}/{%roast<files-total> // '?'} files, " ~
            "{%bench.keys.elems} kernels" ~
            ($opt-here ?? ", {%opt.keys.elems} optbench (re-measured here)" !! '');
    }

    # Past main sittings, charted as their own dated points, and this run's
    # main logged for the next one (see SITTINGS). Only sittings from a date
    # main has already left behind are drawn — otherwise today's reading would
    # appear twice, once as `main` and once as its own date.
    if $main-date {
        my @log = SITTINGS.IO.e ?? SITTINGS.IO.lines.grep(*.trim) !! ();
        my $main-bench = sitting-bench($main-log);
        my $main-rev   = sitting-rev($main-log);
        my $is-main = -> $line {
            my $rev = sitting-rev($line);
            # A rev on both sides is decisive either way: same rev is the same
            # sitting, a different rev is a different one even on the same date.
            $rev && $main-rev ?? $rev eq $main-rev
                              !! sitting-bench($line) eq $main-bench
                                 || (!$rev && !$main-rev && sitting-date($line) eq $main-date)
        };
        my @past = @log.grep({ !$is-main($_) });
        # Each sitting goes in at its own DATE, not as a block before `main`:
        # a positional splice was right while nothing postdated the sittings,
        # but a release tagged after them (v3.20.x vs the Aug 21-22 sittings)
        # then charted BEFORE them and the x-axis ran backwards.
        for @past -> $p {
            my $at = @entries.first(:k,
                { (sitting-date($_) || '9999-99-99') gt sitting-date($p) }) // @entries.end;
            @entries.splice($at, 0, $p);
        }
        say "  past sittings: {@past.elems} dated bench points merged by date";
        unless @log.first({ $is-main($_) }) {
            spurt SITTINGS, (|@log, $main-log).join("\n") ~ "\n";
            say "  logged main's $main-date sitting to {SITTINGS}";
        }
    }

    # Pre-release run-up: daily points from ROAST.md's history before the
    # first release that carries chartable numbers.
    my @dev;
    if $first-charted {
        for @(dev-series($rakupp-repo, $first-charted)) -> %p {
            my @f;
            @f.push('"tag":' ~ json-esc(short-date(%p<date>)));
            @f.push('"date":' ~ json-esc(%p<date>));
            @f.push('"files_pass":' ~ %p<files-pass>);
            @f.push('"tests_pass":' ~ %p<tests-pass>)   if %p<tests-pass>:exists;
            @f.push('"tests_total":' ~ %p<tests-total>) if %p<tests-total>:exists;
            @f.push('"rebaselined":true')               if %p<rebaselined>;
            @dev.push('{' ~ @f.join(',') ~ '}');
        }
    }
    say "  pre-release: {@dev.elems} daily points before $first-charted";

    my @mods;
    for @(battery-series($battery)) -> %p {
        my $batch = %p<batch>:exists ?? ',"batch":' ~ %p<batch> !! '';
        @mods.push('{"date":' ~ json-esc(%p<date>) ~ ',"n":' ~ %p<n> ~ ',"total":' ~ %p<total> ~ $batch ~ '}');
    }
    say "  modules: {@mods.elems} battery points";

    # Whole-ecosystem sweeps: one point per docs/dev/findings/ECOSWEEP-*.md in
    # the rakupp repo. The anchor line is "**Green total: N of M**" — keep
    # writing exactly that in future sweep write-ups; it is what this mines.
    # The chart's point (the user's framing): the graph shows how many modules
    # RUN under Raku++, and the curated battery was only where that started —
    # the sweep line is the ecosystem-scale answer. Dated by the file's last
    # commit; the working tree wins at HEAD, same rule as status-doc().
    my @sweep;
    for run-lines('git', '-C', $rakupp-repo, 'ls-files', 'docs/dev/findings/ECOSWEEP-*.md').sort -> $f {
        my $txt = "$rakupp-repo/$f".IO.e ?? "$rakupp-repo/$f".IO.slurp !! show-file($rakupp-repo, 'HEAD', $f);
        next unless $txt ~~ / 'Green total:' \s* (<[0..9,]>+) \s+ 'of' \s+ (<[0..9,]>+) /;
        my ($n, $total) = denum(~$0), denum(~$1);
        my $date = run-lines('git', '-C', $rakupp-repo, 'log', '-1', '--format=%as', '--', $f).head // '';
        next unless $date;
        @sweep.push({ date => $date, n => $n, total => $total });
    }
    @sweep = @sweep.sort(*.<date>);
    my @sweepj = @sweep.map({ '{"date":' ~ json-esc(.<date>) ~ ',"n":' ~ .<n> ~ ',"total":' ~ .<total> ~ '}' });
    say "  sweep: {@sweepj.elems} whole-ecosystem points";

    # Documentation conformance over time, straight off the snapshots
    # tools/snapshot.raku appends — one record per run of the three-way
    # comparison. This series is only as dense as snapshot.raku has been run,
    # which is why the runbook pairs the two.
    my @conf;
    if 'src/data/history.jsonl'.IO.e {
        for 'src/data/history.jsonl'.IO.lines -> $line {
            next unless $line.trim;
            # each record is one flat JSON object; pull just what the chart needs
            my $date = $line ~~ / '"date":"' <( <-["]>+ )> '"' / ?? ~$/ !! next;
            my %n;
            for <ok rakupp-differs rakudo-differs doc-drift all-differ not-runnable> -> $k {
                %n{$k} = ($line ~~ / '"' $k '":' <( \d+ )> /) ?? +$/ !! 0;
            }
            @conf.push('{"date":' ~ json-esc($date) ~ ',' ~
                       (%n.keys.sort.map({ json-esc($_) ~ ':' ~ %n{$_} }).join(',')) ~ '}');
        }
    }
    say "  conformance: {@conf.elems} snapshot points";

    my $today = run-lines('git', '-C', $rakupp-repo, 'log', '-1', '--format=%as', 'HEAD').head // '';
    my $json = '{"generated":' ~ json-esc($today) ~
               ',"dev":['      ~ @dev.join(',')     ~ ']' ~
               ',"releases":[' ~ @entries.join(',') ~ ']' ~
               ',"conformance":[' ~ @conf.join(',') ~ ']' ~
               ',"modules":['  ~ @mods.join(',')    ~ ']' ~
               ',"sweep":['    ~ @sweepj.join(',')  ~ ']}';
    mkdir('src/data');
    spurt('src/data/dashboard.json', $json);
    say "wrote src/data/dashboard.json ({@entries.elems} releases)";
}
