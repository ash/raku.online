#!/usr/bin/env rakupp
# JSON::Tiny — Numbers come back typed
# https://raku.online/modules/json-tiny/#numbers-come-back-typed
#
# Install what it needs, then run it:
#     rakupp install JSON::Tiny
#     rakupp 03-invalid-input.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Tiny;

say from-json('{"unclosed": [1, 2');
CATCH {
    when X::JSON::Tiny::Invalid { say "not JSON: {.source.chars} characters rejected" }
}

# Output:
#     not JSON: 18 characters rejected
