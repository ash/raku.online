#!/usr/bin/env rakupp
# YAMLish — More than one document
# https://raku.online/modules/yamlish/#more-than-one-document
#
# Install what it needs, then run it:
#     rakupp install YAMLish
#     rakupp 03-stream.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use YAMLish;

my $stream = q:to/YAML/;
    ---
    doc: 1
    ---
    doc: 2
    YAML

my @docs = load-yamls($stream);
say @docs.elems;
say @docs.map(*.<doc>).join(',');

# Output:
#     2
#     1,2
