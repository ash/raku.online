#!/usr/bin/env rakupp
# System::Query — The one thing to know
# https://raku.online/modules/system-query/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install System::Query
#     rakupp 03-wrong-object.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use System::Query;

say 'the module`s own line is:';
say '  my $PTR   = $/[0] eq "distro" ?? $*DISTRO !! … !! $*BACKEND;';
say '  my $value = follower($path, 1, $*DISTRO);   # $PTR discarded';
say '';
my %by-kernel-real = %( "by-kernel.name" => %( $*KERNEL.name => 'kernel branch' ) );
my $r = try system-collapse(%by-kernel-real);
say 'by-kernel keyed on the real kernel name : ',
    $! ?? 'FAILS — no such value in $*DISTRO' !! $r.raku;
say '';
my %by-kernel-distro = %( "by-kernel.name" => %( $*DISTRO.name => 'distro branch' ) );
say 'by-kernel keyed on the DISTRO name      : ',
    system-collapse(%by-kernel-distro).raku;
say '';
say 'so a config keyed on the real kernel fails, and one keyed on the';
say 'distro silently satisfies a by-kernel query. Where the two names';
say 'happen to coincide you get a silently wrong answer, not a crash.';
say '';
say 'use by-distro, and say what you mean.';

# Output:
#     the module`s own line is:
#       my $PTR   = $/[0] eq "distro" ?? $*DISTRO !! … !! $*BACKEND;
#       my $value = follower($path, 1, $*DISTRO);   # $PTR discarded
#     
#     by-kernel keyed on the real kernel name : FAILS — no such value in $*DISTRO
#     
#     by-kernel keyed on the DISTRO name      : "distro branch"
#     
#     so a config keyed on the real kernel fails, and one keyed on the
#     distro silently satisfies a by-kernel query. Where the two names
#     happen to coincide you get a silently wrong answer, not a crash.
#     
#     use by-distro, and say what you mean.
