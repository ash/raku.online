#!/usr/bin/env rakupp
# Abbreviations — The one thing to know
# https://raku.online/modules/abbreviations/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Abbreviations
#     rakupp 02-one-word.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Abbreviations;

my $one = abbreviations(<solo>, :out-type(HA));
say $one.^name, ' ', $one.raku;

my %two = abbreviations(<solo duet>, :out-type(HA));
say %two.^name, ' ', %two.keys.sort.map({ "$_=" ~ %two{$_} }).join(' ');

say (try abbreviations((), :out-type(HA))) // $!.message;

# Output:
#     Str "s|so|sol|solo"
#     Hash duet=d solo=s
#     FATAL: Empty input word set.
