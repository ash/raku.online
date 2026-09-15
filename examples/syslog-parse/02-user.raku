#!/usr/bin/env rakupp
# Syslog::Parse — Parsing a line
# https://raku.online/modules/syslog-parse/#parsing-a-line
#
# Install what it needs, then run it:
#     rakupp install Syslog::Parse
#     rakupp 02-user.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Syslog::Parse;

for "Feb 14 10:11:12 boxname sshd: (pam_unix) session opened\n",
    "Apr  9 23:59:59 boxname systemd: (deploy:1000) started unit\n",
    "May 31 12:00:00 boxname su: nothing special\n" -> $line {
    my %e = Syslog::Grammar.parse($line, actions => Syslog::Grammar::Actions.new).made;
    say sprintf('  actor=%-8s user=%-10s message=%s',
                %e<actor>.raku, %e<user>.raku, %e<message>.raku);
}

# Output:
#       actor="sshd"   user="pam_unix" message="(pam_unix) session opened\n"
#       actor="systemd" user="deploy"   message="(deploy:1000) started unit\n"
#       actor="su"     user="∅"        message="nothing special\n"
