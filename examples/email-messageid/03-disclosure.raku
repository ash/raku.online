#!/usr/bin/env rakupp
# Email::MessageID — The one thing to know
# https://raku.online/modules/email-messageid/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Email::MessageID
#     rakupp 03-disclosure.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Email::MessageID;

my $id = message-id();
say 'hostname in the identifier : ', $id.split('@')[1] eq $*KERNEL.hostname;
say 'PID in the identifier      : ', $id.split('@')[0].split('.')[2] == $*PID;
say '';
my @stamps = (^200).map({ message-id().split('@')[0].split('.')[0].Int });
say 'the leading field is strictly increasing across 200 draws : ', [<] @stamps;
say '  so a recipient holding two of your messages can order them';
say '  and measure the interval between them';

# Output:
#     hostname in the identifier : True
#     PID in the identifier      : True
#     
#     the leading field is strictly increasing across 200 draws : True
#       so a recipient holding two of your messages can order them
#       and measure the interval between them
