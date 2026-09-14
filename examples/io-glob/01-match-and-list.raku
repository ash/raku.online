#!/usr/bin/env rakupp
# IO::Glob — Matching and listing
# https://raku.online/modules/io-glob/#matching-and-listing
#
# Install what it needs, then run it:
#     rakupp install IO::Glob
#     rakupp 01-match-and-list.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use IO::Glob;

say 'notes.txt' ~~ glob('*.txt');
say 'notes.TXT' ~~ glob('*.txt');
say <a.raku b.rakumod c.txt>.grep(glob('*.raku*'));
say <one two three>.grep(glob('{one,two}'));
say 'src/lib/Foo.rakumod' ~~ glob('src/**/*.rakumod');

my $dir = $*TMPDIR.add("glob-{$*PID}");
$dir.mkdir;
$dir.add($_).spurt('') for <alpha.txt beta.txt gamma.md>;
$dir.add('sub').mkdir;
$dir.add('sub/delta.txt').spurt('');
say glob('*.txt').dir($dir.Str).map(*.basename).sort;
say glob('*').dir($dir.Str).map(*.basename).sort;
say glob('**/*.txt').dir($dir.Str).map({ .relative($dir) }).sort;
.unlink for $dir.add('sub/delta.txt'), $dir.add('alpha.txt'), $dir.add('beta.txt'), $dir.add('gamma.md');
$dir.add('sub').rmdir;
$dir.rmdir;

# Output:
#     True
#     False
#     (a.raku b.rakumod)
#     (one two)
#     True
#     (alpha.txt beta.txt)
#     (. .. alpha.txt beta.txt gamma.md sub)
#     (sub/delta.txt)
