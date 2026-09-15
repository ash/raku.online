#!/usr/bin/env rakupp
# PathTools — Listing and creating
# https://raku.online/modules/pathtools/#listing-and-creating
#
# Install what it needs, then run it:
#     rakupp install PathTools
#     rakupp 01-ls.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use PathTools;

my $root = "{$*TMPDIR}/pt-{$*PID}";
LEAVE { rm($root, :r, :d, :f) if $root.IO.e }

say 'mkdirs returns the deepest directory it made:';
my $deep = mkdirs("$root/a/b/c");
say '  ', $deep.subst($root, '<ROOT>');
say '  it exists : ', $deep.IO.d;

"$root/a/one.txt".IO.spurt('x');
"$root/a/b/two.txt".IO.spurt('y');
"$root/a/b/c/three.txt".IO.spurt('z');

sub show(@l) { @l.map(*.Str.subst($root, '<ROOT>')).sort.join("\n  ") }

say '';
say 'ls flat (files and directories):';
say '  ', show(ls("$root/a").list);
say 'ls recursive:';
say '  ', show(ls("$root/a", :r).list);
say 'ls recursive, directories only:';
say '  ', show(ls("$root/a", :r, :!f).list);

# Output:
#     mkdirs returns the deepest directory it made:
#       <ROOT>/a/b/c
#       it exists : True
#     
#     ls flat (files and directories):
#       <ROOT>/a/b
#       <ROOT>/a/one.txt
#     ls recursive:
#       <ROOT>/a/b
#       <ROOT>/a/b/c
#       <ROOT>/a/b/c/three.txt
#       <ROOT>/a/b/two.txt
#       <ROOT>/a/one.txt
#     ls recursive, directories only:
#       <ROOT>/a/b
#       <ROOT>/a/b/c
