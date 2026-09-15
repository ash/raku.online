#!/usr/bin/env rakupp
# Pod::Literate — Splitting a file
# https://raku.online/modules/pod-literate/#splitting-a-file
#
# Install what it needs, then run it:
#     rakupp install Pod::Literate
#     rakupp 01-split.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Pod::Literate;

my $source = q:to/END/;
unit module Literate;

=begin pod
This is the first documentation block.
It has two lines.
=end pod

sub first() is export { 1 }

=begin pod
A second block, after some code.
=end pod

sub second() is export { 2 }
END

my $m = Pod::Literate.parse($source);
say 'matched     : ', $m.defined;
say 'pod chunks  : ', $m<pod>.elems;
for $m<pod>.kv -> $i, $p { say "  pod[$i]  = <<{$p.Str.trim}>>" }
say 'code chunks : ', $m<code>.elems;
for $m<code>.kv -> $i, $c { say "  code[$i] = <<{$c.Str.trim}>>" }

# Output:
#     matched     : True
#     pod chunks  : 2
#       pod[0]  = <<=begin pod
#     This is the first documentation block.
#     It has two lines.
#     =end pod>>
#       pod[1]  = <<=begin pod
#     A second block, after some code.
#     =end pod>>
#     code chunks : 3
#       code[0] = <<unit module Literate;>>
#       code[1] = <<sub first() is export { 1 }>>
#       code[2] = <<sub second() is export { 2 }>>
