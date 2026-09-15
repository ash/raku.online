#!/usr/bin/env rakupp
# File::Zip — Extracting
# https://raku.online/modules/file-zip/#extracting
#
# Install what it needs, then run it:
#     rakupp install File::Zip
#     rakupp 02-extract.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Zip;

my $root = $*TMPDIR.add("zip2-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('src');
$root.add('src/one.txt').spurt("one\n");
run 'zip', '-q', '-r', '-X', $root.add('bundle.zip').Str, 'src', :cwd($root.Str);

mkdir $root.add('out');
my $zip = File::Zip.new($root.add('bundle.zip'));
say 'extract to a directory : ', $zip.extract($root.add('out'));
say '';
sub walk($d) { $d.dir.sort(*.basename).map({ .d ?? ($_, |walk($_)) !! $_ }).flat }
say 'what landed there:';
say '  ', .Str.subst($root.add('out').Str ~ '/', '') for walk($root.add('out'));

# Output:
#     extract to a directory : True
#     
#     what landed there:
#       src
#       src/one.txt
