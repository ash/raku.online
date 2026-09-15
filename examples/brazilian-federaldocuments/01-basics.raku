#!/usr/bin/env rakupp
# Brazilian::FederalDocuments — Using it
# https://raku.online/modules/brazilian-federaldocuments/#using-it
#
# Install what it needs, then run it:
#     rakupp install Brazilian::FederalDocuments
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Brazilian::FederalDocuments;

for '12345678909', '00000000000', '191' -> $n {
    my $cpf = FederalDocuments::CPF.new(number => $n);
    say sprintf('  CPF  %-14s -> %s', $n.raku, $cpf.is-valid);
}
say '';
say 'note the class name: `use Brazilian::FederalDocuments` installs NO';
say 'symbol of that name. What you get is FederalDocuments::CPF and';
say 'FederalDocuments::CNPJ, so the first line of your program does not';
say 'match the one above it.';
say '';
say 'the role behind them:';
say '  is-valid : caches the answer computed at construction';
say '  verify   : public and re-runnable — but $.number cannot change,';
say '             so it can only ever produce the same answer.';

# Output:
#       CPF  "12345678909"  -> False
#       CPF  "00000000000"  -> True
#       CPF  "191"          -> True
#     
#     note the class name: `use Brazilian::FederalDocuments` installs NO
#     symbol of that name. What you get is FederalDocuments::CPF and
#     FederalDocuments::CNPJ, so the first line of your program does not
#     match the one above it.
#     
#     the role behind them:
#       is-valid : caches the answer computed at construction
#       verify   : public and re-runnable — but $.number cannot change,
#                  so it can only ever produce the same answer.
