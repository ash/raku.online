#!/usr/bin/env rakupp
# Dictionary::Create — The tag builders
# https://raku.online/modules/dictionary-create/#the-tag-builders
#
# Install what it needs, then run it:
#     rakupp install Dictionary::Create
#     rakupp 02-tags.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
for <translation example comment index-exclude multimedia url popup accent
     reference mark-secondary> -> $m {
    say sprintf('  %-16s -> %s', $m, $a."$m"('X'));
}
say '';
say '  m-tag(3, "X")   -> ', $a.m-tag(3, 'X');
say '  space(<A B C>)  -> ', $a.space(<A B C>).raku;
say '';
say 'every one of those is a PURE function from a string to a wrapped';
say 'string — none of them touches the article.';

# Output:
#       translation      -> [trn]X[/trn]
#       example          -> [ex]X[/ex]
#       comment          -> [com]X[/com]
#       index-exclude    -> [!trs]X[/!trs]
#       multimedia       -> [s]X[/s]
#       url              -> [url]X[/url]
#       popup            -> [p]X[/p]
#       accent           -> [']X[/']
#       reference        -> [ref]X[/ref]
#       mark-secondary   -> [*]X[/*]
#     
#       m-tag(3, "X")   -> [m3]X[/m]
#       space(<A B C>)  -> "A B C"
#     
#     every one of those is a PURE function from a string to a wrapped
#     string — none of them touches the article.
