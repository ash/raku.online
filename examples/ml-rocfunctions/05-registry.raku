#!/usr/bin/env rakupp
# ML::ROCFunctions — Where the two engines differ
# https://raku.online/modules/ml-rocfunctions/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install ML::ROCFunctions
#     rakupp 05-registry.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ML::ROCFunctions;

say 'the name registry lets you look a function up by acronym or by name:';
say '  listed names   : ', roc-functions('FunctionNames').elems;
say '  lookup table   : ', roc-acronyms-hash.elems, ' accepted spellings';
say '  distinct funcs : ', roc-functions().elems;
say '';
say 'TNR and SPC compute the same quantity, so the registry hands back';
say 'one of them for both:';
say '  roc-functions("TNR").name = ', roc-functions('TNR').name;
say '';
say 'and an unrecognised spec returns an undefined value, silently:';
say '  roc-functions("NoSuchThing").defined = ',
    roc-functions('NoSuchThing').defined;
say '';
say 'the listed set is smaller than the accepted set — Specificity,';
say 'F1Score, TruePositiveRate and MatthewsCorrelationCoefficient all';
say 'work and are not in FunctionNames.';

# Output:
#     the name registry lets you look a function up by acronym or by name:
#       listed names   : 17
#       lookup table   : 17 accepted spellings
#       distinct funcs : 12
#     
#     TNR and SPC compute the same quantity, so the registry hands back
#     one of them for both:
#       roc-functions("TNR").name = SPC
#     
#     and an unrecognised spec returns an undefined value, silently:
#       roc-functions("NoSuchThing").defined = False
#     
#     the listed set is smaller than the accepted set — Specificity,
#     F1Score, TruePositiveRate and MatthewsCorrelationCoefficient all
#     work and are not in FunctionNames.
