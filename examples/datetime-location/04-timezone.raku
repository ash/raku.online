#!/usr/bin/env rakupp
# DateTime::Location — Validation only fires for `Num`
# https://raku.online/modules/datetime-location/#validation-only-fires-for-num
#
# Install what it needs, then run it:
#     rakupp install DateTime::Location
#     rakupp 04-timezone.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Location;

sub build($tz) {
    my $r = try DateTime::Location.new(
        id => 'X', name => 'X', lat => 0e0, lon => 0e0, timezone => $tz);
    $! ?? 'refused' !! 'accepted: ' ~ $r.timezone.raku
}

for -5e0, 999e0, -5, 999, -5.5, 99999.0, 'est', 'zz' -> $tz {
    say sprintf('%-10s %-6s %s', $tz.raku, $tz.WHAT.^name, build($tz));
}
say '';
say 'the range test is `$tz ~~ Num`, so the natural :timezone(-5) and';
say ':timezone(-5.5) skip every check. EVERY three-character code is';
say 'rejected, and the rejection talks about hours rather than codes.';
say '';
say 'latitude and longitude are not checked at all:';
my $wild = DateTime::Location.new(
    id => 'X', name => 'X', lat => 1000, lon => -9999, timezone => 0e0);
say '  lat => 1000, lon => -9999 -> ', $wild.lat, ', ', $wild.lon;

# Output:
#     -5e0       Num    accepted: -5e0
#     999e0      Num    refused
#     -5         Int    accepted: -5
#     999        Int    accepted: 999
#     -5.5       Rat    accepted: -5.5
#     99999.0    Rat    accepted: 99999.0
#     "est"      Str    refused
#     "zz"       Str    refused
#     
#     the range test is `$tz ~~ Num`, so the natural :timezone(-5) and
#     :timezone(-5.5) skip every check. EVERY three-character code is
#     rejected, and the rejection talks about hours rather than codes.
#     
#     latitude and longitude are not checked at all:
#       lat => 1000, lon => -9999 -> 1000, -9999
