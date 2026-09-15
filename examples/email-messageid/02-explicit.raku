#!/usr/bin/env rakupp
# Email::MessageID — Supplying your own halves
# https://raku.online/modules/email-messageid/#supplying-your-own-halves
#
# Install what it needs, then run it:
#     rakupp install Email::MessageID
#     rakupp 02-explicit.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Email::MessageID;

say 'bare    : ', message-id(:host<example.com>, :user<fixed-key>);
say ':header : ', message-id(:host<example.com>, :user<fixed-key>, :header);

# Output:
#     bare    : fixed-key@example.com
#     :header : Message-ID: <fixed-key@example.com>
