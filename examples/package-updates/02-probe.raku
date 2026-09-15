#!/usr/bin/env rakupp
# Package::Updates — How it decides
# https://raku.online/modules/package-updates/#how-it-decides
#
# Install what it needs, then run it:
#     rakupp install Package::Updates
#     rakupp 02-probe.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Package::Updates;

say 'the module probes for a marker directory:';
for </etc/apt /etc/pacman.d /etc/yum> -> $p {
    say sprintf('  %-16s exists : %s', $p, $p.IO.e);
}
say '  win32 kernel     : ', $*KERNEL.name eq 'win32';
say '';
say 'if none of the four matches, it returns an empty hash.';

# Output:
#     the module probes for a marker directory:
#       /etc/apt         exists : False
#       /etc/pacman.d    exists : False
#       /etc/yum         exists : False
#       win32 kernel     : False
#     
#     if none of the four matches, it returns an empty hash.
