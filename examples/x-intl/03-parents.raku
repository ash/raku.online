#!/usr/bin/env rakupp
# X::Intl — The one thing to know
# https://raku.online/modules/x-intl/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install X::Intl
#     rakupp 03-parents.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use X::Intl;

class Boom does X::Intl { method message { 'parametros invalidos' } }

say 'Boom ~~ Exception : ', Boom ~~ Exception;
say 'Boom.^parents     : engine-dependent — see below';
say '';
say 'Rakudo reports ("Exception",) there; Raku++ reports ("Any",).';
say 'The smart-match is True on both, which is why this hides — but on';
say 'Raku++ the class does not inherit Exception`s behaviour, so .gist';
say 'falls back to Mu`s object dump instead of showing the message, and';
say 'an uncaught one prints "parametros invalidos\n  (Boom)" rather than';
say 'a backtrace line.';
say '';
say 'test with ~~, never with ^parents, and never rely on .gist:';
my $e = Boom.new;
say '  the portable way to show it : ', $e.message;

# Output:
#     Boom ~~ Exception : True
#     Boom.^parents     : engine-dependent — see below
#     
#     Rakudo reports ("Exception",) there; Raku++ reports ("Any",).
#     The smart-match is True on both, which is why this hides — but on
#     Raku++ the class does not inherit Exception`s behaviour, so .gist
#     falls back to Mu`s object dump instead of showing the message, and
#     an uncaught one prints "parametros invalidos\n  (Boom)" rather than
#     a backtrace line.
#     
#     test with ~~, never with ^parents, and never rely on .gist:
#       the portable way to show it : parametros invalidos
