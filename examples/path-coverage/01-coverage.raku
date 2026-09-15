#!/usr/bin/env rakupp
# path-coverage — What they print
# https://raku.online/modules/path-coverage/#what-they-print
#
# Install what it needs, then run it:
#     rakupp install path-coverage
#     rakupp 01-coverage.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

my $root = $*TMPDIR.add("pathcov-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.add('lib/Deep').mkdir;
$root.add('lib/Good.pm6').spurt("unit class Good;\n");
$root.add('lib/Bad.pm6').spurt("unit class Wrong;\n");
$root.add('lib/Deep/Ok.pm6').spurt("unit class Deep::Ok;\n");
$root.add('lib/Modern.rakumod').spurt("unit class AlsoWrong;\n");

my $bin = $*HOME.add('.raku/bin');
indir $root, {
    my $cov = run $bin.add('path-coverage').Str, :out;
    say 'path-coverage says:';
    say '  ', $_ for $cov.out.slurp(:close).lines.sort;
    say '';
    my $prov = run $bin.add('path-provides').Str, :out;
    say 'path-provides says:';
    say '  ', $_ for $prov.out.slurp(:close).lines.sort;
}

# Output:
#     path-coverage says:
#       Wrong should be Bad or declared with my keyword
#     
#     path-provides says:
#       "Deep::Ok" : "./lib/Deep/Ok.pm6",
#       "Good" : "./lib/Good.pm6",
#       "Wrong" : "./lib/Bad.pm6",
