#!/usr/bin/env rakupp
# Abbreviations — The shapes
# https://raku.online/modules/abbreviations/#the-shapes
#
# Install what it needs, then run it:
#     rakupp install Abbreviations
#     rakupp 01-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Abbreviations;

my @months = <January February March April May June July>;

my %shortest = abbreviations(@months);
say %shortest.keys.sort.map({ "$_=" ~ %shortest{$_} }).join(' ');

say abbreviations(@months, :out-type(AL)).sort.join(' ');

my %by-abbrev = abbreviations(@months, :out-type(AH));
say %by-abbrev.elems, ' abbreviations in all';
say %by-abbrev<Ja>, ' ', %by-abbrev<Jul>, ' ', %by-abbrev<Marc>;

my %all = abbreviations(@months, :out-type(H));
say %all<April>.join(',');

# Output:
#     April=A February=F January=Ja July=Jul June=Jun March=Mar May=May
#     A F Ja Jul Jun Mar May
#     27 abbreviations in all
#     January July March
#     A,Ap,Apr,Apri,April
