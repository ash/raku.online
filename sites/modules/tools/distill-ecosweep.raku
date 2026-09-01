#!/usr/bin/env raku
# distill-ecosweep.raku — fold the rakupp repo's ecosystem-sweep TSVs into the
# one committed data file the /modules/ecosystem/ page renders from.
#
#   rakupp tools/distill-ecosweep.raku \
#       --results=/Users/ash/raku++/docs/dev/findings/ecosweep/results-2524.tsv \
#       --rerun=/Users/ash/raku++/docs/dev/findings/ecosweep/rerun-1900.tsv \
#       --rank=<rank-ecosystem.raku output> \
#       --index=$HOME/.raku/rakupp-install/rea-meta.json \
#       --fallout=src/data/rakuast-fallout.tsv
#
# The first pass covers every dist; the re-run covers the then-non-pass dists
# on the fixed engine, and its verdict REPLACES the first pass's for those
# dists — the fold mirrors how the sweep write-up counts its Green total.
# Re-run at each sweep (runbook: the ECOSWEEP-*.md Timeline block and this
# file move together).

sub trim-err(Str $e is copy --> Str) {
    # the staging path is noise a reader cannot use — the dist name is the row
    $e .= subst(/ '/var/folders/' \S+? '/T/rakupp-install-' \d+ '-' \S+? '/' /, '', :g);
    $e .= subst(/ \s+ /, ' ', :g);
    $e.chars > 220 ?? $e.substr(0, 217) ~ '…' !! $e
}

