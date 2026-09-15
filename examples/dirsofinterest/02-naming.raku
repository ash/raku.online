#!/usr/bin/env rakupp
# DirsOfInterest — Naming your application
# https://raku.online/modules/dirsofinterest/#naming-your-application
#
# Install what it needs, then run it:
#     rakupp install DirsOfInterest
#     rakupp 02-naming.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DirsOfInterest;

DirsOfInterest.set(app-name => 'demo', app-version => '1.2');
say 'after .set(:app-name, :app-version):';
for <user-data-dir user-config-dir user-documents-dir user-music-dir> -> $m {
    say sprintf('  %-20s %s', $m,
                DirsOfInterest."$m"().Str.subst($*HOME.Str, '~'));
}
say '';
say 'the eight working lookups split into two groups with different';
say 'semantics: data and config get your name and version appended, the';
say 'six media directories do not. Setting :app-name and assuming it';
say 'applies uniformly gets you a wrong answer with no error.';
say '';
say '.set installs a process-wide singleton; .new gives you an instance:';
my $d = DirsOfInterest.new(app-name => 'other', app-version => '0.1');
say '  instance : ', $d.user-data-dir.Str.subst($*HOME.Str, '~');
say '  singleton: ', DirsOfInterest.user-data-dir.Str.subst($*HOME.Str, '~');

# Output:
#     after .set(:app-name, :app-version):
#       user-data-dir        ~/Library/Application Support/demo/1.2
#       user-config-dir      ~/Library/Application Support/demo/1.2
#       user-documents-dir   ~/Documents
#       user-music-dir       ~/Music
#     
#     the eight working lookups split into two groups with different
#     semantics: data and config get your name and version appended, the
#     six media directories do not. Setting :app-name and assuming it
#     applies uniformly gets you a wrong answer with no error.
#     
#     .set installs a process-wide singleton; .new gives you an instance:
#       instance : ~/Library/Application Support/other/0.1
#       singleton: ~/Library/Application Support/demo/1.2
