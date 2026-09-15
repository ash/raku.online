#!/usr/bin/env rakupp
# Browser::Open — The one thing to know
# https://raku.online/modules/browser-open/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Browser::Open
#     rakupp 02-browser-env.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Browser::Open;
use File::Which;

say 'the candidate table stores the $BROWSER value with no "this is';
say 'already a path" flag, so it goes through which():';
say '';
say '  which("cat")      = ', which('cat').raku;
say '  which("/bin/cat") = ', which('/bin/cat').raku, '   <- a real, executable file';
say '  "/bin/cat".IO.x   = ', '/bin/cat'.IO.x;
say '';
say 'File::Which only scans PATH directories, so an absolute path returns';
say 'Nil and the candidate is skipped. No error, no warning.';
say '';
say '  BROWSER=/bin/cat -> falls back to the OS default';
say '  BROWSER=cat      -> resolves to ', which('cat').raku;
say '';
say 'set BROWSER to a NAME on your PATH, not to a path.';

# Output:
#     the candidate table stores the $BROWSER value with no "this is
#     already a path" flag, so it goes through which():
#     
#       which("cat")      = "/bin/cat"
#       which("/bin/cat") = Any   <- a real, executable file
#       "/bin/cat".IO.x   = True
#     
#     File::Which only scans PATH directories, so an absolute path returns
#     Nil and the candidate is skipped. No error, no warning.
#     
#       BROWSER=/bin/cat -> falls back to the OS default
#       BROWSER=cat      -> resolves to "/bin/cat"
#     
#     set BROWSER to a NAME on your PATH, not to a path.
