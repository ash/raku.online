#!/usr/bin/env rakupp
# P5getservbyname — Looking a service up
# https://raku.online/modules/p5getservbyname/#looking-a-service-up
#
# Install what it needs, then run it:
#     rakupp install P5getservbyname
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getservbyname;

for <ssh http https smtp domain> -> $name {
    my @r = getservbyname($name, 'tcp');
    say sprintf('%-8s/tcp  fields=%d  name=%-8s port=%-5d proto=%s',
        $name, @r.elems, @r[0], @r[2], @r[3]);
}

# Output:
#     ssh     /tcp  fields=4  name=ssh      port=22    proto=tcp
#     http    /tcp  fields=4  name=http     port=80    proto=tcp
#     https   /tcp  fields=4  name=https    port=443   proto=tcp
#     smtp    /tcp  fields=4  name=smtp     port=25    proto=tcp
#     domain  /tcp  fields=4  name=domain   port=53    proto=tcp
