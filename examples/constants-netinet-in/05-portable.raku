#!/usr/bin/env rakupp
# Constants::Netinet::In — Where the two engines differ
# https://raku.online/modules/constants-netinet-in/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Constants::Netinet::In
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Constants::Netinet::In :IP, :IPPROTO;

# call each Block once, keep the enum, and read names from it
my $IP    = IP.(Any);
my $PROTO = IPPROTO.(Any);

sub ip-option(Str $name) {
    $IP.enums{$name} // die "no IP option named $name on {$*KERNEL.name}"
}
say 'ip-option("ADD_MEMBERSHIP") = ', ip-option('ADD_MEMBERSHIP');
my $e = try ip-option('NO_SUCH_OPTION');
say 'ip-option("NO_SUCH_OPTION") = ', $! ?? $!.message !! 'found';
say '';
say 'the enum VALUES are never exported bare — even where the branch';
say 'works you get only the two type names, and ADD_MEMBERSHIP on its own';
say 'is never in scope.';
say '';
say 'the distribution is not in the zef index; it resolves from the REA';
say 'archive, whose index path carries no checksum.';

# Output:
#     ip-option("ADD_MEMBERSHIP") = 12
#     ip-option("NO_SUCH_OPTION") = no IP option named NO_SUCH_OPTION on darwin
#     
#     the enum VALUES are never exported bare — even where the branch
#     works you get only the two type names, and ADD_MEMBERSHIP on its own
#     is never in scope.
#     
#     the distribution is not in the zef index; it resolves from the REA
#     archive, whose index path carries no checksum.
