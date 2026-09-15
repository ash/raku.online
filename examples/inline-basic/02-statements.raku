#!/usr/bin/env rakupp
# Inline::BASIC — Running a program
# https://raku.online/modules/inline-basic/#running-a-program
#
# Install what it needs, then run it:
#     rakupp install Inline::BASIC
#     rakupp 02-statements.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Inline::BASIC;

basic(q:to/END/);
10 REM the statements it knows
20 DATA 11, 22
30 READ X
40 READ Y
50 PRINT X + Y
60 GOSUB 100
70 FOR I = 10 TO 1 STEP -3
80 PRINT I;
90 NEXT I
95 END
100 PRINT "IN SUBROUTINE"
110 RETURN
END
say '';
say 'PRINT INPUT LET GOTO GOSUB RETURN IF/THEN FOR/TO/STEP NEXT END STOP';
say 'REM DATA READ RESTORE DIM, plus a bare VAR = expr.';

# Output:
#     33
#     IN SUBROUTINE
#     10741
#     PRINT INPUT LET GOTO GOSUB RETURN IF/THEN FOR/TO/STEP NEXT END STOP
#     REM DATA READ RESTORE DIM, plus a bare VAR = expr.
