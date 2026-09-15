#!/usr/bin/env rakupp
# Browser::Open — Failure is silent
# https://raku.online/modules/browser-open/#failure-is-silent
#
# Install what it needs, then run it:
#     rakupp install Browser::Open
#     rakupp 03-silent.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Browser::Open;

say 'open-browser returns nothing useful:';
say '  the sub does Proc::Async.new($cmd, $url).start and DISCARDS the';
say '  Promise, so it returns immediately and a script that exits right';
say '  after calling it gives the child no time to start.';
say '';
say 'and if no candidate resolves at all, it returns without spawning';
say 'anything and without any indication. Check first:';
my $cmd = open-browser-cmd();
if $cmd {
    say '  a browser command is available : ', $cmd;
} else {
    say '  no browser command found — tell the user yourself';
}
say '';
say 'a wrapper worth having:';
say '  sub open-url($url) {';
say '      my $cmd = open-browser-cmd() or die "no browser command found";';
say '      await Proc::Async.new($cmd, $url).start;';
say '  }';

# Output:
#     open-browser returns nothing useful:
#       the sub does Proc::Async.new($cmd, $url).start and DISCARDS the
#       Promise, so it returns immediately and a script that exits right
#       after calling it gives the child no time to start.
#     
#     and if no candidate resolves at all, it returns without spawning
#     anything and without any indication. Check first:
#       a browser command is available : /usr/bin/open
#     
#     a wrapper worth having:
#       sub open-url($url) {
#           my $cmd = open-browser-cmd() or die "no browser command found";
#           await Proc::Async.new($cmd, $url).start;
#       }
