#!/usr/bin/env rakupp
# License::SPDX — Looking a licence up
# https://raku.online/modules/license-spdx/#looking-a-licence-up
#
# Install what it needs, then run it:
#     rakupp install License::SPDX
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use License::SPDX;

my $spdx = License::SPDX.new;

say 'list version : ', $spdx.license-list-version;
say 'release date : ', $spdx.release-date;
say 'licences     : ', $spdx.license-ids.elems;
say '';

for <MIT Apache-2.0 Artistic-2.0> -> $id {
    my $l = $spdx.get-license($id);
    say $l.license-id;
    say '  name       : ', $l.name;
    say '  osi        : ', $l.is-osi-approved;
    say '  fsf-libre  : ', $l.is-fsf-libre;
    say '  deprecated : ', $l.is-deprecated-license;
    say '  reference  : ', $l.reference;
}

# Output:
#     list version : 3.28.0
#     release date : 2026-02-20
#     licences     : 727
#     
#     MIT
#       name       : MIT License
#       osi        : True
#       fsf-libre  : True
#       deprecated : False
#       reference  : https://spdx.org/licenses/MIT.html
#     Apache-2.0
#       name       : Apache License 2.0
#       osi        : True
#       fsf-libre  : True
#       deprecated : False
#       reference  : https://spdx.org/licenses/Apache-2.0.html
#     Artistic-2.0
#       name       : Artistic License 2.0
#       osi        : True
#       fsf-libre  : True
#       deprecated : False
#       reference  : https://spdx.org/licenses/Artistic-2.0.html
