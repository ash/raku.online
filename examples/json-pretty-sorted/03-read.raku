#!/usr/bin/env rakupp
# JSON::Pretty::Sorted — Reading back
# https://raku.online/modules/json-pretty-sorted/#reading-back
#
# Install what it needs, then run it:
#     rakupp install JSON::Pretty::Sorted
#     rakupp 03-read.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Pretty::Sorted;

my &safe = { ($^x ~~ Pair ?? $x.key !! $x) cmp ($^y ~~ Pair ?? $y.key !! $y) };
my $text = to-json({ b => 1, a => [1, 2] }, sorter => &safe);
my %back = from-json($text);
say 'round trip : ', %back.keys.sort.map({ "$_=" ~ %back{$_}.raku }).join(' ');
say '';
say 'scalars:';
say '  from-json("123")  : ', from-json('123').raku;
say '  from-json(\'"s"\')  : ', from-json('"s"').raku;
say '  from-json("true") : ', from-json('true').raku;
say '  from-json("null") : ', from-json('null').raku;
say '';
say 'malformed input throws : ', (try from-json('{')).defined ?? 'no' !! 'yes';

# Output:
#     round trip : a=$[1, 2] b=1
#     
#     scalars:
#       from-json("123")  : 123
#       from-json('"s"')  : "s"
#       from-json("true") : Bool::True
#       from-json("null") : Any
#     
#     malformed input throws : yes
