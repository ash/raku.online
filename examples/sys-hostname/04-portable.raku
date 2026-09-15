#!/usr/bin/env rakupp
# Sys::Hostname — Where the two engines differ
# https://raku.online/modules/sys-hostname/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Sys::Hostname
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sys::Hostname;

# if you want the guarantee the signature does not give you
sub host(--> Str:D) { hostname() // die 'no hostname available' }

my $h = host();
say 'host() returns a defined Str : ', ($h ~~ Str:D);
say 'and it is the same value     : ', $h eq $*KERNEL.hostname;
say '';
say 'the distribution is three lines long and has no dependencies, so';
say 'there is nothing else to know about it — which is the point.';

# Output:
#     host() returns a defined Str : True
#     and it is the same value     : True
#     
#     the distribution is three lines long and has no dependencies, so
#     there is nothing else to know about it — which is the point.
