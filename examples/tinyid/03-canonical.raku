#!/usr/bin/env rakupp
# TinyID — The one thing to know
# https://raku.online/modules/tinyid/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install TinyID
#     rakupp 03-canonical.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyID;

my $t = TinyID.new(key => 'cbad');
say 'encode(0) = ', $t.encode(0).raku;
for '', 'c', 'cc', 'cccb', 'b' -> $s {
    say sprintf('  decode(%-8s) = %d', $s.raku, $t.decode($s));
}
say '';
say 'so "", "c", "cc" and "ccc…" are all ID 0, and "cccb" and "b" are';
say 'both ID 1.';
say '';
say 'if you use these as URL slugs or database keys, they are NOT';
say 'canonical: an attacker, or a careless cache, can mint unlimited';
say 'distinct strings for the same record.';
say '';
say 'the empty string is particularly easy to hit, because .comb of ""';
say 'is the empty set, which trivially satisfies the argument constraint.';
say '';
say 'check for canonicity yourself:';
sub canonical($t, Str $s) { $s.chars && $t.encode($t.decode($s)) eq $s }
for '', 'c', 'cccb', 'b', 'bd' -> $s {
    say sprintf('  canonical(%-8s) = %s', $s.raku, canonical($t, $s).so);
}

# Output:
#     encode(0) = "c"
#       decode(""      ) = 0
#       decode("c"     ) = 0
#       decode("cc"    ) = 0
#       decode("cccb"  ) = 1
#       decode("b"     ) = 1
#     
#     so "", "c", "cc" and "ccc…" are all ID 0, and "cccb" and "b" are
#     both ID 1.
#     
#     if you use these as URL slugs or database keys, they are NOT
#     canonical: an attacker, or a careless cache, can mint unlimited
#     distinct strings for the same record.
#     
#     the empty string is particularly easy to hit, because .comb of ""
#     is the empty set, which trivially satisfies the argument constraint.
#     
#     check for canonicity yourself:
#       canonical(""      ) = False
#       canonical("c"     ) = True
#       canonical("cccb"  ) = False
#       canonical("b"     ) = True
#       canonical("bd"    ) = True
