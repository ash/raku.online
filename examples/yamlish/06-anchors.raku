#!/usr/bin/env rakupp
# YAMLish — What it does not do
# https://raku.online/modules/yamlish/#what-it-does-not-do
#
# Install what it needs, then run it:
#     rakupp install YAMLish
#     rakupp 06-anchors.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use YAMLish;

my %d = load-yaml(q:to/YAML/);
    defaults: &base
      retries: 3
      timeout: 30
    staging:
      <<: *base
      timeout: 5
    YAML

say %d<staging><retries>;
say %d<staging><timeout>;

# Output:
#     (Any)
#     5
