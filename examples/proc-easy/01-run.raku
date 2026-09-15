#!/usr/bin/env rakupp
# Proc::Easy — Running a command
# https://raku.online/modules/proc-easy/#running-a-command
#
# Install what it needs, then run it:
#     rakupp install Proc::Easy
#     rakupp 01-run.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Proc::Easy;

my ($exit, $err, $out) = run-command('echo hello');
say 'exit : ', $exit;
say 'err  : ', $err.raku;
say 'out  : ', $out.raku;
say '';
say 'true  -> exit ', run-command('true',  :exit);
say 'false -> exit ', run-command('false', :exit);

# Output:
#     exit : 0
#     err  : ""
#     out  : "hello\n"
#     
#     true  -> exit 0
#     false -> exit 1