sub read-tsv(Str $path --> Hash) {
    my %rows;
    for $path.IO.lines.skip(1) -> $line {
        my @c = $line.split("\t");
        next unless @c.elems >= 4;
        # name version released verdict detail seconds exit first-error
        # `detail` is kept only as a fallback for the handful of dists whose
        # log is missing — see the note above blockers-of for why it cannot
        # be trusted as the answer on its own.
        my $verdict = @c[3];
        my $culprit = $verdict eq 'dep-fail' | 'dep-build-fail'
                      ?? (@c[4] // '').trim !! '';
        %rows{@c[0]} = { version => @c[1], verdict => $verdict,
                         culprit => $culprit, blockers => '',
                         error   => trim-err(@c[7] // '') };
    }
    %rows
}

# Who ships a dist is in no sweep TSV — only the REA index knows, and the
# installer keeps a cached copy (~/.raku/rakupp-install/rea-meta.json, one
# dist-version JSON object per line). The `dist` string is the identity —
# name:ver<>:auth<> — and `authors` the human names. Read line-wise, no JSON
# parser needed: `"dist":"…"` cannot occur INSIDE a JSON string (its quotes
# would be escaped there), and `authors` is alphabetically the first key.
sub read-index(Str $path) {
    my %exact;      # "name\0version" -> [auth, human names]
    my %latest;     # name -> [auth, human names] of the newest release
    my %newest;     # name -> the release-date behind %latest
    for $path.IO.lines -> $line {
        next unless $line ~~ / '"dist":"' (<-["]>+) '"' /;
        my $id = ~$0;
        next unless $id ~~ / ^ (.+?) ':ver<' (<-[>]>+) '>' /;
        my $name = ~$0;
        my $ver  = ~$1;
        my $auth = $id ~~ / ':auth<' (<-[>]>+) '>' / ?? ~$0 !! '';
        my $authors = '';
        if $line ~~ / '"authors":[' (<-[\]]>*) ']' / {
            $authors = (~$0).comb(/ '"' <-["]>* '"' /)
                            .map({ .substr(1, .chars - 2).trim })
                            .grep(*.chars).join(', ')
                            .subst(/ \s+ /, ' ', :g);
        }
        my $date = $line ~~ / '"release-date":"' (<-["]>+) '"' / ?? ~$0 !! '';
        %exact{$name ~ "\0" ~ $ver} = [$auth, $authors];
        if !%latest{$name} || $date gt %newest{$name} {
            %newest{$name} = $date;
            %latest{$name} = [$auth, $authors];
        }
    }
    # Itemized, or the first hash in a list assignment slurps them both.
    $(%exact), $(%latest)
}

# Which dependency actually blocks a dist is NOT the sweep's `detail` column.
# The sweep shares one module store across every run and skips a dependency
# that is already installed rather than re-testing it, so `detail` names the
# first dependency that run happened to have to fetch and test from scratch —
# a property of store state, not of the dependency graph. BSON::Simple
# recorded Getopt::Long that way; from a cold store you meet Path::Finder
# first, and in truth five of its dependencies fail on their own code. Across
# the sweep only 137 of 437 `detail` names were even the first failing
# dependency in install order.
#
# So the blockers are reconstructed: each log opens with the plan the
# installer resolved — `plan (N distributions, dependencies first)` — and
# every entry in it that earned a self-fail or build-fail verdict IN ITS OWN
# RIGHT is a dependency this dist cannot get past, listed in the order the
# install would meet them. That answer is the same whatever is in the store.
sub plan-of(Str $name, @dirs) {
    my $file = $name.subst('::', '-', :g) ~ '.log';
    for @dirs -> $dir {
        my $p = $dir.IO.add($file);
        next unless $p.e;
        my @out;
        my $in = False;
        for $p.lines -> $l {
            unless $in {
                $in = True if $l ~~ / ^ 'plan (' \d+ ' distribution' /;
                next;
            }
            last unless $l.starts-with('  ');
            @out.push(~$0) if $l ~~ / ^ \s+ (.+?) ':ver<' /;
        }
        return @out if @out;
    }
    ()
}

sub MAIN(Str :$results!, Str :$rerun = '', Str :$rank = '', Str :$index = '',
         Str :$logs = '', Str :$rerun-logs = '', Str :$fallout = '',
         Str :$out = 'src/data/ecosweep.tsv') {
    my %all = read-tsv($results);
    if $rerun && $rerun.IO.e {
        my %over = read-tsv($rerun);
        %all{$_} = %over{$_} for %over.keys;
    }
    # Reverse-dependency counts from harness/rank-ecosystem.raku's output
    # (battery repo): columns rank/dist/run/…, `run` = how many OTHER dists'
    # runtime depends resolve to this one (self excluded). A dist absent from
    # the ranking has zero dependents.
    # The re-run's logs answer for the dists it re-measured, the first
    # sweep's for the rest — the same precedence the verdicts follow.
    my @logdirs = ($rerun-logs, $logs).grep({ $_ && $_.IO.d });
    if @logdirs {
        my %verdict = %all.keys.map({ $_ => %all{$_}<verdict> });
        my $reconstructed = 0;
        my $fellback = 0;
        for %all.keys -> $n {
            next unless %all{$n}<verdict> eq 'dep-fail' | 'dep-build-fail';
            my @blockers = plan-of($n, @logdirs)
                .grep({ $_ ne $n && (%verdict{$_} // '') eq 'self-fail' | 'build-fail' })
                .unique;
            if @blockers {
                %all{$n}<blockers> = @blockers.join(';');
                $reconstructed++;
            }
            # No log, or a log with no plan block: the sweep's own name is
            # better than nothing, provided that dist really does fail on
            # its own code.
            elsif %all{$n}<culprit>
                  && (%verdict{%all{$n}<culprit>} // '') eq 'self-fail' | 'build-fail' {
                %all{$n}<blockers> = %all{$n}<culprit>;
                $fellback++;
            }
        }
        say "blockers: $reconstructed reconstructed from plans, $fellback from the sweep's own name";
    }
    else { note "no --logs/--rerun-logs given: blockers fall back to the sweep's `detail` name, which is store-dependent" }

    my %deps;
    if $rank && $rank.IO.e {
        for $rank.IO.lines.skip(1) -> $line {
            my @c = $line.split("\t");
            %deps{@c[1]} = @c[2].Int if @c.elems >= 3 && @c[1];
        }
    }
    my ($exact, $latest) = {}, {};
    if $index && $index.IO.e {
        ($exact, $latest) = read-index($index);
        say "index: {$latest.elems} dists with an author";
    }

    # The RakuAST flag (tools/rakuast-fallout.raku) — orthogonal to the
    # verdict, so it rides beside it rather than inside it: a `legacy` dist
    # can be green, and a `needs-AST` one is blocked on us, not on its author.
    my %fallout;
    if $fallout && $fallout.IO.e {
        for $fallout.IO.lines.skip(1) -> $line {
            my @c = $line.split("\t");
            %fallout{@c[0]} = @c[1] if @c.elems >= 2 && @c[0];
        }
        say "fallout: {%fallout.elems} dists flagged legacy/needs-AST";
    }

    my @names = %all.keys.sort(*.lc);
    my $fh = open($out, :w);
    $fh.say("name\tversion\tverdict\tblockers\tdeps\tauth\tauthors\terror\trakuast");
    for @names -> $n {
        my %r = %all{$n};
        # The entry for the swept version names its author; a version the
        # index has since dropped falls back to the newest release — which
        # is what the sweep installed anyway.
        my $hit = $exact{$n ~ "\0" ~ %r<version>} // $latest{$n};
        my $auth    = $hit ?? $hit[0] !! '';
        my $authors = $hit ?? $hit[1] !! '';
        $fh.say("$n\t{%r<version>}\t{%r<verdict>}\t{%r<blockers> || %r<culprit>}\t{%deps{$n} // 0}\t$auth\t$authors\t{%r<error>}\t{%fallout{$n} // ''}");
    }
    $fh.close;
    my %tally;
    %tally{%all{$_}<verdict>}++ for %all.keys;
    say "wrote $out — {@names.elems} dists";
    say "  {%tally{$_}} $_" for %tally.keys.sort({ -%tally{$_} });
}
