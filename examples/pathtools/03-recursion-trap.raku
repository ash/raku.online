#!/usr/bin/env rakupp
# PathTools — The one thing to know
# https://raku.online/modules/pathtools/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install PathTools
#     rakupp 03-recursion-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use PathTools;

my $root = "{$*TMPDIR}/pt2-{$*PID}";
LEAVE { rm($root, :r, :d, :f) if $root.IO.e }

mkdirs("$root/sub");
"$root/top.txt".IO.spurt('t');
"$root/sub/deep.txt".IO.spurt('d');

sub show(@l) { @l.map(*.Str.subst($root, '<ROOT>')).sort.join(' | ') }

say 'the nested file exists : ', "$root/sub/deep.txt".IO.e;
say 'ls(:r)          : ', show(ls($root, :r).list);
say 'ls(:r, :!d)     : ', show(ls($root, :r, :!d).list);
say '';
say 'the working incantation:';
say 'ls(:r).grep(*.IO.f) : ', show(ls($root, :r).grep(*.IO.f).list);

# Output:
#     the nested file exists : True
#     ls(:r)          : <ROOT>/sub | <ROOT>/sub/deep.txt | <ROOT>/top.txt
#     ls(:r, :!d)     : <ROOT>/top.txt
#     
#     the working incantation:
#     ls(:r).grep(*.IO.f) : <ROOT>/sub/deep.txt | <ROOT>/top.txt
