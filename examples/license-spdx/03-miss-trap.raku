#!/usr/bin/env rakupp
# License::SPDX — The one thing to know
# https://raku.online/modules/license-spdx/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install License::SPDX
#     rakupp 03-miss-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use License::SPDX;

my $spdx = License::SPDX.new;

for 'Definitely-Not-A-Licence-1.0', 'mit', 'MIT' -> $id {
    my $l = $spdx.get-license($id);
    say "lookup '$id'";
    say '  type    : ', $l.^name;
    say '  defined : ', $l.defined;
    say '  Bool    : ', ?$l;
    say '  isa License : ', $l ~~ License::SPDX::License;
    say '  .license-id : ', (try $l.license-id) // 'threw';
}

# Output:
#     lookup 'Definitely-Not-A-Licence-1.0'
#       type    : License::SPDX::License
#       defined : False
#       Bool    : False
#       isa License : True
#       .license-id : threw
#     lookup 'mit'
#       type    : License::SPDX::License
#       defined : False
#       Bool    : False
#       isa License : True
#       .license-id : threw
#     lookup 'MIT'
#       type    : License::SPDX::License
#       defined : True
#       Bool    : True
#       isa License : True
#       .license-id : MIT
