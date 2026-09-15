---
name: Data::ICal
version: 1.0.0
auth: github:retupmoca
kind: Distribution · data formats
summary: Parses an .ics calendar into events with DateTimes — and cannot read
  back what it writes.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/github:retupmoca/Data::ICal
source: git://github.com/retupmoca/P6-iCal.git
---

## What it is for

An `.ics` file is what a calendar invitation is. Reading one — to import
events, to check a schedule, to extract attendees — means a small grammar over
`BEGIN:VEVENT` blocks and their folded property lines.

This distribution parses that into a `Data::ICal` holding version, prodid,
events and timezones, and can stringify the object back.

## Parsing

```raku name="basics"
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
```

```output
version   : "2.0"
prodid    : "-//Example//Fixture//EN"
events    : 1

  uid     : "fixture-0001"
  summary : "A meeting"
  status  : "CONFIRMED"
  dtstart : 2024-01-15T10:00:00Z
  dtend   : 2024-01-15T11:00:00Z
  organizer keys : email, name
```

`dtstart` and `dtend` resolve `TZID` through the calendar's own `VTIMEZONE`
rules and hand you a `DateTime`; `dtstart-raw` gives you the pair as parsed.

## Malformed input throws

```raku name="failures"
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
```

```output
  VCALENDAR only     -> ok, 0 event(s)
  VERSION 1.0        -> Can only understand VCALENDAR version 2.0
  empty string       -> Need VCALENDAR item
  no VERSION         -> Can only understand VCALENDAR version 2.0
  not ical           -> Need VCALENDAR item
  unclosed block     -> Need VCALENDAR item

always an exception, never a Failure or an undefined value — which
is a better contract than most parsers here offer. Note the
misleading message for a calendar with no VERSION at all.

and :raw returns the bare parse tree rather than an object:
  keys : 
```

## The one thing to know

`Data::ICal.new($cal.Str)` does not work: the module cannot read back what it
writes.

```raku name="roundtrip"
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
```

```output
parsed      : 1 event
description : "Line one\nLine two"

LOCATION survives the round trip : False
re-parse                         : Need VCALENDAR item

two things go wrong at once. The actions class UNESCAPES \n into a
real newline on parse, and Event.Str writes the value back raw —
producing a second physical line that does not begin with
whitespace, which the grammar reads as a new property.

and Str only emits the ten properties the Event class models:
LOCATION, CATEGORIES, RRULE, ATTENDEE and everything else are
silently discarded.

strip the description and the round trip is byte-identical:
  re-parse ok : 1 event
  identical   : True

so it appears to work on simple fixtures and fails on anything real.
```

## Four units that are empty files

```raku name="empty-units"
use Data::ICal;

say 'the distribution declares eight units. Four of them —';
say 'Data::ICal::Alarm, ::FreeBusy, ::Journal and ::Todo — are';
say 'ZERO-BYTE files.';
say '';
say '`use Data::ICal::Alarm;` succeeds and declares nothing; referring to';
say 'the name is an error on both engines (at run time on Raku++, at';
say 'compile time on Rakudo).';
say '';
say 'introspection tools that report "class Data::ICal::Alarm with no';
say 'methods" are showing you an artefact of a dynamic lookup, not a fact';
say 'about the distribution.';
say '';
say 'and Data::ICal.Str hard-codes VERSION:2.0 regardless of $.version.';
```

```output
the distribution declares eight units. Four of them —
Data::ICal::Alarm, ::FreeBusy, ::Journal and ::Todo — are
ZERO-BYTE files.

`use Data::ICal::Alarm;` succeeds and declares nothing; referring to
the name is an error on both engines (at run time on Raku++, at
compile time on Rakudo).

introspection tools that report "class Data::ICal::Alarm with no
methods" are showing you an artefact of a dynamic lookup, not a fact
about the distribution.

and Data::ICal.Str hard-codes VERSION:2.0 regardless of $.version.
```

## Where the two engines differ

CRLF input loses every event under Raku++, and RFC 5545 **requires** CRLF.

```raku name="crlf"
use Data::ICal;

my $lf = "BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nUID:a\nSUMMARY:A meeting\n"
       ~ "END:VEVENT\nEND:VCALENDAR\n";
my $crlf = $lf.subst("\n", "\r\n", :g);

say 'LF input   : ', Data::ICal.new($lf).events.elems, ' event(s)';
say 'CRLF input : engine-dependent — 1 on Rakudo, 0 on Raku++, and no';
say '             exception either way';
say '';
say 'Raku++`s longest-token alternation parses BEGIN:VEVENT as a PROPERTY';
say 'named BEGIN rather than taking the nested section branch, so the';
say 'calendar comes back with zero events and no exception.';
say '';
say 'normalise first, on both engines:';
sub parse-ics(Str $text) { Data::ICal.new($text.subst(/\r\n/, "\n", :g)) }
say '  parse-ics(CRLF) : ', parse-ics($crlf).events.elems, ' event(s)';
say '  summary         : ', parse-ics($crlf).events[0].summary.raku;
```

```output
LF input   : 1 event(s)
CRLF input : engine-dependent — 1 on Rakudo, 0 on Raku++, and no
             exception either way

Raku++`s longest-token alternation parses BEGIN:VEVENT as a PROPERTY
named BEGIN rather than taking the nested section branch, so the
calendar comes back with zero events and no exception.

normalise first, on both engines:
  parse-ics(CRLF) : 1 event(s)
  summary         : "A meeting"
```
