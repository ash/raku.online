#!/usr/bin/env rakupp
# Concurrent::Channelify — What it accepts
# https://raku.online/modules/concurrent-channelify/#what-it-accepts
#
# Install what it needs, then run it:
#     rakupp install Concurrent::Channelify
#     rakupp 03-accepts.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Concurrent::Channelify;

say 'an Array : ', channelify([1, 2, 3]).list.sort.join(' ');
say 'a List   : ', channelify((4, 5, 6)).list.sort.join(' ');
say '';
say ':no-thread runs the producer inline:';
my $n = channelify([1, 2, 3], :no-thread);
say '  .no-thread : ', $n.no-thread;
say '  contents   : ', $n.list.sort.join(' ');
say '';
for 42, 'text', %(a => 1) -> $bad {
    my $r = try channelify($bad);
    say sprintf('  %-6s -> %s', $bad.^name, $! ?? 'refused' !! 'accepted');
}

# Output:
#     an Array : 1 2 3
#     a List   : 4 5 6
#     
#     :no-thread runs the producer inline:
#       .no-thread : True
#       contents   : 1 2 3
#     
#       Int    -> refused
#       Str    -> refused
#       Hash   -> refused
