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
#   modules   the Tier-2 top-50 battery standing over time, read straight off
#             the battery repo's commit subjects ("Tier-2: N/50 …").
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
sub status-doc(Str $repo, Str $ref, Str $name --> Str) {
    for "docs/status/$name", "docs/$name" -> $path {
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
constant @KERNELS = <fib loopsum strcat hash bigint sortnums regex arrayops streq>;

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

sub bench-json(%bench --> Str) {
    my @parts;
    for @KERNELS -> $k {
        next unless %bench{$k}:exists;
        my %b = %bench{$k};
        my @f;
        @f.push('"interp":' ~ %b<interp>) if %b<interp>:exists;
        @f.push('"native":' ~ %b<native>) if %b<native>:exists;
        @f.push('"rakudo":' ~ %b<rakudo>) if %b<rakudo>:exists;
        @parts.push(json-esc($k) ~ ':{' ~ @f.join(',') ~ '}');
    }
    '{' ~ @parts.join(',') ~ '}'
}

sub MAIN(Str :$rakupp-repo = '../raku++', Str :$battery = '../raku-module-battery') {
    die "rakupp repo not found at $rakupp-repo (pass --rakupp-repo=PATH)"
        unless "$rakupp-repo/.git".IO.e;
    die "battery repo not found at $battery (pass --battery=PATH)"
        unless "$battery/.git".IO.e;

    my @refs = run-lines('git', '-C', $rakupp-repo, 'tag', '--list', 'v*').sort;
    @refs.push('HEAD');

    my @entries;
    my $first-charted = '';
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
        my $label = $ref eq 'HEAD' ?? 'main' !! $ref;
        my @f;
        @f.push('"tag":' ~ json-esc($label));
        @f.push('"date":' ~ json-esc(ref-date($rakupp-repo, $ref)));
        @f.push('"tests_pass":' ~ %roast<tests-pass>);
        @f.push('"tests_total":' ~ %roast<tests-total>);
        @f.push('"files_pass":' ~ %roast<files-pass>)   if %roast<files-pass>:exists;
        @f.push('"files_total":' ~ %roast<files-total>) if %roast<files-total>:exists;
        @f.push('"bench":' ~ bench-json(%bench));
        @entries.push('{' ~ @f.join(',') ~ '}');
        say "  $label: {%roast<tests-pass>}/{%roast<tests-total>} tests, " ~
            "{%roast<files-pass> // '?'}/{%roast<files-total> // '?'} files, " ~
            "{%bench.keys.elems} kernels";
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
               ',"modules":['  ~ @mods.join(',')    ~ ']}';
    mkdir('src/data');
    spurt('src/data/dashboard.json', $json);
    say "wrote src/data/dashboard.json ({@entries.elems} releases)";
}
