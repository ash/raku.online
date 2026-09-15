#!/usr/bin/env rakupp
# QueryOS — Asking about the host
# https://raku.online/modules/queryos/#asking-about-the-host
#
# Install what it needs, then run it:
#     rakupp install QueryOS
#     rakupp 01-os.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use QueryOS;

my $os = OS.new;

say 'class                : ', $os.^name;
say 'name is a Str        : ', $os.name ~~ Str;
say 'version is defined   : ', $os.version.defined;
say 'vnum is Numeric      : ', $os.vnum ~~ Numeric;
say '';
say 'exactly one predicate is true : ',
    ([+] $os.is-linux, $os.is-macos, $os.is-windows) == 1;
say 'all three return Bool         : ',
    ($os.is-linux ~~ Bool) && ($os.is-macos ~~ Bool) && ($os.is-windows ~~ Bool);

# Output:
#     class                : QueryOS::OS
#     name is a Str        : True
#     version is defined   : True
#     vnum is Numeric      : True
#     
#     exactly one predicate is true : True
#     all three return Bool         : True
