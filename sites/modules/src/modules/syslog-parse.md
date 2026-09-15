---
name: Syslog::Parse
version: 0.0.3
auth: zef:jjmerelo
kind: Distribution · log parsing
summary: An RFC 3164 syslog grammar and a Supply that follows a growing file —
  with two months of the year missing from the grammar.
status: divergent
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:jjmerelo/Syslog::Parse
source: https://github.com/JJ/raku-syslog-parse.git
---

## What it is for

A syslog line is `Mon  3 04:05:06 host actor[pid]: message`. Turning that into
fields is the first step of any log analysis, and this distribution does it
with a grammar plus actions, handing back a plain `Hash`.

It also wraps that in a class that watches a file and emits parsed entries on
a `Supply` as the file grows.

## Parsing a line

```raku name="basics"
use Syslog::Parse;

my $line = "Jan  3 04:05:06 boxname cron: a job ran\n";
my $m = Syslog::Grammar.parse($line, actions => Syslog::Grammar::Actions.new);
my %e = $m.made;
for %e.keys.sort -> $k { say sprintf('  %-10s %s', $k, %e{$k}.raku) }
say '';
say 'day comes back as an Int, hour as a Str, and `user` is the literal';
say '"∅" when the message carries no (name) prefix.';
```

```output
  actor      "cron"
  day        3
  hostname   "boxname"
  hour       "04:05:06"
  message    "a job ran\n"
  month      "Jan"
  pid        Any
  user       "∅"
  who        Any

day comes back as an Int, hour as a Str, and `user` is the literal
"∅" when the message carries no (name) prefix.
```

```raku name="user"
use Syslog::Parse;

for "Feb 14 10:11:12 boxname sshd: (pam_unix) session opened\n",
    "Apr  9 23:59:59 boxname systemd: (deploy:1000) started unit\n",
    "May 31 12:00:00 boxname su: nothing special\n" -> $line {
    my %e = Syslog::Grammar.parse($line, actions => Syslog::Grammar::Actions.new).made;
    say sprintf('  actor=%-8s user=%-10s message=%s',
                %e<actor>.raku, %e<user>.raku, %e<message>.raku);
}
```

```output
  actor="sshd"   user="pam_unix" message="(pam_unix) session opened\n"
  actor="systemd" user="deploy"   message="(deploy:1000) started unit\n"
  actor="su"     user="∅"        message="nothing special\n"
```

## The one thing to know

June and July log lines never parse. The `month` token is missing one
alternation bar.

```raku name="june"
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
```

```output
  Jan : parses
  Feb : parses
  Mar : parses
  Apr : parses
  May : parses
  Jun : NO PARSE
  Jul : NO PARSE
  Aug : parses
  Sep : parses
  Oct : parses
  Nov : parses
  Dec : parses

and the string the grammar DOES accept in their place:
  JunJul : parses

the token reads
  [ "Jan"| "Feb" | … | "May" | "Jun"
   "Jul" | "Aug" | … ]
so "Jun" "Jul" is a CONCATENATION. Two months of every year are
invisible, and a .parse that returns Nil is easy to mistake for
"nothing new in the log".
```

## Two fields that are always undefined

```raku name="pid"
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
```

```output
the delivered hash:
  pid   : Any
  who   : Any

but the pid IS in the match — it is thrown away on the way out:
  raw $<actor><pid> : "1234"

the TOP action copies %entry{$key} = $/{$key}.made for pid and who,
and both are captured INSIDE <actor>, not at the top level. Read them
from the Match if you need them.

there is no range checking either:
  "Jan 99 77:88:99" parses : True
```

## Where the two engines differ

The `Syslog::Parse` class itself cannot be constructed under Raku++:
`IO::Notification` is an empty stub there, with no `watch-path`. The grammar
and actions — which is where the value is — work identically on both, and
that is why the four-file suite is green on Raku++.

```raku name="portable"
use Syslog::Parse;

say 'the portable half is the grammar. Drive it yourself over .lines and';
say 'you get the same result on both engines:';
say '';
my $fixture = $*TMPDIR.add("syslog-{$*PID}.log");
LEAVE $fixture.unlink;
$fixture.spurt(qq:to/END/);
Jan  3 04:05:06 boxname app: first
Jan  3 04:05:07 boxname app: second
END

my $actions = Syslog::Grammar::Actions.new;
for $fixture.lines -> $line {
    my $m = Syslog::Grammar.parse("$line\n", :$actions);
    next unless $m;
    say '  ', $m.made<message>;
}
say '';
say 'two further reasons to do it this way, both engine-independent: the';
say 'class default path is /var/log/syslog, which does not exist on macOS,';
say 'and its multi-line append handling keeps only the newest line —';
say '@all-lines is assigned before the count is computed, so the range is';
say 'always 0 … 0. Under real syslog load it drops most of the traffic.';
```

```output
the portable half is the grammar. Drive it yourself over .lines and
you get the same result on both engines:

  first

  second


two further reasons to do it this way, both engine-independent: the
class default path is /var/log/syslog, which does not exist on macOS,
and its multi-line append handling keeps only the newest line —
@all-lines is assigned before the count is computed, so the range is
always 0 … 0. Under real syslog load it drops most of the traffic.
```

One more, worth a thought before you point this at CRLF input: a line-ending
difference changes which grammar branch wins under Raku++, and RFC 5424
mandates CRLF. Normalise to `\n` first.
