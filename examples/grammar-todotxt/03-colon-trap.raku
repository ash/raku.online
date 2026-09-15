#!/usr/bin/env rakupp
# Grammar::TodoTxt — The one thing to know
# https://raku.online/modules/grammar-todotxt/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Grammar::TodoTxt
#     rakupp 03-colon-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Grammar::TodoTxt;

for "Read https://example.com/docs\n", "Meet at 10:30\n", "Fix c:\\path\\thing\n" -> $line {
    my $r = Grammar::TodoTxt.parse($line)<records>[0];
    say 'line   : ', $line.chomp;
    say '  labels : ', ($r<description><labels> // ()).map({ "{$_<key>} => {$_<value>}" }).join(' | ') || '(none)';
    say '  words  : ', ($r<description><words> // ()).map(*.Str).join(' ') || '(none)';
}

# Output:
#     line   : Read https://example.com/docs
#       labels : https => //example.com/docs
#       words  : Read
#     line   : Meet at 10:30
#       labels : 10 => 30
#       words  : Meet at
#     line   : Fix c:\path\thing
#       labels : c => \path\thing
#       words  : Fix
