#!/usr/bin/env rakupp
# HTML::Parser — The whole declaration
# https://raku.online/modules/html-parser/#the-whole-declaration
#
# Install what it needs, then run it:
#     rakupp install HTML::Parser
#     rakupp 01-declaration.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Parser;

say 'HTML::Parser is a : ', HTML::Parser.HOW.^name;
say '';
say 'it declares:';
say '  has XML::Document $.xmldoc;';
say '  method parse(Str $html) returns XML::Document {*}';
say '';
say 'and that is all. No `is export`, no constructor help, no other unit.';

# Output:
#     HTML::Parser is a : Perl6::Metamodel::ParametricRoleGroupHOW
#     
#     it declares:
#       has XML::Document $.xmldoc;
#       method parse(Str $html) returns XML::Document {*}
#     
#     and that is all. No `is export`, no constructor help, no other unit.
