#!/usr/bin/env rakupp
# Email::MessageID — Minting an identifier
# https://raku.online/modules/email-messageid/#minting-an-identifier
#
# Install what it needs, then run it:
#     rakupp install Email::MessageID
#     rakupp 01-shape.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Email::MessageID;

my @ids = (^500).map({ message-id() });

say 'exactly one @ in each   : ', ?all(@ids.map({ .comb('@') == 1 }));
say 'no whitespace           : ', ?all(@ids.map({ !/\s/ }));
say 'no angle brackets       : ', ?all(@ids.map({ !/<[<>]>/ }));
say 'distinct over 500 draws : ', @ids.unique.elems == 500;
say '';
my @f = @ids[0].split('@')[0].split('.');
say 'the local part has ', @f.elems, ' dot-separated fields';
say '  field 1 is a timestamp : ', ?so @f[0] ~~ /^ \d+ $/;
say '  field 2 is hex-ish     : ', ?so @f[1] ~~ /^ <[A..Fa..f0..9]>+ $/;
say '  field 3 is this PID    : ', @f[2] == $*PID;
say '  host part is the hostname : ', @ids[0].split('@')[1] eq $*KERNEL.hostname;

# Output:
#     exactly one @ in each   : True
#     no whitespace           : True
#     no angle brackets       : True
#     distinct over 500 draws : True
#     
#     the local part has 3 dot-separated fields
#       field 1 is a timestamp : True
#       field 2 is hex-ish     : True
#       field 3 is this PID    : True
#       host part is the hostname : True
