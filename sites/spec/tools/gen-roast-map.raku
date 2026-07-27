#!/usr/bin/env rakupp
# gen-roast-map.raku — snapshot rakupp's Roast conformance into a static JSON the
# spec site renders. Reads a run-roast results file (lines like
#   [PASS]    3/3  6.c/S14-roles/attributes.t
#   [part]  31/51  6.c/S02-types/subset-6c.t
# ) and emits src/data/roast-map.json. Run it after a fresh Roast run:
#   rakupp tools/gen-roast-map.raku <results.txt> <YYYY-MM-DD>
# The results file lives in the raku++ repo (machine-specific), so this is a
# periodic snapshot tool — the committed JSON keeps the site build portable.

sub json-str(Str $s --> Str) {
    '"' ~ $s.subst('\\', '\\\\', :g).subst('"', '\\"', :g) ~ '"'
}

# A file's declared test count from its first literal `plan N;` line, read straight
# from the Roast source. -1 for a dynamic/absent plan (`plan *`, computed, or none).
sub static-plan(Str $file --> Int) {
    return -1 unless $file.IO.e;
    for $file.IO.lines -> $ln {
        if $ln ~~ /^ \s* 'plan' <.ws> (\d+) / { return +$0 }
        if $ln ~~ /^ \s* 'plan' <.ws> '*'   / { return -1 }
    }
    -1
}

sub MAIN(Str $results, Str $date = 'unknown', Str $roast = '/Users/ash/roast') {
    my @rows;
    my %by-syn;                       # synopsis -> [pass, part, total-files, assertions-pass, assertions-total]
    my ($files, $ap, $at) = 0, 0, 0;

    for $results.IO.lines -> $line {
        # e.g. "  [PASS]    3/3  6.c/S14-roles/attributes.t"
        next unless $line ~~ / '[' (PASS|part|TIME) ']' \s+ (\d+) '/' (\d+) \s+ (\S+) /;
        my $st   = ~$0 eq 'PASS' ?? 'pass' !! (~$0 eq 'TIME' ?? 'time' !! 'part');
        my $pass = +$1;
        my $ran  = +$2;
        my $path = ~$3;                                   # 6.c/S02-types/subset-6c.t
        # A partial file that aborted mid-plan ran fewer tests than it declared —
        # show the DECLARED total (e.g. tree.t: ran 2 of plan 14), so the count
        # matches the amber status instead of a misleading 2/2.
        my $declared = $st eq 'part' ?? static-plan("$roast/$path") !! -1;
        my $tot = $declared > $ran ?? $declared !! $ran;
        my $rel  = $path.subst(/^ '6.' <[cd]> '/'/, '');  # S02-types/subset-6c.t
        next unless $rel.contains('/');
        my $syn  = $rel.substr(0, $rel.index('/'));       # S02-types
        my $name = $rel.substr($rel.index('/') + 1).subst(/ '.t' $/, '');

        @rows.push: %( :s($syn), :n($name), :st($st), :p($pass), :t($tot), :path($path) );
        %by-syn{$syn} //= [0, 0, 0, 0, 0];
        %by-syn{$syn}[0]++ if $st eq 'pass';
        %by-syn{$syn}[1]++ if $st eq 'part';
        %by-syn{$syn}[2]++;
        %by-syn{$syn}[3] += $pass;
        %by-syn{$syn}[4] += $tot;
        $files++; $ap += $pass; $at += $tot;
    }

    my @row-json = @rows.map({
        '{"s":' ~ json-str(.<s>) ~ ',"n":' ~ json-str(.<n>) ~ ',"st":' ~ json-str(.<st>)
        ~ ',"p":' ~ .<p> ~ ',"t":' ~ .<t> ~ ',"path":' ~ json-str(.<path>) ~ '}'
    });

    my @syn-json = %by-syn.keys.sort.map({
        my @v = %by-syn{$_};
        '{"s":' ~ json-str($_) ~ ',"pass":' ~ @v[0] ~ ',"part":' ~ @v[1]
        ~ ',"files":' ~ @v[2] ~ ',"ap":' ~ @v[3] ~ ',"at":' ~ @v[4] ~ '}'
    });

    # Authoritative conformance counting parsed from run-roast's own summary at
    # the bottom of the results file (the same three-denominator block quoted in
    # raku++ docs/ROAST.md). The per-file rows above are a snapshot of tests that
    # RAN; the summary carries the honest whole-suite figures, incl. no-TAP
    # (parse-error) files whose declared tests can't be in the row data. Parsing
    # it here means a fresh results file IS the refresh — no hand-maintained
    # numbers to forget (the 2026-07-22 site briefly showed a stale 87% headline
    # because these six values used to be literals).
    my %count;
    for $results.IO.lines -> $ln {
        if $ln ~~ / 'Files fully passing:' \s+ (\d+) \s* '/' \s* (\d+) / {
            %count<filesPass>  = +$0;
            %count<filesTotal> = +$1;
        }
        elsif $ln ~~ / 'Assertions passed:' \s+ (\d+) \s* '/' \s* (\d+) / {
            %count<passed> = +$0;
            my $d = +$1;
            if    $ln.contains('tests that ran') { %count<ran>      = $d }
            elsif $ln.contains('planned')        { %count<planned>  = $d }
            elsif $ln.contains('declared')       { %count<declared> = $d }
        }
    }
    for <passed ran planned declared filesPass filesTotal> -> $k {
        die "results file has no run-roast summary block (missing '$k') — "
            ~ "pass a full tools/run-roast.raku output file"
            unless %count{$k}:exists;
    }
    my $counting = '{"passed":' ~ %count<passed> ~ ',"ran":' ~ %count<ran>
        ~ ',"planned":' ~ %count<planned> ~ ',"declared":' ~ %count<declared>
        ~ ',"filesPass":' ~ %count<filesPass> ~ ',"filesTotal":' ~ %count<filesTotal> ~ '}';

    my $pass-files = @rows.grep(*.<st> eq 'pass').elems;
    my $json = '{"generated":' ~ json-str($date)
        ~ ',"counting":' ~ $counting
        ~ ',"totals":{"files":' ~ $files ~ ',"pass":' ~ $pass-files
        ~ ',"assertPass":' ~ $ap ~ ',"assertTotal":' ~ $at ~ '}'
        ~ ',"synopses":[' ~ @syn-json.join(',') ~ ']'
        ~ ',"rows":[' ~ @row-json.join(',') ~ ']}';

    'src/data'.IO.mkdir;
    spurt('src/data/roast-map.json', $json);
    say "wrote src/data/roast-map.json — $files files, $pass-files fully pass, "
        ~ "$ap/$at assertions across {%by-syn.elems} synopses";
}
