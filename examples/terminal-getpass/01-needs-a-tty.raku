#!/usr/bin/env rakupp
# Terminal::Getpass — The one thing to know
# https://raku.online/modules/terminal-getpass/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Terminal::Getpass
#     rakupp 01-needs-a-tty.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::Getpass;

say (try { getpass('never asked: ') }) // $!.message;
say 'still running';

# Output:
#     tcgetattr failed
#     still running
