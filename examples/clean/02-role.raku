#!/usr/bin/env rakupp
# Clean — What the role enforces
# https://raku.online/modules/clean/#what-the-role-enforces
#
# Install what it needs, then run it:
#     rakupp install Clean
#     rakupp 02-role.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Clean;

say 'the role stubs a clean method, so a class that does not implement it';
say 'is refused at composition time:';
my $r = try EVAL 'use Clean; class NoImpl does Cleanable { }; NoImpl.new';
say '  ', $! ?? 'refused: ' ~ $!.message.lines[0] !! 'composed';

# Output:
#     the role stubs a clean method, so a class that does not implement it
#     is refused at composition time:
#       refused: Method 'clean' must be implemented by NoImpl because it is required by roles: Clean::Cleanable.
