#!/usr/bin/env rakupp
# DirsOfInterest — The one thing to know
# https://raku.online/modules/dirsofinterest/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install DirsOfInterest
#     rakupp 03-broken.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DirsOfInterest;

my @all = <site-cache-dir site-config-dir site-config-dirs site-data-dir
           site-data-dirs site-runtime-dir user-cache-dir user-config-dir
           user-data-dir user-desktop-dir user-documents-dir user-downloads-dir
           user-log-dir user-music-dir user-pictures-dir user-runtime-dir
           user-state-dir user-videos-dir>;
my @dead = @all.grep({ my $r = try DirsOfInterest."$_"(); $!.so });
say 'lookups that throw on macOS : ', @dead.elems, ' of ', @all.elems;
say '  ', @dead.join("\n  ");
say '';
say 'DirsOfInterest::MacOS calls self!append-stuff(…) — PRIVATE-method';
say 'syntax — but `append-stuff` is declared as an ordinary public method';
say 'on DirsOfInterest. There is no such private method, and because the';
say 'role is mixed in with `does` at construction, nothing catches it at';
say 'compile time.';
say '';
say 'user-state-dir fails for a second, independent reason: it calls';
say 'self.user_data_dir, with underscores, a name that does not exist.';
say '';
say 'DirsOfInterest::Unix uses the public self.append-stuff consistently';
say 'and has none of this — the defect is macOS-only, which is exactly';
say 'where a macOS developer will meet it.';

# Output:
#     lookups that throw on macOS : 10 of 18
#       site-cache-dir
#       site-config-dir
#       site-config-dirs
#       site-data-dir
#       site-data-dirs
#       site-runtime-dir
#       user-cache-dir
#       user-log-dir
#       user-runtime-dir
#       user-state-dir
#     
#     DirsOfInterest::MacOS calls self!append-stuff(…) — PRIVATE-method
#     syntax — but `append-stuff` is declared as an ordinary public method
#     on DirsOfInterest. There is no such private method, and because the
#     role is mixed in with `does` at construction, nothing catches it at
#     compile time.
#     
#     user-state-dir fails for a second, independent reason: it calls
#     self.user_data_dir, with underscores, a name that does not exist.
#     
#     DirsOfInterest::Unix uses the public self.append-stuff consistently
#     and has none of this — the defect is macOS-only, which is exactly
#     where a macOS developer will meet it.
