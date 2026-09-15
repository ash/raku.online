#!/usr/bin/env rakupp
# Grammar::TodoTxt — Parsing a file
# https://raku.online/modules/grammar-todotxt/#parsing-a-file
#
# Install what it needs, then run it:
#     rakupp install Grammar::TodoTxt
#     rakupp 01-parse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Grammar::TodoTxt;

my $todo = q:to/END/;
(A) 2021-03-04 Call Mum +family @phone due:2021-03-05
x 2021-05-06 2021-03-04 Pay the rent +home @bank
Buy milk @shop
END

my $m = Grammar::TodoTxt.parse($todo);
say 'parsed  : ', ?$m;
say 'records : ', $m<records>.elems;
say '';
for $m<records>.kv -> $i, $r {
    say "record $i";
    say '  done       : ', $r<completion-marker>.defined ?? 'yes' !! 'no';
    say '  priority   : ', $r<priority>.defined ?? ~$r<priority> !! '(none)';
    say '  completion : ', $r<completion>.defined ?? ~$r<completion> !! '(none)';
    say '  creation   : ', $r<creation>.defined   ?? ~$r<creation>   !! '(none)';
    say '  projects   : ', ($r<description><projects> // ()).map(*.Str).join(',') || '(none)';
    say '  contexts   : ', ($r<description><contexts> // ()).map(*.Str).join(',') || '(none)';
    say '  labels     : ', ($r<description><labels> // ()).map({ "{$_<key>}={$_<value>}" }).join(',') || '(none)';
    say '  words      : ', ($r<description><words> // ()).map(*.Str).join(' ');
}

# Output:
#     parsed  : True
#     records : 3
#     
#     record 0
#       done       : no
#       priority   : A
#       completion : (none)
#       creation   : 2021-03-04
#       projects   : family
#       contexts   : phone
#       labels     : due=2021-03-05
#       words      : Call Mum
#     record 1
#       done       : yes
#       priority   : (none)
#       completion : 2021-05-06
#       creation   : 2021-03-04
#       projects   : home
#       contexts   : bank
#       labels     : (none)
#       words      : Pay the rent
#     record 2
#       done       : no
#       priority   : (none)
#       completion : (none)
#       creation   : (none)
#       projects   : (none)
#       contexts   : shop
#       labels     : (none)
#       words      : Buy milk
