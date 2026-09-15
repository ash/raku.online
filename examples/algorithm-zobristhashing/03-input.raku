#!/usr/bin/env rakupp
# Algorithm::ZobristHashing — What counts as input
# https://raku.online/modules/algorithm-zobristhashing/#what-counts-as-input
#
# Install what it needs, then run it:
#     rakupp install Algorithm::ZobristHashing
#     rakupp 03-input.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;

say 'a Str is split into characters : ', $z.encode('ab') == $z.encode(['a', 'b']);
say 'elements are stringified       : ', $z.encode('12') == $z.encode([1, 2]);
say 'so "ab" is not ["ab"]          : ', $z.encode('ab') != $z.encode(['ab']);
say '';
say 'nested arrays are FLATTENED, so structure is lost:';
say '  [[1,2],[3,4]] == [1,2,3,4] : ', $z.encode([[1,2],[3,4]]) == $z.encode([1,2,3,4]);
say '  [[1],[2,3,4]] == [1,2,3,4] : ', $z.encode([[1],[2,3,4]]) == $z.encode([1,2,3,4]);

# Output:
#     a Str is split into characters : True
#     elements are stringified       : True
#     so "ab" is not ["ab"]          : True
#     
#     nested arrays are FLATTENED, so structure is lost:
#       [[1,2],[3,4]] == [1,2,3,4] : True
#       [[1],[2,3,4]] == [1,2,3,4] : True
