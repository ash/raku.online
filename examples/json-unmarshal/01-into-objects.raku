#!/usr/bin/env rakupp
# JSON::Unmarshal — Documents into objects
# https://raku.online/modules/json-unmarshal/#documents-into-objects
#
# Install what it needs, then run it:
#     rakupp install JSON::Unmarshal
#     rakupp 01-into-objects.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Unmarshal;

class Point { has Int $.x; has Int $.y }
class Box {
    has Str    $.label;
    has Point  $.corner;
    has Point  @.points;
    has Bool   $.active;
}

my $box = unmarshal(
    '{"label":"b1","corner":{"x":1,"y":2},"points":[{"x":3,"y":4}],"active":true}',
    Box);
say $box.label, ' ', $box.active;
say $box.corner.^name, ' at ', $box.corner.x, ',', $box.corner.y;
say $box.points.elems, ' ', $box.points[0].^name;

say unmarshal('[1,2,3]', Array[Int]).raku;
say unmarshal({ x => 5, y => 6 }, Point).x;

# Output:
#     b1 True
#     Point at 1,2
#     1 Point
#     (1, 2, 3)
#     5
