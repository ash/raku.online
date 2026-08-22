#!/usr/bin/env rakupp
# JSON::Fast — When the text is wrong
# https://raku.online/ecosystem/json-fast/#when-the-text-is-wrong
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 08-errors.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

my $text = '{"a":1} trailing junk';
my $data = try from-json($text);
with $! {
    say .^name;
    say .rest-position;
    say $text.substr(.rest-position).trim;
}

# Output:
#     X::JSON::AdditionalContent
#     8
#     trailing junk
