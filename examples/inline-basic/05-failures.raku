#!/usr/bin/env rakupp
# Inline::BASIC — Silent zeros and hard dies
# https://raku.online/modules/inline-basic/#silent-zeros-and-hard-dies
#
# Install what it needs, then run it:
#     rakupp install Inline::BASIC
#     rakupp 05-failures.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Inline::BASIC;

basic(q:to/END/);
10 PRINT SQR(9)
20 PRINT LEN("hello")
30 PRINT 1 +
40 PRINT "abc" x 3
END
say '';
say 'any expression Raku cannot evaluate becomes 0, with no warning.';
say '(line 40 prints abc0 — the string-literal branch consumes "abc" and';
say 'the remaining ` x 3` fails its own EVAL to 0.)';
say '';
say 'but an unrecognised STATEMENT aborts the whole program:';
my $r = try basic("10 PRINT \"one\"\n20 FROBNICATE\n30 PRINT \"three\"\n");
say '  ', $! ?? $!.message !! 'completed';
say '';
say 'and a string assignment needs LET while a numeric one does not,';
say 'because the bare-assignment branch is ^ (\\w+) \\s* "=" and \\w';
say 'excludes $:';
basic("10 LET A\$ = \"HI\"\n20 PRINT A\$\n30 B = 42\n40 PRINT B\n");

# Output:
#     0
#     0
#     0
#     abc0
#     
#     any expression Raku cannot evaluate becomes 0, with no warning.
#     (line 40 prints abc0 — the string-literal branch consumes "abc" and
#     the remaining ` x 3` fails its own EVAL to 0.)
#     
#     but an unrecognised STATEMENT aborts the whole program:
#     one
#       ?SYNTAX ERROR IN 20: Unknown statement 'FROBNICATE'
#     
#     and a string assignment needs LET while a numeric one does not,
#     because the bare-assignment branch is ^ (\w+) \s* "=" and \w
#     excludes $:
#     HI
#     42
