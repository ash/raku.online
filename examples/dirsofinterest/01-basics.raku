#!/usr/bin/env rakupp
# DirsOfInterest — The lookups that work here
# https://raku.online/modules/dirsofinterest/#the-lookups-that-work-here
#
# Install what it needs, then run it:
#     rakupp install DirsOfInterest
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DirsOfInterest;

for <user-config-dir user-data-dir user-desktop-dir user-documents-dir
     user-downloads-dir user-music-dir user-pictures-dir user-videos-dir> -> $m {
    my $r = try DirsOfInterest."$m"();
    say sprintf('  %-20s %s', $m,
                $! ?? 'THROWS' !! $r.Str.subst($*HOME.Str, '~'));
}
say '';
say 'note user-videos-dir maps to ~/Movies on macOS, not ~/Videos.';

# Output:
#       user-config-dir      ~/Library/Application Support
#       user-data-dir        ~/Library/Application Support
#       user-desktop-dir     ~/Desktop
#       user-documents-dir   ~/Documents
#       user-downloads-dir   ~/Downloads
#       user-music-dir       ~/Music
#       user-pictures-dir    ~/Pictures
#       user-videos-dir      ~/Movies
#     
#     note user-videos-dir maps to ~/Movies on macOS, not ~/Videos.
