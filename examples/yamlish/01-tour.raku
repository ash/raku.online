#!/usr/bin/env rakupp
# YAMLish — What it is for
# https://raku.online/modules/yamlish/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install YAMLish
#     rakupp 01-tour.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use YAMLish;

my $yaml = q:to/YAML/;
    name: raku
    version: 6.d
    tags:
      - fast
      - fun
    limits:
      depth: 3
      strict: true
    YAML

my %d = load-yaml($yaml);
say %d<name>;
say %d<tags>.join(', ');
say %d<limits><depth>.^name, ' ', %d<limits><depth>;
say %d<limits><strict>.^name;

# Output:
#     raku
#     fast, fun
#     Int 3
#     Bool
