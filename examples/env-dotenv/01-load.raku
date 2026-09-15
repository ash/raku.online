#!/usr/bin/env rakupp
# Env::Dotenv — Loading a file
# https://raku.online/modules/env-dotenv/#loading-a-file
#
# Install what it needs, then run it:
#     rakupp install Env::Dotenv
#     rakupp 01-load.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Env::Dotenv :load, :values;

my $dir = $*TMPDIR.add("dotenv-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

$dir.add('.env').spurt: q:to/ENV/;
SIMPLE=hello
DATABASE=postgres
PORT=5432
ENV

indir $dir, {
    my %v = dotenv_values();
    say 'dotenv_values : ', %v.keys.sort.map({ "$_={%v{$_}}" }).join(' ');
    dotenv_load();
    say 'after dotenv_load, ENV<SIMPLE> = ', %*ENV<SIMPLE>;
}

# Output:
#     dotenv_values : DATABASE=postgres PORT=5432 SIMPLE=hello
#     after dotenv_load, ENV<SIMPLE> = hello
