#!/usr/bin/env rakupp
# Astro::Sunrise — When the sun does not rise
# https://raku.online/modules/astro-sunrise/#when-the-sun-does-not-rise
#
# Install what it needs, then run it:
#     rakupp install Astro::Sunrise
#     rakupp 03-polar.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Astro::Sunrise;

# Longyearbyen, Svalbard, at midwinter
my $date = Date.new(2024, 12, 21);
my $r = try sunrise($date, 15.6, 78.22, 1);
say 'polar night : ', $! ?? "threw {$!.^name}: {$!.message.trim}" !! $r.raku;

# Output:
#     polar night : threw X::AdHoc: Sun never rises!!
