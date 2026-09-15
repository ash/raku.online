#!/usr/bin/env rakupp
# Syslog::Parse — Where the two engines differ
# https://raku.online/modules/syslog-parse/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Syslog::Parse
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     the portable half is the grammar. Drive it yourself over .lines and
#     you get the same result on both engines:
#     
#       first
#     
#       second
#     
#     
#     two further reasons to do it this way, both engine-independent: the
#     class default path is /var/log/syslog, which does not exist on macOS,
#     and its multi-line append handling keeps only the newest line —
#     @all-lines is assigned before the count is computed, so the range is
#     always 0 … 0. Under real syslog load it drops most of the traffic.
