#!/usr/bin/env rakupp
# Digest::HMAC — Verifying a webhook
# https://raku.online/modules/digest-hmac/#verifying-a-webhook
#
# Install what it needs, then run it:
#     rakupp install Digest::HMAC
#     rakupp 02-webhook-signature.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::HMAC;
use Digest::SHA2;

my $secret  = 'webhook-secret';
my $payload = '{"action":"opened","number":1}';

my $expected = 'sha256=' ~ hmac-hex($secret, $payload, &sha256);
say $expected;

my $header = 'sha256=b41572a08af38c59c7736ef55ac89a408ce86f4ac8474b077a7a8962ab87bd15';
say $header eq $expected;

# Output:
#     sha256=b41572a08af38c59c7736ef55ac89a408ce86f4ac8474b077a7a8962ab87bd15
#     True
