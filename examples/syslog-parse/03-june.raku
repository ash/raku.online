#!/usr/bin/env rakupp
# Syslog::Parse — The one thing to know
# https://raku.online/modules/syslog-parse/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Syslog::Parse
#     rakupp 03-june.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Syslog::Parse;

sub parses($mon) {
    my $line = "$mon  3 04:05:06 boxname cron: a job ran\n";
    Syslog::Grammar.parse($line, actions => Syslog::Grammar::Actions.new).defined
}

for <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec> -> $m {
    say sprintf('  %s : %s', $m, parses($m) ?? 'parses' !! 'NO PARSE');
}
say '';
say 'and the string the grammar DOES accept in their place:';
say '  JunJul : ', parses('JunJul') ?? 'parses' !! 'no parse';
say '';
say 'the token reads';
say '  [ "Jan"| "Feb" | … | "May" | "Jun"';
say '   "Jul" | "Aug" | … ]';
say 'so "Jun" "Jul" is a CONCATENATION. Two months of every year are';
say 'invisible, and a .parse that returns Nil is easy to mistake for';
say '"nothing new in the log".';

# Output:
#       Jan : parses
#       Feb : parses
#       Mar : parses
#       Apr : parses
#       May : parses
#       Jun : NO PARSE
#       Jul : NO PARSE
#       Aug : parses
#       Sep : parses
#       Oct : parses
#       Nov : parses
#       Dec : parses
#     
#     and the string the grammar DOES accept in their place:
#       JunJul : parses
#     
#     the token reads
#       [ "Jan"| "Feb" | … | "May" | "Jun"
#        "Jul" | "Aug" | … ]
#     so "Jun" "Jul" is a CONCATENATION. Two months of every year are
#     invisible, and a .parse that returns Nil is easy to mistake for
#     "nothing new in the log".
