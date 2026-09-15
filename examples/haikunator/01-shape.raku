#!/usr/bin/env rakupp
# Haikunator — Minting a name
# https://raku.online/modules/haikunator/#minting-a-name
#
# Install what it needs, then run it:
#     rakupp install Haikunator
#     rakupp 01-shape.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Haikunator;

my @names = (^300).map({ haikunate() });

say 'all match adjective-noun-NNNN : ',
    ?all(@names.map({ so $_ ~~ /^ <[a..z]>+ '-' <[a..z]>+ '-' \d ** 4 $/ }));
say 'distinct adjectives seen      : ', @names.map(*.split('-')[0]).unique.elems > 60;
say 'distinct nouns seen           : ', @names.map(*.split('-')[1]).unique.elems > 60;
say 'token is always four digits   : ',
    ?all(@names.map({ .split('-')[2] ~~ /^ \d ** 4 $/ }));

# Output:
#     all match adjective-noun-NNNN : True
#     distinct adjectives seen      : True
#     distinct nouns seen           : True
#     token is always four digits   : True
