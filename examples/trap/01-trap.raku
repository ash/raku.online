#!/usr/bin/env rakupp
# Trap — Capturing output
# https://raku.online/modules/trap/#capturing-output
#
# Install what it needs, then run it:
#     rakupp install Trap
#     rakupp 01-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Trap;

my ($text, $silent);
{
    my $*OUT;                # scope the replacement
    Trap($*OUT);             # $*OUT is now a Trap instance
    say 'first line';
    print 'no newline';
    say '';
    printf("%s=%d\n", 'n', 42);
    $text   = $*OUT.text;
    $silent = $*OUT.silent;
}
say 'nothing leaked above this line';
say 'captured : ', $text.raku;
say 'silent   : ', $silent;
say '.text returns a : ', $text.^name;

# Output:
#     nothing leaked above this line
#     captured : "first line\nno newline\nn=42\n"
#     silent   : False
#     .text returns a : Str
