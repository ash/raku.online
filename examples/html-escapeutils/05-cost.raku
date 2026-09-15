#!/usr/bin/env rakupp
# HTML::EscapeUtils — Cost
# https://raku.online/modules/html-escapeutils/#cost
#
# Install what it needs, then run it:
#     rakupp install HTML::EscapeUtils
#     rakupp 05-cost.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::EscapeUtils;

say 'unescape re-slurps and re-parses the 64 KB resource on EVERY call,';
say 'so the cost tracks the number of CALLS, not the size of the input.';
say '';
my $many = '&amp;' x 200;
my $t0 = now;
unescape($many);
my $one-call = now - $t0;
$t0 = now;
unescape('&amp;') for ^200;
my $many-calls = now - $t0;
say '  one call over 200 entities : ', $one-call < 1 ?? 'under a second' !! 'slow';
say '  200 calls over one entity  : ',
    $many-calls > $one-call * 20 ?? 'more than 20x slower' !! 'comparable';
say '';
say 'batch your text into one call.';

# Output:
#     unescape re-slurps and re-parses the 64 KB resource on EVERY call,
#     so the cost tracks the number of CALLS, not the size of the input.
#     
#       one call over 200 entities : under a second
#       200 calls over one entity  : more than 20x slower
#     
#     batch your text into one call.
