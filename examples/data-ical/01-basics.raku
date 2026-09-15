#!/usr/bin/env rakupp
# Data::ICal — Parsing
# https://raku.online/modules/data-ical/#parsing
#
# Install what it needs, then run it:
#     rakupp install Data::ICal
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::ICal;

my $ics = q:to/END/;
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//Fixture//EN
BEGIN:VEVENT
UID:fixture-0001
DTSTAMP:20240101T000000Z
DTSTART:20240115T100000Z
DTEND:20240115T110000Z
SUMMARY:A meeting
STATUS:CONFIRMED
SEQUENCE:0
ORGANIZER;CN=Ada Lovelace:mailto:ada@example.invalid
END:VEVENT
END:VCALENDAR
END

my $cal = Data::ICal.new($ics);
say 'version   : ', $cal.version.raku;
say 'prodid    : ', $cal.prodid.raku;
say 'events    : ', $cal.events.elems;
say '';
my $e = $cal.events[0];
say '  uid     : ', $e.uid.raku;
say '  summary : ', $e.summary.raku;
say '  status  : ', $e.status.raku;
say '  dtstart : ', $e.dtstart;
say '  dtend   : ', $e.dtend;
say '  organizer keys : ', $e.organizer.list.map(*.key).sort.join(', ');

# Output:
#     version   : "2.0"
#     prodid    : "-//Example//Fixture//EN"
#     events    : 1
#     
#       uid     : "fixture-0001"
#       summary : "A meeting"
#       status  : "CONFIRMED"
#       dtstart : 2024-01-15T10:00:00Z
#       dtend   : 2024-01-15T11:00:00Z
#       organizer keys : email, name
