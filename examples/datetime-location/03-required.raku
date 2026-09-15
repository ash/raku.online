#!/usr/bin/env rakupp
# DateTime::Location — The one thing to know
# https://raku.online/modules/datetime-location/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install DateTime::Location
#     rakupp 03-required.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DateTime::Location;

my %coords = lat => 51.4775e0, lon => 0e0, timezone => 0e0;
for ('name only', { name => 'Greenwich' }),
    ('id only',   { id => 'EGLL' }),
    ('both',      { id => 'EGLL', name => 'Heathrow' }),
    ('neither',   { }) -> ($label, $args) {
    my $r = try DateTime::Location.new(|%coords, |$args);
    say sprintf('%-12s -> %s', $label,
                $! ?? $!.message.lines.grep(*.trim).tail.trim !! 'built: ' ~ $r.name);
}
say '';
say 'the guard is an `if not (…defined) { } elsif $!id eq "" { }` chain,';
say 'and an undefined Any `eq ""` is True — so the elsif fires for the';
say 'field you left out. Pass both.';

# Output:
#     name only    -> $id cannot be an empty string
#     id only      -> $name cannot be an empty string
#     both         -> built: Heathrow
#     neither      -> you must define at least one of $id or $name
#     
#     the guard is an `if not (…defined) { } elsif $!id eq "" { }` chain,
#     and an undefined Any `eq ""` is True — so the elsif fires for the
#     field you left out. Pass both.
