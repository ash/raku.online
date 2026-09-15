#!/usr/bin/env rakupp
# Data::ICal — Where the two engines differ
# https://raku.online/modules/data-ical/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Data::ICal
#     rakupp 05-crlf.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     LF input   : 1 event(s)
#     CRLF input : engine-dependent — 1 on Rakudo, 0 on Raku++, and no
#                  exception either way
#     
#     Raku++`s longest-token alternation parses BEGIN:VEVENT as a PROPERTY
#     named BEGIN rather than taking the nested section branch, so the
#     calendar comes back with zero events and no exception.
#     
#     normalise first, on both engines:
#       parse-ics(CRLF) : 1 event(s)
#       summary         : "A meeting"
