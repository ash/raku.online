#!/usr/bin/env rakupp
# Acme::Scrub — What it does to a file
# https://raku.online/modules/acme-scrub/#what-it-does-to-a-file
#
# Install what it needs, then run it:
#     rakupp install Acme::Scrub
#     rakupp 01-scrub.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

my $dir = $*TMPDIR.add("scrub-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

my $prog = $dir.add('demo.raku');
$prog.spurt: q:to/SRC/;
use Acme::Scrub;
say "hello from the original source";
say "answer: ", 6 * 7;
SRC

say 'before : ', $prog.s, ' bytes, ', $prog.slurp.lines.elems, ' lines';
say '';
say 'run 1:';
say '  ', run($*EXECUTABLE, $prog.Str, :out).out.slurp(:close).trim.lines.join(' / ');
say '';
say 'after  : ', $prog.s, ' bytes';
say '  the visible text is now : ', $prog.slurp.subst(/<:Cf>/, '', :g).trim.raku;
say '';
say 'run 2, from the scrubbed file:';
say '  ', run($*EXECUTABLE, $prog.Str, :out).out.slurp(:close).trim.lines.join(' / ');

# Output:
#     before : 78 bytes, 3 lines
#     
#     run 1:
#       hello from the original source / answer: 42
#     
#     after  : 1529 bytes
#       the visible text is now : "use Acme::Scrub; # for REALLY clean code."
#     
#     run 2, from the scrubbed file:
#       hello from the original source / answer: 42
