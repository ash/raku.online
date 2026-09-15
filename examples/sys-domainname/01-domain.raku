#!/usr/bin/env rakupp
# Sys::Domainname — Asking for the domain
# https://raku.online/modules/sys-domainname/#asking-for-the-domain
#
# Install what it needs, then run it:
#     rakupp install Sys::Domainname
#     rakupp 01-domain.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sys::Domainname;

my $d = domainname();
say 'returns a Str        : ', $d ~~ Str;
say 'is defined           : ', $d.defined;
say 'has no trailing newline : ', !$d.contains("\n");

# Output:
#     returns a Str        : True
#     is defined           : True
#     has no trailing newline : True
