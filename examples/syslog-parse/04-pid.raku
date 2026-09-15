#!/usr/bin/env rakupp
# Syslog::Parse — Two fields that are always undefined
# https://raku.online/modules/syslog-parse/#two-fields-that-are-always-undefined
#
# Install what it needs, then run it:
#     rakupp install Syslog::Parse
#     rakupp 04-pid.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Syslog::Parse;

my $line = "Jan  3 04:05:06 boxname cron[1234]: a job ran\n";
my $m = Syslog::Grammar.parse($line, actions => Syslog::Grammar::Actions.new);
my %e = $m.made;
say 'the delivered hash:';
say '  pid   : ', %e<pid>.raku;
say '  who   : ', %e<who>.raku;
say '';
say 'but the pid IS in the match — it is thrown away on the way out:';
say '  raw $<actor><pid> : ', $m<actor><pid>.Str.raku;
say '';
say 'the TOP action copies %entry{$key} = $/{$key}.made for pid and who,';
say 'and both are captured INSIDE <actor>, not at the top level. Read them';
say 'from the Match if you need them.';
say '';
say 'there is no range checking either:';
my $wild = Syslog::Grammar.parse("Jan 99 77:88:99 h a: m\n",
                                 actions => Syslog::Grammar::Actions.new);
say '  "Jan 99 77:88:99" parses : ', $wild.defined;

# Output:
#     the delivered hash:
#       pid   : Any
#       who   : Any
#     
#     but the pid IS in the match — it is thrown away on the way out:
#       raw $<actor><pid> : "1234"
#     
#     the TOP action copies %entry{$key} = $/{$key}.made for pid and who,
#     and both are captured INSIDE <actor>, not at the top level. Read them
#     from the Match if you need them.
#     
#     there is no range checking either:
#       "Jan 99 77:88:99" parses : True
