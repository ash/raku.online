#!/usr/bin/env rakupp
# Locale::Dates — Where the two engines differ
# https://raku.online/modules/locale-dates/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Locale::Dates
#     rakupp 05-containers.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Locale::Dates;

my @codes = Locale::Dates.known-locales.sort;
say 'sorted into your own array : ', @codes.join(' ');
say '';
say 'the name tables themselves are immutable Lists on BOTH engines, so';
say 'the shared singletons cannot be corrupted through them:';
my $en = Locale::Dates.new('EN');
my $ok = try { $en.weekdays[1] = 'Mandag'; True };
say '  writing to .weekdays -> ', $ok ?? 'succeeded' !! 'refused';
say '  .weekdays[1] is still ', $en.weekdays[1];

# Output:
#     sorted into your own array : BG DE EN FR NL PT RU
#     
#     the name tables themselves are immutable Lists on BOTH engines, so
#     the shared singletons cannot be corrupted through them:
#       writing to .weekdays -> refused
#       .weekdays[1] is still Monday
