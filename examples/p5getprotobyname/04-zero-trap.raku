#!/usr/bin/env rakupp
# P5getprotobyname — The one thing to know
# https://raku.online/modules/p5getprotobyname/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5getprotobyname
#     rakupp 04-zero-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5getprotobyname;

my $ip   = getprotobyname(Scalar, 'ip');
my $miss = getprotobyname(Scalar, 'nosuchproto-xyzzy');

say "'ip' is IANA protocol number 0:";
say '  value   : ', $ip;
say '  Bool    : ', ?$ip;
say '  defined : ', $ip.defined;
say '';
say 'a genuine miss:';
say '  value   : ', $miss.defined ?? $miss !! '(undefined)';
say '  Bool    : ', ?$miss;
say '  defined : ', $miss.defined;
say '';
say 'so the two are indistinguishable by truthiness.';
say 'the working guard is .defined, or //';

# Output:
#     'ip' is IANA protocol number 0:
#       value   : 0
#       Bool    : False
#       defined : True
#     
#     a genuine miss:
#       value   : (undefined)
#       Bool    : False
#       defined : False
#     
#     so the two are indistinguishable by truthiness.
#     the working guard is .defined, or //
