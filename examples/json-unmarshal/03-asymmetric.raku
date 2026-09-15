#!/usr/bin/env rakupp
# JSON::Unmarshal — The one thing to know
# https://raku.online/modules/json-unmarshal/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install JSON::Unmarshal
#     rakupp 03-asymmetric.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Unmarshal;

class Record { has Str $.id; has Int $.count; has Bool $.on }

say (try unmarshal('{"count":"42"}', Record)) // 'string into Int: throws';

say unmarshal('{"id":12345}', Record).id.defined;
say unmarshal('{"id":12345}', Record, :die).id.defined;

say unmarshal('{"on":"false"}', Record).on;

# Output:
#     string into Int: throws
#     False
#     False
#     True
