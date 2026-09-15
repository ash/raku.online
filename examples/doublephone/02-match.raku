#!/usr/bin/env rakupp
# Doublephone — Matching
# https://raku.online/modules/doublephone/#matching
#
# Install what it needs, then run it:
#     rakupp install Doublephone
#     rakupp 02-match.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Doublephone;

sub sounds-alike($a, $b) {
    my @a = double-metaphone($a);
    my @b = double-metaphone($b);
    so @a.grep(*.chars) (&) @b.grep(*.chars);
}

for <Smith Schmidt>, <Wright Rait>, <Knight Nite>,
    <Smith Jones>, <Thompson Tomson> -> ($a, $b) {
    say sprintf('%-10s %-10s -> %s', $a, $b, sounds-alike($a, $b) ?? 'match' !! 'no');
}

# Output:
#     Smith      Schmidt    -> match
#     Wright     Rait       -> match
#     Knight     Nite       -> match
#     Smith      Jones      -> no
#     Thompson   Tomson     -> no
