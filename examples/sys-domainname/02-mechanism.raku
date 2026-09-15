#!/usr/bin/env rakupp
# Sys::Domainname — How it works
# https://raku.online/modules/sys-domainname/#how-it-works
#
# Install what it needs, then run it:
#     rakupp install Sys::Domainname
#     rakupp 02-mechanism.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sys::Domainname;

say 'this is not a syscall. the implementation is four lines:';
say '  run `hostname -f`, chomp it, delete up to and including the first dot.';
say '';
say 'so the answer depends on what `hostname` is on your PATH,';
say 'and on whether the name it prints contains a dot at all.';
say '';
say 'the sub is declared `sub ... is export` at file scope,';
say 'so it is importable but never qualifiable:';
say '  Sys::Domainname::domainname is reachable : ',
    (try &Sys::Domainname::domainname.defined).defined;

# Output:
#     this is not a syscall. the implementation is four lines:
#       run `hostname -f`, chomp it, delete up to and including the first dot.
#     
#     so the answer depends on what `hostname` is on your PATH,
#     and on whether the name it prints contains a dot at all.
#     
#     the sub is declared `sub ... is export` at file scope,
#     so it is importable but never qualifiable:
#       Sys::Domainname::domainname is reachable : True
