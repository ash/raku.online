#!/usr/bin/env rakupp
# Inline::BASIC — The three built-in functions are broken
# https://raku.online/modules/inline-basic/#the-three-built-in-functions-are-broken
#
# Install what it needs, then run it:
#     rakupp install Inline::BASIC
#     rakupp 04-builtins.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Inline::BASIC;

basic(q:to/END/);
10 PRINT RND()
20 PRINT INT(3.7)
30 PRINT ABS(-9)
40 PRINT floor(3.7)
50 PRINT abs(-9)
END
say '';
say 'RND() is rewritten to the text `rand()`, which Raku rejects outright;';
say 'evaluate-expression swallows the failure in a bare try and returns 0.';
say 'So RND() is a constant zero — forty consecutive PRINT RND() lines';
say 'produce forty identical zeros.';
say '';
say 'INT(x) and ABS(x) are rewritten by an s/// whose replacement is a';
say 'STRING, so the expression becomes the literal text "floor(3.7)" and';
say 'EVALs to that string rather than to 3.';
say '';
say 'the workaround is on lines 40 and 50: write the Raku names in lower';
say 'case and they pass straight through EVAL.';

# Output:
#     0
#     floor(3.7)
#     abs(-9)
#     3
#     9
#     
#     RND() is rewritten to the text `rand()`, which Raku rejects outright;
#     evaluate-expression swallows the failure in a bare try and returns 0.
#     So RND() is a constant zero — forty consecutive PRINT RND() lines
#     produce forty identical zeros.
#     
#     INT(x) and ABS(x) are rewritten by an s/// whose replacement is a
#     STRING, so the expression becomes the literal text "floor(3.7)" and
#     EVALs to that string rather than to 3.
#     
#     the workaround is on lines 40 and 50: write the Raku names in lower
#     case and they pass straight through EVAL.
