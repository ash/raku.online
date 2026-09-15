#!/usr/bin/env rakupp
# File::Zip — Opening and listing
# https://raku.online/modules/file-zip/#opening-and-listing
#
# Install what it needs, then run it:
#     rakupp install File::Zip
#     rakupp 01-list.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use File::Zip;

my $root = $*TMPDIR.add("zip-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('src/nested');
$root.add('src/alpha.txt').spurt("alpha\n");
$root.add('src/beta.txt').spurt("beta beta\n");
$root.add('src/nested/gamma.txt').spurt("gamma gamma gamma\n");
# pin the timestamps so the listing is the same everywhere
run 'touch', '-t', '202401021530',
    $root.add('src/alpha.txt').Str, $root.add('src/beta.txt').Str,
    $root.add('src/nested/gamma.txt').Str, $root.add('src/nested').Str,
    $root.add('src').Str;
run 'zip', '-q', '-r', '-X', $root.add('bundle.zip').Str, 'src', :cwd($root.Str);

my $zip = File::Zip.new($root.add('bundle.zip'));
say 'object : ', $zip.^name;
say 'path   : ', $zip.path.basename, '  (a ', $zip.path.^name, ')';
say '';
my %f = $zip.files;
say 'members : ', %f.keys.elems;
for %f.keys.sort -> $k {
    say sprintf('  %-22s %d bytes  %s %s', $k, %f{$k}<length>, %f{$k}<date>, %f{$k}<time>);
}

# Output:
#     object : File::Zip
#     path   : bundle.zip  (a IO::Path)
#     
#     members : 5
#       src/                   0 bytes  01-02-2024 15:30
#       src/alpha.txt          6 bytes  01-02-2024 15:30
#       src/beta.txt           10 bytes  01-02-2024 15:30
#       src/nested/            0 bytes  01-02-2024 15:30
#       src/nested/gamma.txt   18 bytes  01-02-2024 15:30
