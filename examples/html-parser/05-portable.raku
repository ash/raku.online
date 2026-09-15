#!/usr/bin/env rakupp
# HTML::Parser — Where the two engines differ
# https://raku.online/modules/html-parser/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install HTML::Parser
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Parser;

say 'so if you are designing an interface role, two things this one shows:';
say '';
say '  1. write  { ... }  for a required method, not  {*}  — the yada';
say '     form is enforced at composition and names the method;';
say '';
say '  2. do not declare the implementation`s state in the interface.';
say '     `has XML::Document $.xmldoc` means every implementor inherits';
say '     a slot it may not want, and re-declaring it is a compile error:';
say '';
say '       class SimpleParser does HTML::Parser {';
say '           has XML::Document $.xmldoc;   # conflicts';
say '       }';
say '';
say '  the role`s own attribute is writable from the class, which is what';
say '  the working example on this page does.';

# Output:
#     so if you are designing an interface role, two things this one shows:
#     
#       1. write  { ... }  for a required method, not  {*}  — the yada
#          form is enforced at composition and names the method;
#     
#       2. do not declare the implementation`s state in the interface.
#          `has XML::Document $.xmldoc` means every implementor inherits
#          a slot it may not want, and re-declaring it is a compile error:
#     
#            class SimpleParser does HTML::Parser {
#                has XML::Document $.xmldoc;   # conflicts
#            }
#     
#       the role`s own attribute is writable from the class, which is what
#       the working example on this page does.
