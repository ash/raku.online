#!/usr/bin/env rakupp
# Fortune — Drawing a fortune
# https://raku.online/modules/fortune/#drawing-a-fortune
#
# Install what it needs, then run it:
#     rakupp install Fortune
#     rakupp 01-fortune.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Fortune;

my $db = $Fortune::DATABASE;
say 'the bundled database exists : ', $db.e;
say 'records in it               : ', Fortune.new($db.absolute).fortune.elems;
say '';
my @picks = (^25).map({ fortune() });
say '25 draws:';
say '  every result is a Str or Nil : ', ?all(@picks.map({ $_ ~~ Str|Nil }));
say '  every result is in the store : ',
    ?all(@picks.grep(*.defined).map({ $_ (elem) Fortune.new($db.absolute).fortune.Set }));
say '';
say ':short  — all 160 characters or fewer : ',
    ?all((^25).map({ fortune(:short) }).grep(*.defined).map({ .chars <= 160 }));
say ':long   — all longer than 160         : ',
    ?all((^25).map({ fortune(:long) }).grep(*.defined).map({ .chars > 160 }));

# Output:
#     the bundled database exists : True
#     records in it               : 16942
#     
#     25 draws:
#       every result is a Str or Nil : True
#       every result is in the store : True
#     
#     :short  — all 160 characters or fewer : True
#     :long   — all longer than 160         : True
