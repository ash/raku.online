#!/usr/bin/env raku
# distill-ecosweep.raku — fold the rakupp repo's ecosystem-sweep TSVs into the
# one committed data file the /modules/ecosystem/ page renders from.
#
#   rakupp tools/distill-ecosweep.raku \
#       --results=/Users/ash/raku++/docs/dev/findings/ecosweep/results-2524.tsv \
#       --rerun=/Users/ash/raku++/docs/dev/findings/ecosweep/rerun-1900.tsv \
#       --rank=<rank-ecosystem.raku output> \
#       --index=$HOME/.raku/rakupp-install/rea-meta.json
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
        %rows{@c[0]} = { version => @c[1], verdict => @c[3],
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

sub MAIN(Str :$results!, Str :$rerun = '', Str :$rank = '', Str :$index = '',
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

    my @names = %all.keys.sort(*.lc);
    my $fh = open($out, :w);
    $fh.say("name\tversion\tverdict\tdeps\tauth\tauthors\terror");
    for @names -> $n {
        my %r = %all{$n};
        # The entry for the swept version names its author; a version the
        # index has since dropped falls back to the newest release — which
        # is what the sweep installed anyway.
        my $hit = $exact{$n ~ "\0" ~ %r<version>} // $latest{$n};
        my $auth    = $hit ?? $hit[0] !! '';
        my $authors = $hit ?? $hit[1] !! '';
        $fh.say("$n\t{%r<version>}\t{%r<verdict>}\t{%deps{$n} // 0}\t$auth\t$authors\t{%r<error>}");
    }
    $fh.close;
    my %tally;
    %tally{%all{$_}<verdict>}++ for %all.keys;
    say "wrote $out — {@names.elems} dists";
    say "  {%tally{$_}} $_" for %tally.keys.sort({ -%tally{$_} });
}
