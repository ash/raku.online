#!/usr/bin/env rakupp
# Intl::LanguageTaggish — The one thing to know
# https://raku.online/modules/intl-languagetaggish/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Intl::LanguageTaggish
#     rakupp 02-not-a-type.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Intl::LanguageTaggish;

say LanguageTaggish.HOW.^name.subst(/^.*'::'/, '');
say LanguageTaggish.^name;
say (try LanguageTaggish.new('en-US')) // 'new: refused';
say (try LanguageTaggish('en-US')) // 'coercion: refused';

# Output:
#     ParametricRoleGroupHOW
#     LanguageTaggish
#     new: refused
#     coercion: refused
