#!/usr/bin/env rakupp
# Highlight::Terminal — The fallback
# https://raku.online/modules/highlight-terminal/#the-fallback
#
# Install what it needs, then run it:
#     rakupp install Highlight::Terminal
#     rakupp 02-fallback.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Highlight::Terminal;

class HL does Highlight::Terminal {}
my $h = HL.new;

for 'version', 'arrow', 'arrow-one', 'arrow-one-deeper', 'block-xxx', 'no-such' -> $t {
    say sprintf('from-map(%-20s) = %-8s   table entry: %s',
        "'$t'", $h.from-map($t).raku,
        $h.map{$t}:exists ?? $h.map{$t}.raku !! 'absent');
}

# Output:
#     from-map('version'           ) = "33;4"     table entry: "33;4"
#     from-map('arrow'             ) = "35;1"     table entry: "35;1"
#     from-map('arrow-one'         ) = "35;1"     table entry: Str
#     from-map('arrow-one-deeper'  ) = "35;1"     table entry: absent
#     from-map('block-xxx'         ) = "35"       table entry: Str
#     from-map('no-such'           ) = Nil        table entry: absent
