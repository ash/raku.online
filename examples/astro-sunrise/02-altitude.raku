#!/usr/bin/env rakupp
# Astro::Sunrise — Choosing an altitude
# https://raku.online/modules/astro-sunrise/#choosing-an-altitude
#
# Install what it needs, then run it:
#     rakupp install Astro::Sunrise
#     rakupp 02-altitude.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Astro::Sunrise;

my $date = Date.new(2024, 6, 21);

for -0.833, -6, -12, -18 -> $alt {
    my ($r, $s) = sunrise($date, -71.0589, 42.3601, -5, $alt);
    say sprintf('altitude %6.3f -> rise=%s set=%s', $alt, $r, $s);
}
say '';
say '-0.833 is the default: the sun\'s upper limb at the horizon,';
say 'allowing for refraction. -6, -12 and -18 are civil, nautical';
say 'and astronomical twilight.';

# Output:
#     altitude -0.833 -> rise=04:06 set=19:26
#     altitude -6.000 -> rise=03:31 set=20:01
#     altitude -12.000 -> rise=02:46 set=20:47
#     altitude -18.000 -> rise=01:50 set=21:42
#     
#     -0.833 is the default: the sun's upper limb at the horizon,
#     allowing for refraction. -6, -12 and -18 are civil, nautical
#     and astronomical twilight.
