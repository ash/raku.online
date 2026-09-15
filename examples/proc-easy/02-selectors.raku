#!/usr/bin/env rakupp
# Proc::Easy — Asking for one of them
# https://raku.online/modules/proc-easy/#asking-for-one-of-them
#
# Install what it needs, then run it:
#     rakupp install Proc::Easy
#     rakupp 02-selectors.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Proc::Easy;

say ':out alone : ', run-command('echo one two', :out).raku;
say ':err alone : ', run-command('echo one two', :err).raku;
say ':exit alone: ', run-command('echo one two', :exit);
say '';
say 'the flags are checked in the order exit, err, out,';
say 'and the FIRST one set wins — they do not combine:';
say '  :out and :err together : ', run-command('echo x', :out, :err).raku;
say '  all three together     : ', run-command('echo x', :out, :err, :exit).raku;

# Output:
#     :out alone : "one two\n"
#     :err alone : ""
#     :exit alone: 0
#     
#     the flags are checked in the order exit, err, out,
#     and the FIRST one set wins — they do not combine:
#       :out and :err together : ""
#       all three together     : 0
