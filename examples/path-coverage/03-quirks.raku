#!/usr/bin/env rakupp
# path-coverage — Two more things it gets wrong
# https://raku.online/modules/path-coverage/#two-more-things-it-gets-wrong
#
# Install what it needs, then run it:
#     rakupp install path-coverage
#     rakupp 03-quirks.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

my $root = $*TMPDIR.add("pathcov3-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.add('lib').mkdir;
$root.add('lib/Plain.pm6').spurt("class Inner \{ \}\nmy class Hidden \{ \}\n");
$root.add('lib/R.pl6').spurt("unit role R;\n");
$root.add('Top.pm6').spurt("unit class Top;\n");

indir $root, {
    my $p = run $*HOME.add('.raku/bin/path-coverage').Str, :out;
    say 'path-coverage says:';
    say '  ', $_ for $p.out.slurp(:close).lines.sort;
}
say '';
say 'a non-`unit` inner declaration is reported as if it were the file`s';
say 'package, so any file with a helper class in it produces a false';
say 'positive. `my class` is correctly ignored, so the two ARE told apart';
say '— but only the `my` form.';
say '';
say 'the name stripper only removes \\.pm6?$, so a .pl6 or .p6 file keeps';
say 'its extension in the expected name and can never match. And outside';
say 'a lib/ directory the expected name is derived from the raw relative';
say 'path, giving nonsense like ".::Top".';

# Output:
#     path-coverage says:
#       Inner should be Plain or declared with my keyword
#       R should be R.pl6 or declared with my keyword
#       Top should be .::Top or declared with my keyword
#     
#     a non-`unit` inner declaration is reported as if it were the file`s
#     package, so any file with a helper class in it produces a false
#     positive. `my class` is correctly ignored, so the two ARE told apart
#     — but only the `my` form.
#     
#     the name stripper only removes \.pm6?$, so a .pl6 or .p6 file keeps
#     its extension in the expected name and can never match. And outside
#     a lib/ directory the expected name is derived from the raw relative
#     path, giving nonsense like ".::Top".
