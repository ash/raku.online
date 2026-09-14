#!/usr/bin/env rakupp
# OO::Monitors — A monitor is a class
# https://raku.online/modules/oo-monitors/#a-monitor-is-a-class
#
# Install what it needs, then run it:
#     rakupp install OO::Monitors
#     rakupp 01-declare.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use OO::Monitors;

monitor Ledger {
    has %!balance;
    method deposit(Str $who, Int $amount) { %!balance{$who} += $amount; self }
    method balance(Str $who)             { %!balance{$who} // 0 }
    method total                         { %!balance.values.sum }
}

my $ledger = Ledger.new;
$ledger.deposit('ada', 40).deposit('ada', 2).deposit('grace', 10);
say $ledger.balance('ada'), ' ', $ledger.balance('grace'), ' ', $ledger.total;
say Ledger.^name, ' ', $ledger ~~ Ledger;

# Output:
#     42 10 52
#     Ledger True
