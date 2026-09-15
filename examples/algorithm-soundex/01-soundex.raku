#!/usr/bin/env rakupp
# Algorithm::Soundex — Coding a name
# https://raku.online/modules/algorithm-soundex/#coding-a-name
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Soundex
#     rakupp 01-soundex.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Soundex;

my $sx = Algorithm::Soundex.new;

my %published =
    Robert   => 'R163', Rupert    => 'R163', Rubin    => 'R150',
    Ashcraft => 'A261', Ashcroft  => 'A261', Tymczak  => 'T522',
    Pfister  => 'P236', Honeyman  => 'H555', Euler    => 'E460',
    Gauss    => 'G200', Hilbert   => 'H416', Knuth    => 'K530',
    Lloyd    => 'L300', Washington => 'W252', Lee     => 'L000';

for %published.keys.sort -> $name {
    my $got = $sx.soundex($name);
    say sprintf('%-12s got=%-5s published=%-5s %s',
        $name, $got, %published{$name}, $got eq %published{$name} ?? 'match' !! 'DIFFERS');
}

# Output:
#     Ashcraft     got=A261  published=A261  match
#     Ashcroft     got=A261  published=A261  match
#     Euler        got=E460  published=E460  match
#     Gauss        got=G200  published=G200  match
#     Hilbert      got=H416  published=H416  match
#     Honeyman     got=H555  published=H555  match
#     Knuth        got=K530  published=K530  match
#     Lee          got=L000  published=L000  match
#     Lloyd        got=L300  published=L300  match
#     Pfister      got=P236  published=P236  match
#     Robert       got=R163  published=R163  match
#     Rubin        got=R150  published=R150  match
#     Rupert       got=R163  published=R163  match
#     Tymczak      got=T522  published=T522  match
#     Washington   got=W252  published=W252  match
