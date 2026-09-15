#!/usr/bin/env rakupp
# File::Zip — What the constructor refuses
# https://raku.online/modules/file-zip/#what-the-constructor-refuses
#
# Install what it needs, then run it:
#     rakupp install File::Zip
#     rakupp 03-refuses.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Zip;

my $root = $*TMPDIR.add("zip3-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.mkdir;
$root.add('adir').mkdir;
$root.add('notazip.txt').spurt("I am plain text\n");

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-26s %s', $label, $! ?? 'refused' !! 'accepted');
}

attempt 'a missing path',   { File::Zip.new($root.add('nope.zip')) };
attempt 'a directory',      { File::Zip.new($root.add('adir')) };
attempt 'a plain text file',{ File::Zip.new($root.add('notazip.txt')) };

# Output:
#     a missing path             refused
#     a directory                refused
#     a plain text file          refused
