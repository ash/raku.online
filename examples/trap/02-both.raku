#!/usr/bin/env rakupp
# Trap — Both handles at once
# https://raku.online/modules/trap/#both-handles-at-once
#
# Install what it needs, then run it:
#     rakupp install Trap
#     rakupp 02-both.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Trap;

my ($same, $both);
{
    my $*OUT;
    my $*ERR;
    Trap($*OUT, $*ERR);
    say  'to out';
    note 'to err';
    $same = $*OUT === $*ERR;
    $both = $*OUT.text;
}
say 'both handles are literally the same object : ', $same;
say 'interleaved text : ', $both.raku;

# Output:
#     both handles are literally the same object : True
#     interleaved text : "to out\nto err\n"
