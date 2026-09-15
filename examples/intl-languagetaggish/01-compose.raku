#!/usr/bin/env rakupp
# Intl::LanguageTaggish — Composing it
# https://raku.online/modules/intl-languagetaggish/#composing-it
#
# Install what it needs, then run it:
#     rakupp install Intl::LanguageTaggish
#     rakupp 01-compose.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Intl::LanguageTaggish;

class Tag does LanguageTaggish {
    has Str $.bcp47;
    method language { $!bcp47.split('-')[0] }
    method region   { $!bcp47.split('-')[1] // Str }
    multi method COERCE(LanguageTaggish:D $t --> Tag) { self.new: :bcp47($t.bcp47) }
    multi method COERCE(Str:D $s --> Tag)             { self.new: :bcp47($s) }
    method FALLBACK($name, |) { "<$name not modelled>" }
}

my $t = Tag.new(:bcp47('es-MX'));
say $t.language, ' ', $t.region, ' ', $t.bcp47;
say $t ~~ LanguageTaggish;
say $t.script;

my Tag() $coerced = 'pt-BR';
say $coerced.bcp47, ' ', $coerced.language;

# Output:
#     es MX es-MX
#     True
#     <script not modelled>
#     pt-BR pt
