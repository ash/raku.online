#!/usr/bin/env rakupp
# StrictNamedArguments — Using it
# https://raku.online/modules/strictnamedarguments/#using-it
#
# Install what it needs, then run it:
#     rakupp install StrictNamedArguments
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use StrictNamedArguments;

class Plain   { method go(:$a) { "plain a=" ~ $a.raku } }
class Guarded { method go(:$a) is strict { "guard a=" ~ $a.raku } }

say 'plain,   good named  : ', Plain.new.go(a => 1);
say 'plain,   EXTRA named : ', Plain.new.go(a => 1, bogus => 2), '   <- swallowed';
say 'guarded, good named  : ', Guarded.new.go(a => 1);
my $r = try Guarded.new.go(a => 1, bogus => 2);
say 'guarded, EXTRA named : ', $! ?? 'refused' !! $r;
say '';
say 'the exception carries the detail:';
try Guarded.new.go(a => 1, bogus => 2);
say '  class           : ', $!.^name.subst('StrictNamedArguments::', '');
say '  extra-parameters: ', $!.extra-parameters.keys.sort.join(', ');
say '  method-name     : ', $!.method-name;

# Output:
#     plain,   good named  : plain a=1
#     plain,   EXTRA named : plain a=1   <- swallowed
#     guarded, good named  : guard a=1
#     guarded, EXTRA named : refused
#     
#     the exception carries the detail:
#       class           : X::Parameter::ExtraNamed
#       extra-parameters: bogus
#       method-name     : go
