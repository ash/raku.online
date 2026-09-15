#!/usr/bin/env rakupp
# X::Intl — Composing it
# https://raku.online/modules/x-intl/#composing-it
#
# Install what it needs, then run it:
#     rakupp install X::Intl
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use X::Intl;

class X::Bad::Locale does X::Intl {
    has Str $.tag;
    method message { "unusable locale tag: $!tag" }
}

my $e = X::Bad::Locale.new(tag => 'xx-YY-zz');
say 'message        : ', $e.message;
say '~~ X::Intl     : ', $e ~~ X::Intl;
say '~~ Exception   : ', $e ~~ Exception;
say '';
my $caught = try { $e.throw };
say 'caught as X::Intl : ', $! ~~ X::Intl;
say '  its message     : ', $!.message;
say '';
say 'that is the whole use case, and it works on both engines.';

# Output:
#     message        : unusable locale tag: xx-YY-zz
#     ~~ X::Intl     : True
#     ~~ Exception   : True
#     
#     caught as X::Intl : True
#       its message     : unusable locale tag: xx-YY-zz
#     
#     that is the whole use case, and it works on both engines.
