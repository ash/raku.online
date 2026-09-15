#!/usr/bin/env rakupp
# Swedish::TextDates_sv — The one thing to know
# https://raku.online/modules/swedish-textdates-sv/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Swedish::TextDates_sv
#     rakupp 04-exit.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Swedish::TextDates_sv;

say 'about to ask for 2017-02-30, which does not exist.';
say 'if you see the line after this one, the module did not abort.';
say '';
say '(it does abort. `try`, CATCH and LEAVE are all powerless — this is';
say 'exit, not an exception, and the status is 0, so a shell script or a';
say 'CI job sees a clean run with truncated output.)';
say '';
say 'validate before you call:';
for '2017-02-30', '2017-13-01', '2020-02-29' -> $s {
    my ($y, $m, $d) = $s.split('-')>>.Int;
    my $ok = try { Date.new($y, $m, $d); True };
    say sprintf('  %-12s %s', $s, $ok ?? 'a real date' !! 'refuse it yourself');
}

# Output:
#     about to ask for 2017-02-30, which does not exist.
#     if you see the line after this one, the module did not abort.
#     
#     (it does abort. `try`, CATCH and LEAVE are all powerless — this is
#     exit, not an exception, and the status is 0, so a shell script or a
#     CI job sees a clean run with truncated output.)
#     
#     validate before you call:
#       2017-02-30   refuse it yourself
#       2017-13-01   refuse it yourself
#       2020-02-29   a real date
