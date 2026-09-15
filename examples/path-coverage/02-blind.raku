#!/usr/bin/env rakupp
# path-coverage — The one thing to know
# https://raku.online/modules/path-coverage/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install path-coverage
#     rakupp 02-blind.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

my $root = $*TMPDIR.add("pathcov2-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.add('lib').mkdir;
$root.add('lib/Modern.rakumod').spurt("unit class AlsoWrong;\n");

my $bin = $*HOME.add('.raku/bin/path-coverage').Str;
my @lines = indir $root, { run($bin, :out).out.slurp(:close).lines.grep(*.chars) };
say 'a lib/ holding only Modern.rakumod, declaring `unit class AlsoWrong`:';
say '  path-coverage output lines : ', @lines.elems;
say '';
say 'the file filter is  name => /.p [l||m] 6? $/  — a literal "p" then';
say '"l" or "m" at the end of the name. It matches .pm, .pm6, .pl, .pl6';
say 'and nothing else. A distribution written since the .rakumod rename';
say 'gets a silent all-clear from path-coverage and an EMPTY provides';
say 'block from path-provides, which is precisely the case where you';
say 'most wanted the tool to speak up.';

# Output:
#     a lib/ holding only Modern.rakumod, declaring `unit class AlsoWrong`:
#       path-coverage output lines : 0
#     
#     the file filter is  name => /.p [l||m] 6? $/  — a literal "p" then
#     "l" or "m" at the end of the name. It matches .pm, .pm6, .pl, .pl6
#     and nothing else. A distribution written since the .rakumod rename
#     gets a silent all-clear from path-coverage and an EMPTY provides
#     block from path-provides, which is precisely the case where you
#     most wanted the tool to speak up.
