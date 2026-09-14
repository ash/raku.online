#!/usr/bin/env rakupp
# OO::Monitors — The one thing to know
# https://raku.online/modules/oo-monitors/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install OO::Monitors
#     rakupp 03-escapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use OO::Monitors;

monitor Registry {
    has %!items;
    method add(Str $k, $v) { %!items{$k} = $v; self }
    method items { %!items }         # hands the container out
    method copy  { %!items.clone }   # hands a snapshot out
    method count { %!items.elems }
}

my $r = Registry.new;
$r.add('a', 1);
$r.items<b> = 2;                      # written from outside, unlocked
say $r.count;
my %snapshot = $r.copy;
%snapshot<c> = 3;                     # written into the copy
say $r.count;

# Output:
#     2
#     2
