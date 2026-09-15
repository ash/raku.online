#!/usr/bin/env rakupp
# Browser::Open — Asking what it would run
# https://raku.online/modules/browser-open/#asking-what-it-would-run
#
# Install what it needs, then run it:
#     rakupp install Browser::Open
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Browser::Open;

say 'kernel               : ', $*KERNEL.name;
say 'open-browser-cmd     : ', open-browser-cmd();
say 'open-browser-cmd-all : ', open-browser-cmd-all();
say '';
my $cmd = open-browser-cmd();
say 'it is executable     : ', $cmd.IO.x;
say 'return type          : ', $cmd.WHAT.^name;
say '';
say 'open-browser($url) spawns that command with the URL as its single';
say 'argv element — Proc::Async.new($cmd, $url), no shell — so a URL';
say 'containing shell metacharacters is not an injection vector.';
say '  it would run : ', ($cmd, 'https://example.invalid/x').raku;

# Output:
#     kernel               : darwin
#     open-browser-cmd     : /usr/bin/open
#     open-browser-cmd-all : /usr/bin/open
#     
#     it is executable     : True
#     return type          : Str
#     
#     open-browser($url) spawns that command with the URL as its single
#     argv element — Proc::Async.new($cmd, $url), no shell — so a URL
#     containing shell metacharacters is not an injection vector.
#       it would run : ("/usr/bin/open", "https://example.invalid/x")
