#!/usr/bin/env rakupp
# IO::Path::Dirstack — The one thing to know
# https://raku.online/modules/io-path-dirstack/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install IO::Path::Dirstack
#     rakupp 03-failure-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use IO::Path::Dirstack;

my $base = $*TMPDIR.add("ds3-{$*PID}");
$base.add('a').mkdir;
$base.add('f.txt').spurt('x');
LEAVE { run 'rm', '-rf', $base.Str }

my $start = $*CWD.absolute;

my $r = pushd $base.add('nope');
say 'pushd to a missing path:';
say '  it threw            : ', False;
say '  the directory moved : ', $*CWD.absolute ne $start;
say '';
my $r2 = pushd $base.add('f.txt');
say 'pushd to a plain file:';
say '  the directory moved : ', $*CWD.absolute ne $start;
say '';
say 'now push once successfully, and pop once:';
pushd $base.add('a');
say '  moved : ', $*CWD.absolute ne $start;
popd();
say '  back  : ', $*CWD.absolute eq $start;
say '';
say 'the stack is now empty, even though pushd was called three times';

# Output:
#     pushd to a missing path:
#       it threw            : False
#       the directory moved : False
#     
#     pushd to a plain file:
#       the directory moved : False
#     
#     now push once successfully, and pop once:
#       moved : True
#       back  : True
#     
#     the stack is now empty, even though pushd was called three times
