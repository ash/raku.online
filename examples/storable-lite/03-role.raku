#!/usr/bin/env rakupp
# Storable::Lite — The role
# https://raku.online/modules/storable-lite/#the-role
#
# Install what it needs, then run it:
#     rakupp install Storable::Lite
#     rakupp 03-role.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Storable::Lite;

class Config does FileStore {
    has Str $.host is rw;
    has Int $.port is rw;
}

my $dir = $*TMPDIR.add("store3-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $f = $dir.add('c.raku').absolute;

say 'the role adds instance methods : ',
    Config.^can('to-file') && Config.^can('from-file') ?? 'to-file and from-file' !! 'none';

# Output:
#     the role adds instance methods : to-file and from-file
