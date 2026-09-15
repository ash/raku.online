#!/usr/bin/env rakupp
# Texas::To::Uni — Converting a string
# https://raku.online/modules/texas-to-uni/#converting-a-string
#
# Install what it needs, then run it:
#     rakupp install Texas::To::Uni
#     rakupp 01-string.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Texas::To::Uni;

my $src = 'my @a = (1,2) (<=) (3,4); say (5,6) (>=) (7,8);';
convert-string($src);
say $src;
say '';
my $shift = 'if $a <<= $b { say $a ** 2 }';
convert-string($shift);
say $shift;
say '';
say 'note the signature: convert-string(Str $source is rw). It MUTATES';
say 'your variable and returns Any — the return value is useless.';
my $x = 'a << b';
my $ret = convert-string($x);
say '  return value : ', $ret.raku;
say '  the variable : ', $x.raku;

# Output:
#     my @a = (1,2) ⊆ (3,4); say (5,6) ⊇ (7,8);
#     
#     if $a «= $b { say $a ** 2 }
#     
#     note the signature: convert-string(Str $source is rw). It MUTATES
#     your variable and returns Any — the return value is useless.
#       return value : Any
#       the variable : "a « b"
