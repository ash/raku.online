#!/usr/bin/env rakupp
# URI — What it is for
# https://raku.online/modules/uri/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

my $u = URI.new('https://raku.land/zef:timo/JSON::Fast?ver=0.20.1#docs');
say $u.scheme;
say $u.host;
say $u.path;
say $u.query;
say $u.fragment;

# Output:
#     https
#     raku.land
#     /zef%3Atimo/JSON%3A%3AFast
#     ver=0.20.1
#     docs
