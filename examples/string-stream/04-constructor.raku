#!/usr/bin/env rakupp
# String::Stream — Where the two engines differ
# https://raku.online/modules/string-stream/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install String::Stream
#     rakupp 04-constructor.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Stream;

say 'the two documented forms:';
say '  .new()      -> buffer ', String::Stream.new.get.raku;
say '  .new("seed") -> buffer ', String::Stream.new('seed').get.raku;
say '';
say 'anything else is where the engines part:';
say '  .new(42)        builds with an EMPTY buffer on Raku++,';
say '                  X::Constructor::Positional on Rakudo';
say '  .new("a", "b")  the same';
say '';
say 'so a typo`d constructor argument is lost without a sound on one';
say 'engine and caught on the other. Pass one Str, or none.';
say '';
say 'the safe idiom:';
sub sink(Str $seed = '') { String::Stream.new($seed) }
my $s = sink();
$s.say('line one');
$s.say('line two');
say '  ', $s.get.raku;

# Output:
#     the two documented forms:
#       .new()      -> buffer Any
#       .new("seed") -> buffer "seed"
#     
#     anything else is where the engines part:
#       .new(42)        builds with an EMPTY buffer on Raku++,
#                       X::Constructor::Positional on Rakudo
#       .new("a", "b")  the same
#     
#     so a typo`d constructor argument is lost without a sound on one
#     engine and caught on the other. Pass one Str, or none.
#     
#     the safe idiom:
#       "line one\nline two\n"
