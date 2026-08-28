#!/usr/bin/env rakupp
# YAMLish — What the scalars become
# https://raku.online/modules/yamlish/#what-the-scalars-become
#
# Install what it needs, then run it:
#     rakupp install YAMLish
#     rakupp 04-types.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use YAMLish;

my %d = load-yaml(q:to/YAML/);
    count: 42
    ratio: 0.5
    when: 2026-08-22
    nothing: ~
    text: "42"
    YAML

for <count ratio when nothing text> -> $k {
    say "$k: %d{$k}.^name() = %d{$k}.raku()";
}

# Output:
#     count: Int = 42
#     ratio: Rat = 0.5
#     when: Str = "2026-08-22"
#     nothing: Any = Any
#     text: Str = "42"
