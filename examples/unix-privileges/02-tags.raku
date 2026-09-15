#!/usr/bin/env rakupp
# UNIX::Privileges — The import tags
# https://raku.online/modules/unix-privileges/#the-import-tags
#
# Install what it needs, then run it:
#     rakupp install UNIX::Privileges
#     rakupp 02-tags.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UNIX::Privileges;

say 'a plain `use` imports nothing at all.';
say 'the full name still works:';
say '  UNIX::Privileges::userinfo("root").uid = ',
    UNIX::Privileges::userinfo('root').uid;
say '';
say 'the three tags:';
say '  :USER  gives userinfo and groupinfo';
say '  :CH    gives chown and chroot';
say '  :ALL   gives those four plus drop';

# Output:
#     a plain `use` imports nothing at all.
#     the full name still works:
#       UNIX::Privileges::userinfo("root").uid = 0
#     
#     the three tags:
#       :USER  gives userinfo and groupinfo
#       :CH    gives chown and chroot
#       :ALL   gives those four plus drop
