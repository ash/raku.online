#!/usr/bin/env rakupp
# System::Query — Collapsing
# https://raku.online/modules/system-query/#collapsing
#
# Install what it needs, then run it:
#     rakupp install System::Query
#     rakupp 02-distro.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use System::Query;

say 'the reference points on this machine:';
say '  $*DISTRO.name = ', $*DISTRO.name;
say '  $*KERNEL.name = ', $*KERNEL.name;
say '';
my %config = %( "by-distro.name" => %( $*DISTRO.name => 'the distro branch',
                                       ''           => 'fallback' ) );
say 'by-distro.name : ', system-collapse(%config).raku;
say '';
say "the '' key is a catch-all, and version keys take a + or - suffix:";
my %ver = %( 'by-distro.version' => %( '0.0.1+' => 'at least 0.0.1' ) );
say 'by-distro.version : ', system-collapse(%ver).raku;

# Output:
#     the reference points on this machine:
#       $*DISTRO.name = macos
#       $*KERNEL.name = darwin
#     
#     by-distro.name : "the distro branch"
#     
#     the '' key is a catch-all, and version keys take a + or - suffix:
#     by-distro.version : "at least 0.0.1"
