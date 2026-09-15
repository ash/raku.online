#!/usr/bin/env rakupp
# Algorithm::Manacher — The one thing to know
# https://raku.online/modules/algorithm-manacher/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Manacher
#     rakupp 03-maximal-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Manacher;

my $t = 'banana';
my %all = Algorithm::Manacher.new(text => $t).find-all-palindrome;

my @every = gather for 0 ..^ $t.chars -> $i {
    for $i ..^ $t.chars -> $j {
        my $s = $t.substr($i, $j - $i + 1);
        take $s if $s eq $s.flip;
    }
};

say "text                        : $t";
say 'find-all-palindrome keys    : ', %all.keys.sort.join(' ');
say 'every palindromic substring : ', @every.unique.sort.join(' ');
say 'missing from find-all       : ', (@every.unique (-) %all.keys).keys.sort.join(' ');
say '';
say "'a' occurs at indices       : ",
    (0 ..^ $t.chars).grep({ $t.substr($_, 1) eq 'a' }).join(',');
say "find-all says 'a' is at     : ", %all<a>.list.map(*.Int).sort.join(',');

# Output:
#     text                        : banana
#     find-all-palindrome keys    : a ana anana b
#     every palindromic substring : a ana anana b n nan
#     missing from find-all       : n nan
#     
#     'a' occurs at indices       : 1,3,5
#     find-all says 'a' is at     : 1,5
