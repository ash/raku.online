#!/usr/bin/env rakupp
# JSON::Native — Comments, and refusals in JSON::Fast's words
# https://raku.online/modules/json-native/#comments-and-refusals-in-jsonfasts-words
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 08-refusals.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

for '[1,', "[\"a\tb\"]", '[1] [2]' -> $doc {
    try from-json($doc);
    say $!.^name, ': ', $!.message.lines.head;
}

# Output:
#     X::AdHoc: at end of input: expected a json object
#     X::AdHoc: this kind of whitespace is not allowed in a string: '"\t"' near 6
#     X::JSON::Native::AdditionalContent: JSON Input contained additional text after the document (parsed 3 chars, next non-whitespace lives at 4)
