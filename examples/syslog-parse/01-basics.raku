#!/usr/bin/env rakupp
# Syslog::Parse — Parsing a line
# https://raku.online/modules/syslog-parse/#parsing-a-line
#
# Install what it needs, then run it:
#     rakupp install Syslog::Parse
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Syslog::Parse;

my $line = "Jan  3 04:05:06 boxname cron: a job ran\n";
my $m = Syslog::Grammar.parse($line, actions => Syslog::Grammar::Actions.new);
my %e = $m.made;
for %e.keys.sort -> $k { say sprintf('  %-10s %s', $k, %e{$k}.raku) }
say '';
say 'day comes back as an Int, hour as a Str, and `user` is the literal';
say '"∅" when the message carries no (name) prefix.';

# Output:
#       actor      "cron"
#       day        3
#       hostname   "boxname"
#       hour       "04:05:06"
#       message    "a job ran\n"
#       month      "Jan"
#       pid        Any
#       user       "∅"
#       who        Any
#     
#     day comes back as an Int, hour as a Str, and `user` is the literal
#     "∅" when the message carries no (name) prefix.
