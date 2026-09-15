#!/usr/bin/env rakupp
# Color::Scheme — Generating a palette
# https://raku.online/modules/color-scheme/#generating-a-palette
#
# Install what it needs, then run it:
#     rakupp install Color::Scheme
#     rakupp 01-scheme.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color;
use Color::Scheme;

my $base = Color.new('#1A3CFA');
say 'base : ', $base.to-string('hex');
say '';
for <triadic tetradic analogous split-complementary clash neutral> -> $name {
    my @p = color-scheme($base, $name);
    say sprintf('%-22s %d  %s', $name, @p.elems, @p.map(*.to-string('hex')).join(' '));
}

# Output:
#     base : #1A3CFA
#     
#     triadic                3  #1A3CFA #FA1A3C #3CFA1A
#     tetradic               4  #1A3CFA #FA1AAC #FAD81A #1AFA68
#     analogous              6  #1A3CFA #681AFA #D81AFA #FA1AAC #FA1A3C #FA681A
#     split-complementary    3  #1A3CFA #FA681A #1AD1FA
#     clash                  3  #1A3CFA #FA1AAC #1AFA68
#     neutral                6  #1A3CFA #301AFA #681AFA #A01AFA #D81AFA #FA1AE4
