#!/usr/bin/env rakupp
# System::Query — Where the two engines differ
# https://raku.online/modules/system-query/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install System::Query
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use System::Query;

say 'the shapes that behave identically on both engines:';
say '  by-env.NAME          with an explicit "" catch-all';
say '  by-distro.name       keyed on $*DISTRO.name';
say '  by-distro.version    with a + or - suffix on every key';
say '';
say 'the ones to avoid:';
say '  by-kernel / by-backend  — they read $*DISTRO';
say '  an exact version key with no suffix — dies on Rakudo';
say '  a "" catch-all on a Version-valued path — substr(*-1) on "" throws';
say '  two by-* keys in one hash — order decides, and order varies';
say '';
my %safe = %( "by-distro.name" => %( $*DISTRO.name => 'match', '' => 'fallback' ) );
say 'a safe config collapses the same way everywhere : ',
    system-collapse(%safe).raku;

# Output:
#     the shapes that behave identically on both engines:
#       by-env.NAME          with an explicit "" catch-all
#       by-distro.name       keyed on $*DISTRO.name
#       by-distro.version    with a + or - suffix on every key
#     
#     the ones to avoid:
#       by-kernel / by-backend  — they read $*DISTRO
#       an exact version key with no suffix — dies on Rakudo
#       a "" catch-all on a Version-valued path — substr(*-1) on "" throws
#       two by-* keys in one hash — order decides, and order varies
#     
#     a safe config collapses the same way everywhere : "match"
