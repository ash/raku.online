#!/usr/bin/env rakupp
# System::Query — Collapsing
# https://raku.online/modules/system-query/#collapsing
#
# Install what it needs, then run it:
#     rakupp install System::Query
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use System::Query;

my %*ENV-SPIKE;   # not used; the module reads the real %*ENV
{
    my %*ENV = SPIKE_MODE => 'blue';
    my %config = %(
        'by-env.SPIKE_MODE' => %( blue => 'chose blue', green => 'chose green' ),
    );
    say 'by-env      : ', system-collapse(%config).raku;

    say 'by-env-exists, set   : ', system-collapse(%(
        'by-env-exists.SPIKE_MODE' => %( yes => 'present', no => 'absent' ))).raku;
    say 'by-env-exists, unset : ', system-collapse(%(
        'by-env-exists.NO_SUCH' => %( yes => 'present', no => 'absent' ))).raku;
    say '';
    say 'a branch with no matching key is a hard die, so give every';
    say 'by-env a catch-all or be sure of the value:';
    my $r = try system-collapse(%( 'by-env.SPIKE_MODE' => %( green => 'only green' ) ));
    say '  no branch for "blue" -> ', $! ?? 'refused' !! $r.raku;
}
say '';
say 'a non-Hash, non-Array value is returned unchanged:';
say '  ', system-collapse('a bare string').raku;
say '  ', system-collapse(42).raku;

# Output:
#     by-env      : "chose blue"
#     by-env-exists, set   : "present"
#     by-env-exists, unset : "absent"
#     
#     a branch with no matching key is a hard die, so give every
#     by-env a catch-all or be sure of the value:
#       no branch for "blue" -> refused
#     
#     a non-Hash, non-Array value is returned unchanged:
#       "a bare string"
#       42
