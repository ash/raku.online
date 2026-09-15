#!/usr/bin/env rakupp
# String::Stream — Using it
# https://raku.online/modules/string-stream/#using-it
#
# Install what it needs, then run it:
#     rakupp install String::Stream
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Stream;

my $s = String::Stream.new('');
$s.print('a', 'b');
$s.print('c');
$s.say(42);
$s.print('e');

say 'buffer     : ', $s.get.raku;
say 'read twice : ', $s.get.raku;
say '';
say '.print joins its arguments with NO separator; .say appends "\n".';
say '.get does not consume — read it twice and you get the history twice.';
say '';
my $seeded = String::Stream.new('seed:');
$seeded.print('x');
say 'new(Str)   : ', $seeded.get.raku;

# Output:
#     buffer     : "abc42\ne"
#     read twice : "abc42\ne"
#     
#     .print joins its arguments with NO separator; .say appends "\n".
#     .get does not consume — read it twice and you get the history twice.
#     
#     new(Str)   : "seed:x"
