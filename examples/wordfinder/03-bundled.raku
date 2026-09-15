#!/usr/bin/env rakupp
# wordfinder — The one thing to know
# https://raku.online/modules/wordfinder/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install wordfinder
#     rakupp 03-bundled.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use wordfinder;

my $r = try check_file('tea');
say 'check_file("tea") with no path -> ', $! ?? 'threw' !! $r.raku;
say '';
say 'it is CWD-relative, not missing: create ./resources/en_dict.txt in';
say 'whatever directory you run from and the same call starts working.';
say '';
my $dir = $*TMPDIR.add("wf-{$*PID}");
LEAVE { $dir.add('resources/en_dict.txt').unlink; $dir.add('resources').rmdir; $dir.rmdir }
$dir.add('resources').mkdir;
$dir.add('resources/en_dict.txt').spurt("eat\nate\ntea\ntar\n");
my $old = $*CWD;
indir $dir, { say '  from inside such a directory: ', check_file('tea').raku };
say '';
say 'the two-argument (letters, Int) form has the same defect. Only the';
say 'forms where you pass a path yourself, and check_array, are usable.';

# Output:
#     check_file("tea") with no path -> threw
#     
#     it is CWD-relative, not missing: create ./resources/en_dict.txt in
#     whatever directory you run from and the same call starts working.
#     
#       from inside such a directory: ["eat", "ate", "tea"]
#     
#     the two-argument (letters, Int) form has the same defect. Only the
#     forms where you pass a path yourself, and check_array, are usable.
