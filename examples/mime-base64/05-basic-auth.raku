#!/usr/bin/env rakupp
# MIME::Base64 — The header everybody writes
# https://raku.online/modules/mime-base64/#the-header-everybody-writes
#
# Install what it needs, then run it:
#     rakupp install MIME::Base64
#     rakupp 05-basic-auth.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::Base64;

my ($user, $pass) = 'ash', 's3cr3t';
my $header = 'Basic ' ~ MIME::Base64.encode-str("$user:$pass", :oneline);
say $header;
say MIME::Base64.decode-str($header.substr(6)).split(':').head;

# Output:
#     Basic YXNoOnMzY3IzdA==
#     ash
