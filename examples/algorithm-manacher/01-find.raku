#!/usr/bin/env rakupp
# Algorithm::Manacher — Finding palindromes
# https://raku.online/modules/algorithm-manacher/#finding-palindromes
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Manacher
#     rakupp 01-find.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Manacher;

sub dump(%h) {
    %h.keys.sort.map({
        "$_ => " ~ (%h{$_} ~~ Positional
            ?? '[' ~ %h{$_}.list.map(*.Int).sort.join(',') ~ ']'
            !! %h{$_}.Int)
    }).join('  ')
}

for 'banana', 'abacaba', 'aabb', 'noon', 'abc' -> $t {
    my $m = Algorithm::Manacher.new(text => $t);
    say "text '$t'";
    say '  is-palindrome           : ', $m.is-palindrome;
    say '  find-longest-palindrome : ', dump($m.find-longest-palindrome);
    say '  find-all-palindrome     : ', dump($m.find-all-palindrome);
}

# Output:
#     text 'banana'
#       is-palindrome           : False
#       find-longest-palindrome : anana => 1
#       find-all-palindrome     : a => [1,5]  ana => [1,3]  anana => 1  b => 0
#     text 'abacaba'
#       is-palindrome           : True
#       find-longest-palindrome : abacaba => 0
#       find-all-palindrome     : a => [0,2,4,6]  aba => [0,4]  abacaba => 0
#     text 'aabb'
#       is-palindrome           : False
#       find-longest-palindrome : aa => 0  bb => 2
#       find-all-palindrome     : a => [0,1]  aa => 0  b => [2,3]  bb => 2
#     text 'noon'
#       is-palindrome           : True
#       find-longest-palindrome : noon => 0
#       find-all-palindrome     : n => [0,3]  noon => 0  o => [1,2]
#     text 'abc'
#       is-palindrome           : False
#       find-longest-palindrome : a => 0  b => 1  c => 2
#       find-all-palindrome     : a => 0  b => 1  c => 2
