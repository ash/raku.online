#!/usr/bin/env rakupp
# Brazilian::FederalDocuments — Where the two engines differ
# https://raku.online/modules/brazilian-federaldocuments/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Brazilian::FederalDocuments
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Brazilian::FederalDocuments;

# the portable shape: validate the string yourself, then construct
sub cpf-valid(Str $raw) {
    my $digits = $raw.subst(/<-[0..9]>/, '', :g);
    return False unless $digits.chars <= 11;
    return False if $digits.comb.unique.elems == 1;   # the blacklist the module lacks
    FederalDocuments::CPF.new(number => $digits).is-valid
}

for '000.000.001-91', '0000000019a', '11111111111', '' -> $raw {
    say sprintf('  %-18s -> %s', $raw.raku, cpf-valid($raw));
}
say '';
say 'without that guard, "0000000019a" throws X::Str::Numeric on Raku++';
say 'and returns False on Rakudo, and `FederalDocuments::CPF(number => 191)`';
say 'builds an instance on Raku++ and raises "No such method CALL-ME" on';
say 'Rakudo. Always write .new, and always sanitise first.';

# Output:
#       "000.000.001-91"   -> True
#       "0000000019a"      -> False
#       "11111111111"      -> False
#       ""                 -> True
#     
#     without that guard, "0000000019a" throws X::Str::Numeric on Raku++
#     and returns False on Rakudo, and `FederalDocuments::CPF(number => 191)`
#     builds an instance on Raku++ and raises "No such method CALL-ME" on
#     Rakudo. Always write .new, and always sanitise first.
