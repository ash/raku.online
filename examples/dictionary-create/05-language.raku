#!/usr/bin/env rakupp
# Dictionary::Create — Where the two engines differ
# https://raku.online/modules/dictionary-create/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Dictionary::Create
#     rakupp 05-language.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Dictionary::Create;

say 'with no properties it works on Raku++ and is refused on Rakudo —';
say 'even an empty Hash is not an Associative[Hash].';
say '';
say 'with one property it works on Raku++ and is';
say '"expected Associative[Hash] but got Hash" on Rakudo. And passing';
say 'what the signature actually demands produces nonsense on both:';
say '  my Hash %one = k => %(v => 1);';
say '  $a.language(%one, "X")  ->  [lang k="v<TAB>1"]X[/lang]';
say '';
say 'so treat language as unusable, and write the tag yourself:';
sub lang-tag(Str $text, Str :$name) {
    $name.defined ?? "[lang name=\"$name\"]$text\[/lang]" !! "[lang]$text\[/lang]"
}
say '  lang-tag("X")               = ', lang-tag('X');
say '  lang-tag("X", name => "ru") = ', lang-tag('X', name => 'ru');
say '';
say 'one naming note: Dictionary::Create::DSL is an EMPTY class. Reach';
say 'for Dictionary::Create::DSL::Article, which is where everything is.';

# Output:
#     with no properties it works on Raku++ and is refused on Rakudo —
#     even an empty Hash is not an Associative[Hash].
#     
#     with one property it works on Raku++ and is
#     "expected Associative[Hash] but got Hash" on Rakudo. And passing
#     what the signature actually demands produces nonsense on both:
#       my Hash %one = k => %(v => 1);
#       $a.language(%one, "X")  ->  [lang k="v<TAB>1"]X[/lang]
#     
#     so treat language as unusable, and write the tag yourself:
#       lang-tag("X")               = [lang]X[/lang]
#       lang-tag("X", name => "ru") = [lang name="ru"]X[/lang]
#     
#     one naming note: Dictionary::Create::DSL is an EMPTY class. Reach
#     for Dictionary::Create::DSL::Article, which is where everything is.
