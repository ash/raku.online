#!/usr/bin/env rakupp
# Trap — The one thing to know
# https://raku.online/modules/trap/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Trap
#     rakupp 03-not-a-handle.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Trap;

my @missing;
{
    my $*OUT;
    Trap($*OUT);
    for <flush write t lines slurp encoding> -> $m {
        @missing.push($m) unless $*OUT.^can($m);
    }
}
note 'methods a real handle has that Trap lacks : ', @missing.join(' ');
note 'Trap does IO::Handle : ', Trap ~~ IO::Handle;
note '';
my $e = 'no error';
{ my $*OUT; Trap($*OUT); try { my $x = $*OUT.t; CATCH { default { $e = .^name } } } }
note '$*OUT.t inside a trap -> ', $e;

# Output:
