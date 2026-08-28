#!/usr/bin/env rakupp
# Method::Also — It composes with multis and coercions
# https://raku.online/modules/method-also/#it-composes-with-multis-and-coercions
#
# Install what it needs, then run it:
#     rakupp install Method::Also
#     rakupp 02-multi-and-gist.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Method::Also;

class Temperature {
    has $.celsius;
    multi method in(Str $unit where 'C') is also<as> { $!celsius }
    multi method in(Str $unit where 'F') { $!celsius * 9/5 + 32 }
    method gist() is also<Str> { "{$!celsius}°C" }
}

my $t = Temperature.new(:celsius(21));
say $t.in('F');
say $t.as('C');
say ~$t;

# Output:
#     69.8
#     21
#     21°C
