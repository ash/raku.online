#!/usr/bin/env rakupp
# DateTime::Format — Month names in your language
# https://raku.online/modules/datetime-format/#month-names-in-your-language
#
# Install what it needs, then run it:
#     rakupp install DateTime::Format
#     rakupp 02-localized.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Format;
use DateTime::Format::Lang::FR;

set-datetime-format-lang('fr');
say strftime('%A %d %B %Y', DateTime.new('2026-08-28T00:00:00Z'));

# Output:
#     vendredi 28 août 2026
