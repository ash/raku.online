#!/usr/bin/env rakupp
# JSON::Marshal — Objects into documents
# https://raku.online/modules/json-marshal/#objects-into-documents
#
# Install what it needs, then run it:
#     rakupp install JSON::Marshal
#     rakupp 01-into-json.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Marshal;

class Point { has Int $.x; has Int $.y }
class Box {
    has Str   $.label;
    has Point $.corner;
    has Point @.points;
    has       %.meta;
}

my $box = Box.new(
    label  => 'b1',
    corner => Point.new(x => 1, y => 2),
    points => (Point.new(x => 3, y => 4),),
    meta   => { z => 9 },
);
say marshal($box, :!pretty, :sorted-keys);

say marshal(42, :!pretty);
say marshal('hi', :!pretty);
say marshal([1, 2, 3], :!pretty);
say marshal(Int, :!pretty);

# Output:
#     {"corner":{"x":1,"y":2},"label":"b1","meta":{"z":9},"points":[{"x":3,"y":4}]}
#     42
#     "hi"
#     [1,2,3]
#     null
