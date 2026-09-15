#!/usr/bin/env rakupp
# P5getpwnam — The one thing to know
# https://raku.online/modules/p5getpwnam/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5getpwnam
#     rakupp 03-arity-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getpwnam;

my @p = getpwuid(0);
say 'this kernel : ', $*KERNEL.name;
say 'record length here : ', @p.elems;
say '';
say 'on darwin and freebsd the list is 10 long:';
say '  ($name, $passwd, $uid, $gid, $quota, $comment, $gecos, $dir, $shell, $expire)';
say 'on linux and generic unix it is 9 — the trailing $expire is absent.';
say '';
say 'so the same destructuring assignment binds different things per platform.';
say '';
say 'and fields 4 and 5 are literals the module writes in:';
say '  field 4 (quota)   is always : ', @p[4].raku;
say '  field 5 (comment) is always : ', @p[5].raku;
say '  the real GECOS text is field 6, one later than a Perl one-liner';
say '  that says "the fifth element is the comment" would reach for.';

# Output:
#     this kernel : darwin
#     record length here : 10
#     
#     on darwin and freebsd the list is 10 long:
#       ($name, $passwd, $uid, $gid, $quota, $comment, $gecos, $dir, $shell, $expire)
#     on linux and generic unix it is 9 — the trailing $expire is absent.
#     
#     so the same destructuring assignment binds different things per platform.
#     
#     and fields 4 and 5 are literals the module writes in:
#       field 4 (quota)   is always : 0
#       field 5 (comment) is always : ""
#       the real GECOS text is field 6, one later than a Perl one-liner
#       that says "the fifth element is the comment" would reach for.
