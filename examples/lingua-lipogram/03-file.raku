#!/usr/bin/env rakupp
# Lingua::Lipogram — From a file
# https://raku.online/modules/lingua-lipogram/#from-a-file
#
# Install what it needs, then run it:
#     rakupp install Lingua::Lipogram
#     rakupp 03-file.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Lipogram;

my $f = $*TMPDIR.add("lipogram-{$*PID}.txt");
LEAVE $f.unlink;
$f.spurt("A quick brown fox jumps over a lazy dog.\n");

say 'no "z" in the file ? ', lipogram($f, 'z');
say 'no "o" in the file ? ', lipogram($f, 'o');
say '';
say 'there is no IO::Path + list candidate — only Str and Range:';
my $r = try lipogram($f, ('ing',));
say '  lipogram($path, ("ing",)) -> ', $! ?? 'no candidate matches' !! $r;
say '  slurp it yourself for the list form.';

# Output:
#     no "z" in the file ? False
#     no "o" in the file ? False
#     
#     there is no IO::Path + list candidate — only Str and Range:
#       lipogram($path, ("ing",)) -> no candidate matches
#       slurp it yourself for the list form.
