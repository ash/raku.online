#!/usr/bin/env rakupp
# Concurrent::Channelify — Draining a list through a channel
# https://raku.online/modules/concurrent-channelify/#draining-a-list-through-a-channel
#
# Install what it needs, then run it:
#     rakupp install Concurrent::Channelify
#     rakupp 01-channelify.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Concurrent::Channelify;

my @work = 1 .. 8;
my $c = channelify(@work);

say 'channelify returns : ', $c.^name;
say '  isa Channel      : ', $c ~~ Channel;
say '  .no-thread       : ', $c.no-thread;
say '';
my @got = $c.list;
say 'drained (sorted) : ', @got.sort.join(' ');
say 'count            : ', @got.elems;
say '';
say 'a second consumer sees an exhausted channel : ', $c.list.elems, ' items';

# Output:
#     channelify returns : Channel+{<anon|1>}
#       isa Channel      : True
#       .no-thread       : False
#     
#     drained (sorted) : 1 2 3 4 5 6 7 8
#     count            : 8
#     
#     a second consumer sees an exhausted channel : 0 items
