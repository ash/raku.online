#!/usr/bin/env rakupp
# Clean — The one thing to know
# https://raku.online/modules/clean/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Clean
#     rakupp 03-exception-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Clean;

class Resource does Cleanable {
    has Str  $.name;
    has Bool $.released is rw = False;
    method clean() { $!released = True }
}

my $a = Resource.new(name => 'A');
try { clean $a, -> $o { die 'boom inside the block' } };
say 'the block died, and A was released : ', $a.released;
say '';
say 'the same shape written with a real LEAVE phaser:';
my $b = Resource.new(name => 'B');
try {
    sub scoped(Resource $o, &blk) { LEAVE $o.clean; blk($o) }
    scoped $b, -> $o { die 'boom inside the block' };
}
say '  B was released : ', $b.released;

# Output:
#     the block died, and A was released : False
#     
#     the same shape written with a real LEAVE phaser:
#       B was released : True
