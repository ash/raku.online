#!/usr/bin/env rakupp
# Sys::Hostname — Using it
# https://raku.online/modules/sys-hostname/#using-it
#
# Install what it needs, then run it:
#     rakupp install Sys::Hostname
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sys::Hostname;

my $h = hostname();
say 'type            : ', $h.WHAT.^name;
say 'defined         : ', $h.defined;
say 'non-empty       : ', $h.chars > 0;
say 'no whitespace   : ', !($h ~~ /\s/);
say 'hostname-shaped : ', so $h ~~ /^ <[\w.-]>+ $/;
say '';
say 'stable across two calls      : ', hostname() eq hostname();
say 'same as $*KERNEL.hostname    : ', $h eq $*KERNEL.hostname;
say '';
say 'nothing above prints the machine`s name — every line is a property';
say 'that holds wherever you run it.';

# Output:
#     type            : Str
#     defined         : True
#     non-empty       : True
#     no whitespace   : True
#     hostname-shaped : True
#     
#     stable across two calls      : True
#     same as $*KERNEL.hostname    : True
#     
#     nothing above prints the machine`s name — every line is a property
#     that holds wherever you run it.
