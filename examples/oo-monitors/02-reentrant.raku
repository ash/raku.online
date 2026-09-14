#!/usr/bin/env rakupp
# OO::Monitors — A monitor is a class that serialises itself
# https://raku.online/modules/oo-monitors/#a-monitor-is-a-class-that-serialises-itself
#
# Install what it needs, then run it:
#     rakupp install OO::Monitors
#     rakupp 02-reentrant.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use OO::Monitors;

monitor Ledger {
    has %!balance;
    method deposit(Str $who, Int $amount) { %!balance{$who} += $amount; self }
    method transfer(Str $from, Str $to, Int $amount) {
        self.deposit($from, -$amount);     # a method, from inside a method
        self.deposit($to, $amount);
    }
    method balance(Str $who) { %!balance{$who} // 0 }
    method snapshot { %!balance.clone }
}

my $ledger = Ledger.new;
$ledger.deposit('ada', 100).deposit('grace', 10);
$ledger.transfer('ada', 'grace', 40);
say $ledger.balance('ada'), ' ', $ledger.balance('grace');
say $ledger.snapshot.sort.map({ .key ~ '=' ~ .value }).join(' ');

# Output:
#     60 50
#     ada=60 grace=50
