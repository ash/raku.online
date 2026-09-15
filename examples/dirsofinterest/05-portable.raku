#!/usr/bin/env rakupp
# DirsOfInterest — Where the two engines differ
# https://raku.online/modules/dirsofinterest/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install DirsOfInterest
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DirsOfInterest;

# the eight that work, wrapped so a caller gets Nil rather than an exception
sub dir(Str $which) {
    my $r = try DirsOfInterest."$which"();
    $! ?? Nil !! $r
}
for <user-config-dir user-log-dir user-documents-dir> -> $m {
    my $p = dir($m);
    say sprintf('  %-20s %s', $m,
                $p.defined ?? $p.Str.subst($*HOME.Str, '~') !! 'unavailable here');
}
say '';
say 'and note `new` is a submethod, so it is not inherited — subclassing';
say 'DirsOfInterest and calling .new bypasses the role mixin entirely and';
say 'leaves you with an object that has none of the eighteen methods.';

# Output:
#       user-config-dir      ~/Library/Application Support
#       user-log-dir         unavailable here
#       user-documents-dir   ~/Documents
#     
#     and note `new` is a submethod, so it is not inherited — subclassing
#     DirsOfInterest and calling .new bypasses the role mixin entirely and
#     leaves you with an object that has none of the eighteen methods.
