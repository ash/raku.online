#!/usr/bin/env rakupp
# Sys::Hostname — The one thing to know
# https://raku.online/modules/sys-hostname/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Sys::Hostname
#     rakupp 03-typeobject.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sys::Hostname;

say 'Kernel.hostname on the type object works : ',
    (try Kernel.hostname).defined;
say '';
say '  Kernel.name / .arch / .bits on the type object -> engine-dependent';
say '';
say 'under Rakudo, name, arch and bits all die on a type object with';
say 'X::AdHoc while hostname succeeds; under Raku++ all four work, so the';
say 'difference is invisible there.';
say '';
say 'anyone "simplifying" this module by writing Kernel.name beside';
say 'Kernel.hostname gets a crash on Rakudo only. Use $*KERNEL for';
say 'everything except the one method this module already wraps:';
say '  $*KERNEL.name works everywhere : ', ($*KERNEL.name.chars > 0);

# Output:
#     Kernel.hostname on the type object works : True
#     
#       Kernel.name / .arch / .bits on the type object -> engine-dependent
#     
#     under Rakudo, name, arch and bits all die on a type object with
#     X::AdHoc while hostname succeeds; under Raku++ all four work, so the
#     difference is invisible there.
#     
#     anyone "simplifying" this module by writing Kernel.name beside
#     Kernel.hostname gets a crash on Rakudo only. Use $*KERNEL for
#     everything except the one method this module already wraps:
#       $*KERNEL.name works everywhere : True
