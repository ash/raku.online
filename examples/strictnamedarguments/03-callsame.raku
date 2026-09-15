#!/usr/bin/env rakupp
# StrictNamedArguments — The one thing to know
# https://raku.online/modules/strictnamedarguments/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install StrictNamedArguments
#     rakupp 03-callsame.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use StrictNamedArguments;

class B { method g(:$a) is strict { "B a=" ~ $a.raku } }
class D is B { method g(:$a) is strict { "D(" ~ (callsame() // 'Nil') ~ ")" } }
class E is B { }

say 'inheritance without an override is fine:';
say '  E.new.g(a => 2) -> ', E.new.g(a => 2);
say '';
say 'overriding and calling callsame is not:';
say '  D.new.g(a => 1) -> B.g never runs, on either engine';
say '  (Rakudo returns D(Nil); Raku++ recurses until X::Recursion)';
say '';
say 'the wrapper`s callwith(self, |args) destroys the dispatch chain.';
say 'Rakudo returns Nil from callsame — a silent wrong answer — and';
say 'Raku++ loops until X::Recursion. Neither tells you the trait is the';
say 'cause. Do not put `is strict` on a method that delegates upward.';

# Output:
#     inheritance without an override is fine:
#       E.new.g(a => 2) -> B a=2
#     
#     overriding and calling callsame is not:
#       D.new.g(a => 1) -> B.g never runs, on either engine
#       (Rakudo returns D(Nil); Raku++ recurses until X::Recursion)
#     
#     the wrapper`s callwith(self, |args) destroys the dispatch chain.
#     Rakudo returns Nil from callsame — a silent wrong answer — and
#     Raku++ loops until X::Recursion. Neither tells you the trait is the
#     cause. Do not put `is strict` on a method that delegates upward.
