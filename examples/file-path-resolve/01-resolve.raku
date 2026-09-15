#!/usr/bin/env rakupp
# File::Path::Resolve — Resolving
# https://raku.online/modules/file-path-resolve/#resolving
#
# Install what it needs, then run it:
#     rakupp install File::Path::Resolve
#     rakupp 01-resolve.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Path::Resolve;

my $R = File::Path::Resolve;
my $home = $*HOME.Str;

say $R.absolute('~').Str eq $home;
say $R.absolute('~/.config').Str eq "$home/.config";
say $R.absolute('~//.config').Str eq "$home/.config";
say $R.absolute('/tmp/../tmp').Str.ends-with('/tmp');
say $R.absolute('relative/bit').Str.starts-with($*CWD.Str);
say $R.absolute('~').^name;
say $R.absolute('/no/such/path').Str;

# Output:
#     True
#     True
#     True
#     True
#     True
#     IO::Path
#     /no/such/path
