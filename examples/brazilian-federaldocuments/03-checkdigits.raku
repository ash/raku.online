#!/usr/bin/env rakupp
# Brazilian::FederalDocuments — The one thing to know
# https://raku.online/modules/brazilian-federaldocuments/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Brazilian::FederalDocuments
#     rakupp 03-checkdigits.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Brazilian::FederalDocuments;

# the published rule: r = sum % 11; digit = r < 2 ?? 0 !! 11 - r
sub cpf-digits(@base) {
    my @d = @base;
    for 0, 1 -> $round {
        my $w = 10 + $round;
        my $sum = [+] @d.kv.map(-> $i, $v { $v * ($w - $i) });
        my $r = $sum % 11;
        @d.push($r < 2 ?? 0 !! 11 - $r);
    }
    @d.join
}

my $good = cpf-digits([1,2,3,4,5,6,7,8,9]);
say 'the published algorithm turns 123456789 into ', $good;
say '  the module says is-valid = ',
    FederalDocuments::CPF.new(number => $good).is-valid;
say '';
say 'the repdigits, which the real specification blacklists by name:';
for <00000000000 11111111111 55555555555 99999999999> -> $n {
    say sprintf('  %-14s -> %s', $n, FederalDocuments::CPF.new(number => $n).is-valid);
}
say '';
say 'the formula genuinely self-satisfies for those, which is exactly why';
say 'the specification carries an explicit blacklist. This module has none.';

# Output:
#     the published algorithm turns 123456789 into 12345678909
#       the module says is-valid = False
#     
#     the repdigits, which the real specification blacklists by name:
#       00000000000    -> True
#       11111111111    -> True
#       55555555555    -> True
#       99999999999    -> True
#     
#     the formula genuinely self-satisfies for those, which is exactly why
#     the specification carries an explicit blacklist. This module has none.
