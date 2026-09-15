#!/usr/bin/env rakupp
# Cro::Core — Media types, including the suffix
# https://raku.online/modules/cro-core/#media-types-including-the-suffix
#
# Install what it needs, then run it:
#     rakupp install Cro::Core
#     rakupp 03-mediatype.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Cro::MediaType;

for 'text/plain; charset=UTF-8',
    'application/vnd.api+json',
    'image/svg+xml',
    'application/x-www-form-urlencoded' -> $s {
    my $m = Cro::MediaType.parse($s);
    say $s;
    say '   type            ', $m.type;
    say '   tree            ', $m.tree       || '(none)';
    say '   subtype-name    ', $m.subtype-name;
    say '   suffix          ', $m.suffix     || '(none)';
    say '   subtype         ', $m.subtype;
    say '   type-and-subtype ', $m.type-and-subtype;
    say '   parameters      ', $m.parameters.map({ .key ~ '=' ~ .value }).join(', ') || '(none)';
}

# Output:
#     text/plain; charset=UTF-8
#        type            text
#        tree            (none)
#        subtype-name    plain
#        suffix          (none)
#        subtype         plain
#        type-and-subtype text/plain
#        parameters      charset=UTF-8
#     application/vnd.api+json
#        type            application
#        tree            vnd
#        subtype-name    api
#        suffix          json
#        subtype         vnd.api+json
#        type-and-subtype application/vnd.api+json
#        parameters      (none)
#     image/svg+xml
#        type            image
#        tree            (none)
#        subtype-name    svg
#        suffix          xml
#        subtype         svg+xml
#        type-and-subtype image/svg+xml
#        parameters      (none)
#     application/x-www-form-urlencoded
#        type            application
#        tree            (none)
#        subtype-name    x-www-form-urlencoded
#        suffix          (none)
#        subtype         x-www-form-urlencoded
#        type-and-subtype application/x-www-form-urlencoded
#        parameters      (none)
