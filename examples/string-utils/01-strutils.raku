#!/usr/bin/env rakupp
# String::Utils — Cutting a string at a marker
# https://raku.online/modules/string-utils/#cutting-a-string-at-a-marker
#
# Install what it needs, then run it:
#     rakupp install String::Utils
#     rakupp 01-strutils.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Utils;

my $path = 'lib/String/Utils.rakumod';
say 'before   : ', before($path, '/').raku;
say 'after    : ', after($path, '/').raku;
say 'between  : ', between($path, 'lib/', '.rakumod').raku;
say '';
say 'stem           : ', stem('archive.tar.gz').raku;
say 'stem, 1 part   : ', stem('archive.tar.gz', 1).raku;
say 'shorten        : ', shorten('a rather long sentence', 10).raku;
say 'nomark         : ', nomark('çédille naïve').raku;
say 'is-sha1        : ', is-sha1('0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33');
say '';
say 'ngram("raku", 2) : ', ngram('raku', 2).join(' ');
say 'word-at          : ', word-at('the quick brown', 4).raku;
say 'abbrev("length") : ', abbrev('length').sort(*.key).map({ .key }).join(' ');

# Output:
#     before   : "lib"
#     after    : "String/Utils.rakumod"
#     between  : "String/Utils"
#     
#     stem           : "archive"
#     stem, 1 part   : "archive.tar"
#     shorten        : "a ra…tence"
#     nomark         : "cedille naive"
#     is-sha1        : False
#     
#     ngram("raku", 2) : ra ak ku
#     word-at          : (4, 5, 1)
#     abbrev("length") : l le len leng lengt length
