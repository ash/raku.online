#!/usr/bin/env rakupp
# Glob::Grammar — Glob in, regex source out
# https://raku.online/modules/glob-grammar/#glob-in-regex-source-out
#
# Install what it needs, then run it:
#     rakupp install Glob::Grammar
#     rakupp 01-translate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Glob::Grammar;
use Glob::ToRegexActions;

my $actions = Glob::ToRegexActions.new;
sub to-rx(Str $glob) {
    my $m = Glob::Grammar.parse($glob, :$actions);
    $m ?? $m.made !! Nil
}

for '*.txt', 'a?c', 'README', 'src/*.rakumod' -> $g {
    say sprintf('%-14s %s', $g, to-rx($g).raku);
}

my $rx = to-rx('*.txt');
say $rx.^name;
for <notes.txt notes.md a.txt txt> -> $name {
    say sprintf('  %-10s %s', $name, so $name ~~ /<$rx>/);
}

# Output:
#     *.txt          "^.*\\.txt\$"
#     a?c            "^a.c\$"
#     README         "^README\$"
#     src/*.rakumod  "^src\\/.*\\.rakumod\$"
#     Str
#       notes.txt  True
#       notes.md   False
#       a.txt      True
#       txt        False
