#!/usr/bin/env rakupp
# Proc::Easy — The one thing to know
# https://raku.online/modules/proc-easy/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Proc::Easy
#     rakupp 04-no-shell.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Proc::Easy;

say 'plain     : ', run-command('echo hello world', :out).raku;
say 'quoted    : ', run-command(Q[echo 'hello world'], :out).raku;
say 'a glob    : ', run-command('echo *', :out).raku;
say 'a pipe    : ', run-command('echo a | true', :out).raku;
say 'a redirect: ', run-command('echo a > /dev/null', :out).raku;

# Output:
#     plain     : "hello world\n"
#     quoted    : "'hello world'\n"
#     a glob    : "*\n"
#     a pipe    : "a | true\n"
#     a redirect: "a > /dev/null\n"
