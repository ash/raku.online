#!/usr/bin/env rakupp
# Dictionary::Create — Building an article
# https://raku.online/modules/dictionary-create/#building-an-article
#
# Install what it needs, then run it:
#     rakupp install Dictionary::Create
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
$a.set-title('rakupp');
$a.append-line($a.m-tag(1,
    $a.space([$a.translation('a Raku engine'), $a.example('rakupp foo.raku')])));
$a.set-newline;
$a.append-line($a.m-tag(2,
    $a.space([$a.comment('see also'), $a.url('https://example.invalid')])));

say $a.give;

# Output:
#     rakupp
#     	[m1][trn]a Raku engine[/trn] [ex]rakupp foo.raku[/ex][/m]
#     
#     	[m2][com]see also[/com] [url]https://example.invalid[/url][/m]
