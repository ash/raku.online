#!/usr/bin/env rakupp
# Path::Finder — Rules, and pruning
# https://raku.online/modules/path-finder/#rules-and-pruning
#
# Install what it needs, then run it:
#     rakupp install Path::Finder
#     rakupp 01-find.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Finder;

my $root = $*TMPDIR.add("pf-{$*PID}");
$root.mkdir;
$root.add('lib').mkdir;
$root.add('lib/deep').mkdir;
$root.add('.git').mkdir;
$root.add('README.md').spurt("top\n");
$root.add('lib/A.rakumod').spurt("unit class A;\n");
$root.add('lib/deep/B.rakumod').spurt("unit class B;\nneedle\n");
$root.add('.git/config').spurt("[core]\n");

say find($root, :file, :name('*.rakumod'), :relative).map(~*).sort;
say find($root, :file, :lines(/needle/), :relative).map(~*).sort;
say find($root, :directory, :relative).map(~*).sort;
say find($root, :file, :skip-dir('.git'), :relative).map(~*).sort;

my $rule = Path::Finder.file.name('*.md');
say $rule.in($root, :relative).map(~*).sort;
say $rule.^name;

sub nuke($d) { for $d.dir { $_.d ?? nuke($_) !! .unlink }; rmdir $d }
nuke($root);

# Output:
#     (lib/A.rakumod lib/deep/B.rakumod)
#     (lib/deep/B.rakumod)
#     (. .git lib lib/deep)
#     (README.md lib/A.rakumod lib/deep/B.rakumod)
#     (README.md)
#     Path::Finder
