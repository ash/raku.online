#!/usr/bin/env rakupp
# Zodiac::Chinese — It takes a DateTime and only a DateTime
# https://raku.online/modules/zodiac-chinese/#it-takes-a-datetime-and-only-a-datetime
#
# Install what it needs, then run it:
#     rakupp install Zodiac::Chinese
#     rakupp 03-types.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Zodiac::Chinese;

for DateTime.new(year => 2024, month => 6, day => 15),
    Date.new(2024, 6, 15), 2024, '2024' -> $arg {
    my $r = try ChineseZodiac.new($arg);
    say sprintf('%-10s -> %s', $arg.WHAT.^name, $! ?? 'refused' !! $r.sign);
}
say '';
say 'there is no Date candidate and no Int one. Coerce yourself:';
say '  Date -> ', ChineseZodiac.new(Date.new(2024, 6, 15).DateTime).sign;

# Output:
#     DateTime   -> dragon
#     Date       -> refused
#     Int        -> refused
#     Str        -> refused
#     
#     there is no Date candidate and no Int one. Coerce yourself:
#       Date -> dragon
