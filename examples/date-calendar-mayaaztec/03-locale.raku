#!/usr/bin/env rakupp
# Date::Calendar::MayaAztec — Locales
# https://raku.online/modules/date-calendar-mayaaztec/#locales
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::MayaAztec
#     rakupp 03-locale.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Maya;
use Date::Calendar::Aztec;

my $m = Date::Calendar::Maya.new-from-date(Date.new(2020, 6, 20));
for <yua en fr> -> $loc {
    $m.locale = $loc;
    say sprintf('maya  %-3s  haab %-12s tzolkin %s', $loc, $m.haab.raku, $m.tzolkin.raku);
}
say '';
my $a = Date::Calendar::Aztec.new-from-date(Date.new(2020, 6, 20));
for <nah en fr> -> $loc {
    $a.locale = $loc;
    say sprintf('aztec %-3s  xiuh %-16s tonal %s', $loc, $a.xiuhpohualli.raku, $a.tonalpohualli.raku);
}

# Output:
#     maya  yua  haab "1 Tzec"     tzolkin "12 Etznab"
#     maya  en   haab "1 Skull"    tzolkin "12 Flint"
#     maya  fr   haab "1 Tzec"     tzolkin "12 Couteau de silex"
#     
#     aztec nah  xiuh "20 Teotleco"    tonal "12 Tecpatl"
#     aztec en   xiuh "20 God arrives" tonal "12 Flint"
#     aztec fr   xiuh "20 Retour des dieux" tonal "12 Silex"
