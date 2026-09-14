#!/usr/bin/env rakupp
# Getopt::Long — Patterns, and a signature
# https://raku.online/modules/getopt-long/#patterns-and-a-signature
#
# Install what it needs, then run it:
#     rakupp install Getopt::Long
#     rakupp 02-signature.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Getopt::Long;

sub main(Str :$name = 'nobody', Bool :$verbose, Int :$count = 1, *@files) {
    say "name=$name verbose={$verbose // 'no'} count=$count files={@files.join(',')}";
}

call-with-getopt(&main, <--name Ada --verbose --count=2 a.txt b.txt>);
call-with-getopt(&main, ["--count=7"]);
say (try { call-with-getopt(&main, ["--nope"]); 'ran' }) // $!.message;

# Output:
#     name=Ada verbose=True count=2 files=a.txt,b.txt
#     name=nobody verbose=no count=7 files=
#     Unknown option --nope
