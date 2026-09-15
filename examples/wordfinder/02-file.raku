#!/usr/bin/env rakupp
# wordfinder — Matching against a file
# https://raku.online/modules/wordfinder/#matching-against-a-file
#
# Install what it needs, then run it:
#     rakupp install wordfinder
#     rakupp 02-file.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use wordfinder;

my $dict = $*TMPDIR.add("wordfinder-{$*PID}.txt");
LEAVE $dict.unlink;
$dict.spurt("eat\nate\ntea\neaten\ntar\n");

say 'check_file("tea", $path)    : ', check_file('tea', $dict.Str).raku;
say 'check_file("tea", $path, 3) : ', check_file('tea', $dict.Str, 3).raku;
say '';
say 'read_dict returns the lines: ', read_dict($dict.Str).elems, ' of them';

# Output:
#     check_file("tea", $path)    : ["eat", "ate", "tea"]
#     check_file("tea", $path, 3) : ["eat", "ate", "tea"]
#     
#     read_dict returns the lines: 5 of them
