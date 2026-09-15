#!/usr/bin/env rakupp
# JSON::JWT — The one thing to know
# https://raku.online/modules/json-jwt/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install JSON::JWT
#     rakupp 02-bloat.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::JWT;
use MIME::Base64;

my $token = JSON::JWT.encode({ sub => 'ada' }, :alg<HS256>, :secret<s3cret>);
my @parts = $token.split('.');

say MIME::Base64.decode-str(@parts[1].trans('-_' => '+/')).raku;
say 'payload segment: ', @parts[1].chars, ' characters';
say 'compact JSON would be: ', '{"sub":"ada"}'.chars, ' characters of input';

# Output:
#     "\{\n  \"sub\": \"ada\"\n}"
#     payload segment: 24 characters
#     compact JSON would be: 13 characters of input
