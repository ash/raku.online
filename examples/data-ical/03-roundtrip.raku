#!/usr/bin/env rakupp
# Data::ICal — The one thing to know
# https://raku.online/modules/data-ical/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Data::ICal
#     rakupp 03-roundtrip.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::ICal;

my $with-desc = q:to/END/;
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//Fixture//EN
BEGIN:VEVENT
UID:a
DTSTAMP:20240101T000000Z
DTSTART:20240115T100000Z
DTEND:20240115T110000Z
SUMMARY:A meeting
DESCRIPTION:Line one\nLine two
LOCATION:Room 3
END:VEVENT
END:VCALENDAR
END

my $cal = Data::ICal.new($with-desc);
say 'parsed      : ', $cal.events.elems, ' event';
say 'description : ', $cal.events[0].description.raku;
say '';
my $out = $cal.Str;
say 'LOCATION survives the round trip : ', $out.contains('LOCATION');
my $r = try Data::ICal.new($out);
say 're-parse                         : ', $! ?? $!.message !! 'ok';
say '';
say 'two things go wrong at once. The actions class UNESCAPES \\n into a';
say 'real newline on parse, and Event.Str writes the value back raw —';
say 'producing a second physical line that does not begin with';
say 'whitespace, which the grammar reads as a new property.';
say '';
say 'and Str only emits the ten properties the Event class models:';
say 'LOCATION, CATEGORIES, RRULE, ATTENDEE and everything else are';
say 'silently discarded.';
say '';
say 'strip the description and the round trip is byte-identical:';
my $plain = $with-desc.lines.grep({ !.starts-with('DESCRIPTION') && !.starts-with('LOCATION') }).join("\n") ~ "\n";
my $c2 = Data::ICal.new($plain);
say '  re-parse ok : ', Data::ICal.new($c2.Str).events.elems, ' event';
say '  identical   : ', Data::ICal.new($c2.Str).Str eq $c2.Str;
say '';
say 'so it appears to work on simple fixtures and fails on anything real.';

# Output:
#     parsed      : 1 event
#     description : "Line one\nLine two"
#     
#     LOCATION survives the round trip : False
#     re-parse                         : Need VCALENDAR item
#     
#     two things go wrong at once. The actions class UNESCAPES \n into a
#     real newline on parse, and Event.Str writes the value back raw —
#     producing a second physical line that does not begin with
#     whitespace, which the grammar reads as a new property.
#     
#     and Str only emits the ten properties the Event class models:
#     LOCATION, CATEGORIES, RRULE, ATTENDEE and everything else are
#     silently discarded.
#     
#     strip the description and the round trip is byte-identical:
#       re-parse ok : 1 event
#       identical   : True
#     
#     so it appears to work on simple fixtures and fails on anything real.
