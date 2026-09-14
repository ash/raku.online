#!/usr/bin/env rakupp
# META6 — Reading one
# https://raku.online/modules/meta6/#reading-one
#
# Install what it needs, then run it:
#     rakupp install META6
#     rakupp 01-read.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use META6;

my $json = q:to/JSON/;
    { "name": "Widget::Tools", "version": "1.2.3", "auth": "zef:someone",
      "description": "Tools for widgets", "raku": "6.d", "license": "Artistic-2.0",
      "authors": ["A. Person"],
      "provides": { "Widget::Tools": "lib/Widget/Tools.rakumod" },
      "depends": ["JSON::Fast", "URI:ver<0.3+>"], "test-depends": ["Test::META"],
      "source-url": "https://example.org/widget-tools.git" }
    JSON

my $m = META6.new(:$json);
say $m.name, ' ', $m.version, ' (', $m.version.^name, ')';
say $m.raku-version, ' ', $m.license;
say $m.depends.join(', ');
say $m.test-depends.join(', ');
say $m.provides.keys.join(', ');
say $m<auth>;
say META6.new(json => $m.to-json).name;

# Output:
#     Widget::Tools v1.2.3 (Version)
#     v6.d Artistic-2.0
#     JSON::Fast, URI:ver<0.3+>
#     Test::META
#     Widget::Tools
#     zef:someone
#     Widget::Tools
