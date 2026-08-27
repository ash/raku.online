#!/usr/bin/env raku
# distill-ecosweep.raku — fold the rakupp repo's ecosystem-sweep TSVs into the
# one committed data file the /modules/ecosystem/ page renders from.
#
#   rakupp tools/distill-ecosweep.raku \
#       --results=/Users/ash/raku++/docs/dev/findings/ecosweep/results-2524.tsv \
#       --rerun=/Users/ash/raku++/docs/dev/findings/ecosweep/rerun-1900.tsv
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

sub MAIN(Str :$results!, Str :$rerun = '', Str :$out = 'src/data/ecosweep.tsv') {
    my %all = read-tsv($results);
    if $rerun && $rerun.IO.e {
        my %over = read-tsv($rerun);
        %all{$_} = %over{$_} for %over.keys;
    }
    my @names = %all.keys.sort(*.lc);
    my $fh = open($out, :w);
    $fh.say("name\tversion\tverdict\terror");
    for @names -> $n {
        my %r = %all{$n};
        $fh.say("$n\t{%r<version>}\t{%r<verdict>}\t{%r<error>}");
    }
    $fh.close;
    my %tally;
    %tally{%all{$_}<verdict>}++ for %all.keys;
    say "wrote $out — {@names.elems} dists";
    say "  {%tally{$_}} $_" for %tally.keys.sort({ -%tally{$_} });
}
