#!/usr/bin/env rakupp
# IO::Path::Dirstack — Pushing and popping
# https://raku.online/modules/io-path-dirstack/#pushing-and-popping
#
# Install what it needs, then run it:
#     rakupp install IO::Path::Dirstack
#     rakupp 01-pushd.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use IO::Path::Dirstack;

my $base = $*TMPDIR.add("ds-{$*PID}");
$base.add('a/b').mkdir;
LEAVE { run 'rm', '-rf', $base.Str }

my $start = $*CWD;

say 'pushd a   : ', pushd $base.add('a');
say '  now in  : ', $*CWD.basename;
say 'pushd a/b : ', pushd $base.add('a/b');
say '  now in  : ', $*CWD.basename;
say '';
say 'popd      : ', popd();
say '  now in  : ', $*CWD.basename;
say 'popd      : ', popd();
say '  back at the start : ', $*CWD.absolute eq $start.absolute;

# Output:
#     pushd a   : True
#       now in  : a
#     pushd a/b : True
#       now in  : b
#     
#     popd      : True
#       now in  : a
#     popd      : True
#       back at the start : True
