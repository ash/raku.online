#!/usr/bin/env rakupp
# Inline::BASIC — Running a program
# https://raku.online/modules/inline-basic/#running-a-program
#
# Install what it needs, then run it:
#     rakupp install Inline::BASIC
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Inline::BASIC;

basic(q:to/END/);
10 PRINT "HELLO, WORLD!"
20 LET A = 42
30 PRINT A
40 IF A > 10 THEN PRINT "A IS BIG"
50 FOR I = 1 TO 3
60 PRINT I
70 NEXT I
80 END
END

# Output:
#     HELLO, WORLD!
#     42
#     A IS BIG
#     1
#     2
#     3
