#!/usr/bin/env rakupp
# License::SPDX — Deprecated identifiers
# https://raku.online/modules/license-spdx/#deprecated-identifiers
#
# Install what it needs, then run it:
#     rakupp install License::SPDX
#     rakupp 02-deprecated.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use License::SPDX;

my $spdx = License::SPDX.new;

for <GPL-3.0 GPL-3.0-only LGPL-2.1 LGPL-2.1-only> -> $id {
    my $l = $spdx.get-license($id);
    say sprintf('%-16s deprecated=%-5s  name=%s', $id, $l.is-deprecated-license, $l.name);
}
say '';
say 'deprecated ids still resolvable : ',
    $spdx.licenses.grep(*.is-deprecated-license).elems, ' of ', $spdx.licenses.elems;

# Output:
#     GPL-3.0          deprecated=True   name=GNU General Public License v3.0 only
#     GPL-3.0-only     deprecated=False  name=GNU General Public License v3.0 only
#     LGPL-2.1         deprecated=True   name=GNU Lesser General Public License v2.1 only
#     LGPL-2.1-only    deprecated=False  name=GNU Lesser General Public License v2.1 only
#     
#     deprecated ids still resolvable : 32 of 727
