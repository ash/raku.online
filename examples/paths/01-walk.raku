#!/usr/bin/env rakupp
# paths — Walking a tree
# https://raku.online/modules/paths/#walking-a-tree
#
# Install what it needs, then run it:
#     rakupp install paths
#     rakupp 01-walk.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use paths;

my $root = $*TMPDIR.add('paths-demo-' ~ $*PID);
for <keep/a.txt keep/inner/b.txt skip/a.txt skip/inner/b.txt root.txt> -> $rel {
    my $f = $root.add($rel);
    $f.parent.mkdir;
    $f.spurt('x');
}
sub rel($p) { $p.substr($root.Str.chars + 1) }
sub show($label, @found) { say sprintf('%-26s %s', $label, @found.map(&rel).sort.join('  ')) }

show 'everything:',       paths($root).list;
show 'only *.txt:',       paths($root, :file(/ '.txt' $ /)).list;
show ':!recurse alone:',  paths($root, :!recurse).list;
say '';
show ':dir(keep) :!recurse', paths($root, :dir(/ keep | inner /), :!recurse).list;
show ':dir(keep) :recurse',  paths($root, :dir(/ keep | inner /), :recurse).list;

run 'rm', '-rf', $root.Str;

# Output:
#     everything:                keep/a.txt  keep/inner/b.txt  root.txt  skip/a.txt  skip/inner/b.txt
#     only *.txt:                keep/a.txt  keep/inner/b.txt  root.txt  skip/a.txt  skip/inner/b.txt
#     :!recurse alone:           keep/a.txt  keep/inner/b.txt  root.txt  skip/a.txt  skip/inner/b.txt
#     
#     :dir(keep) :!recurse       keep/a.txt  keep/inner/b.txt  root.txt
#     :dir(keep) :recurse        keep/a.txt  keep/inner/b.txt  root.txt  skip/inner/b.txt
