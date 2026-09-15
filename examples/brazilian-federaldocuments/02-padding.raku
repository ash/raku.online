#!/usr/bin/env rakupp
# Brazilian::FederalDocuments — The padding
# https://raku.online/modules/brazilian-federaldocuments/#the-padding
#
# Install what it needs, then run it:
#     rakupp install Brazilian::FederalDocuments
#     rakupp 02-padding.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Brazilian::FederalDocuments;

for 0, '', 191, '000.000.001-91' -> $n {
    my $cpf = FederalDocuments::CPF.new(number => $n);
    say sprintf('  %-18s -> is-valid %-5s   .number reads back as %s',
                $n.raku, $cpf.is-valid, $cpf.number.raku);
}
say '';
say 'an empty string is a valid CPF. A formatted one is 14 characters,';
say 'over the 11-character ceiling, so it is rejected as invalid rather';
say 'than cleaned — strip the punctuation yourself.';
say '';
say 'and .number is stored verbatim, so the accessor and the value the';
say 'validator actually checked disagree.';

# Output:
#       0                  -> is-valid True    .number reads back as 0
#       ""                 -> is-valid True    .number reads back as ""
#       191                -> is-valid True    .number reads back as 191
#       "000.000.001-91"   -> is-valid False   .number reads back as "000.000.001-91"
#     
#     an empty string is a valid CPF. A formatted one is 14 characters,
#     over the 11-character ceiling, so it is rejected as invalid rather
#     than cleaned — strip the punctuation yourself.
#     
#     and .number is stored verbatim, so the accessor and the value the
#     validator actually checked disagree.
