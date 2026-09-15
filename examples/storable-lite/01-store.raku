#!/usr/bin/env rakupp
# Storable::Lite — Saving and loading
# https://raku.online/modules/storable-lite/#saving-and-loading
#
# Install what it needs, then run it:
#     rakupp install Storable::Lite
#     rakupp 01-store.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Storable::Lite;

my $dir = $*TMPDIR.add("store-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $f = $dir.add('x.raku').absolute;

sub trip($label, $v) {
    to-file($f, $v);
    my $back = from-file($f);
    say sprintf('%-8s same type=%-5s eqv=%s',
        $label, $v.WHAT === $back.WHAT, $v eqv $back);
}

trip 'Int',   42;
trip 'Str',   'hi';
trip 'Rat',   1/3;
trip 'Array', [1, 'two', 3.5];
trip 'Hash',  { a => 1, b => 'x' };
trip 'Bool',  True;
trip 'Set',   set(<a b>);
trip 'Date',  Date.new('2024-03-01');

# Output:
#     Int      same type=True  eqv=True
#     Str      same type=True  eqv=True
#     Rat      same type=True  eqv=True
#     Array    same type=True  eqv=True
#     Hash     same type=True  eqv=True
#     Bool     same type=True  eqv=True
#     Set      same type=True  eqv=True
#     Date     same type=True  eqv=True
