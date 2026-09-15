#!/usr/bin/env rakupp
# Data::ICal — Malformed input throws
# https://raku.online/modules/data-ical/#malformed-input-throws
#
# Install what it needs, then run it:
#     rakupp install Data::ICal
#     rakupp 02-failures.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::ICal;

my %cases =
    'empty string'      => '',
    'not ical'          => "hello\n",
    'VCALENDAR only'    => "BEGIN:VCALENDAR\nVERSION:2.0\nEND:VCALENDAR\n",
    'no VERSION'        => "BEGIN:VCALENDAR\nEND:VCALENDAR\n",
    'VERSION 1.0'       => "BEGIN:VCALENDAR\nVERSION:1.0\nEND:VCALENDAR\n",
    'unclosed block'    => "BEGIN:VCALENDAR\nVERSION:2.0\n";

for %cases.keys.sort -> $k {
    my $r = try Data::ICal.new(%cases{$k});
    say sprintf('  %-18s -> %s', $k,
                $! ?? $!.message !! 'ok, ' ~ $r.events.elems ~ ' event(s)');
}
say '';
say 'always an exception, never a Failure or an undefined value — which';
say 'is a better contract than most parsers here offer. Note the';
say 'misleading message for a calendar with no VERSION at all.';
say '';
say 'and :raw returns the bare parse tree rather than an object:';
say '  keys : ', Data::ICal.new(%cases<VCALENDAR only>, :raw).keys.sort.join(', ');

# Output:
#       VCALENDAR only     -> ok, 0 event(s)
#       VERSION 1.0        -> Can only understand VCALENDAR version 2.0
#       empty string       -> Need VCALENDAR item
#       no VERSION         -> Can only understand VCALENDAR version 2.0
#       not ical           -> Need VCALENDAR item
#       unclosed block     -> Need VCALENDAR item
#     
#     always an exception, never a Failure or an undefined value — which
#     is a better contract than most parsers here offer. Note the
#     misleading message for a calendar with no VERSION at all.
#     
#     and :raw returns the bare parse tree rather than an object:
#       keys : 
