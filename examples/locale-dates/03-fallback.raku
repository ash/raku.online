#!/usr/bin/env rakupp
# Locale::Dates — The one thing to know
# https://raku.online/modules/locale-dates/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Locale::Dates
#     rakupp 03-fallback.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::Dates;

for 'RU', 'ru', 'XX', 'Klingon', '' -> $code {
    say sprintf('  new(%-10s).code = %s', $code.raku, Locale::Dates.new($code).code);
}
say '';
say 'a program that does Locale::Dates.new($user-locale) will happily';
say 'print English month names for every locale it does not recognise,';
say 'with no signal of any kind. Check the code you got back:';
say '';
sub dates-for($code) {
    my $l = Locale::Dates.new($code);
    $l.code eq $code.uc ?? $l !! die "no table for '$code'"
}
say '  dates-for("RU").code : ', dates-for('RU').code;
my $r = try dates-for('ru');
say '  dates-for("ru")      : ', $! ?? $!.message !! 'accepted';

# Output:
#       new("RU"      ).code = RU
#       new("ru"      ).code = EN
#       new("XX"      ).code = EN
#       new("Klingon" ).code = EN
#       new(""        ).code = EN
#     
#     a program that does Locale::Dates.new($user-locale) will happily
#     print English month names for every locale it does not recognise,
#     with no signal of any kind. Check the code you got back:
#     
#       dates-for("RU").code : RU
#       dates-for("ru")      : no table for 'ru'
