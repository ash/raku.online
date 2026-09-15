#!/usr/bin/env rakupp
# IO::Path::Dirstack — The stack is process-global
# https://raku.online/modules/io-path-dirstack/#the-stack-is-process-global
#
# Install what it needs, then run it:
#     rakupp install IO::Path::Dirstack
#     rakupp 02-global.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use IO::Path::Dirstack;

my $base = $*TMPDIR.add("ds2-{$*PID}");
$base.add('a').mkdir;
LEAVE { run 'rm', '-rf', $base.Str }

my $start = $*CWD;

sub go-somewhere { pushd $base.add('a') }
sub come-back    { popd() }

go-somewhere();
say 'a sub pushed, and the change is visible out here : ', $*CWD.basename;
come-back();
say 'another sub popped, and we are back              : ', $*CWD.absolute eq $start.absolute;

# Output:
#     a sub pushed, and the change is visible out here : a
#     another sub popped, and we are back              : True
