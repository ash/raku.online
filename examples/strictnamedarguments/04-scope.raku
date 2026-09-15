#!/usr/bin/env rakupp
# StrictNamedArguments — Where the trait can go, and what leaks
# https://raku.online/modules/strictnamedarguments/#where-the-trait-can-go-and-what-leaks
#
# Install what it needs, then run it:
#     rakupp install StrictNamedArguments
#     rakupp 04-scope.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use StrictNamedArguments;

say 'the trait is constrained to Method, so:';
say '  method         : accepted';
say '  multi method   : accepted';
say '  sub            : refused by Rakudo, accepted by Raku++';
say '  submethod      : refused by Rakudo, accepted by Raku++';
say '';
say 'the difference is that Raku++ reports a `submethod` as a Method and';
say 'ignores unknown `is` traits entirely, so the constraint that stops';
say 'Rakudo never fires there.';
say '';
say 'and the GUARD leaks even where the TRAIT does not: .wrap mutates the';
say 'method object itself, so a class guarded in one compilation unit';
say 'stays guarded when another unit calls it — while `is strict` in that';
say 'other unit is an unknown trait. The exception type lands in GLOBAL as';
say 'X::Parameter::ExtraNamed on both engines, so you can catch it';
say 'anywhere:';
class G { method go(:$a) is strict { $a } }
try G.new.go(:zz);
say '  caught as X::Parameter::ExtraNamed : ', ($! ~~ X::Parameter::ExtraNamed);

# Output:
#     the trait is constrained to Method, so:
#       method         : accepted
#       multi method   : accepted
#       sub            : refused by Rakudo, accepted by Raku++
#       submethod      : refused by Rakudo, accepted by Raku++
#     
#     the difference is that Raku++ reports a `submethod` as a Method and
#     ignores unknown `is` traits entirely, so the constraint that stops
#     Rakudo never fires there.
#     
#     and the GUARD leaks even where the TRAIT does not: .wrap mutates the
#     method object itself, so a class guarded in one compilation unit
#     stays guarded when another unit calls it — while `is strict` in that
#     other unit is an unknown trait. The exception type lands in GLOBAL as
#     X::Parameter::ExtraNamed on both engines, so you can catch it
#     anywhere:
#       caught as X::Parameter::ExtraNamed : True
