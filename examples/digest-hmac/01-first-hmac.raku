#!/usr/bin/env rakupp
# Digest::HMAC — What it is for
# https://raku.online/modules/digest-hmac/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Digest::HMAC
#     rakupp 01-first-hmac.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::HMAC;
use Digest::SHA1;

say hmac-hex('key', 'The quick brown fox jumps over the lazy dog', &sha1);

# Output:
#     de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9
