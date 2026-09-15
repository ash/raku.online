#!/usr/bin/env rakupp
# Term::Size — Asking
# https://raku.online/modules/term-size/#asking
#
# Install what it needs, then run it:
#     rakupp install Term::Size
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Term::Size;

my $ts = Term::Size.new;
my $ok = $ts.populate;

say 'STDOUT is a tty : ', $*OUT.t;
say 'populate failed : ', ($ok ~~ Failure).so;
say '  message       : ', ($ok ~~ Failure) ?? $ok.exception.message !! '(none)';
say '';
for <term-width-cells term-height-cells term-width-px term-height-px
     cell-width-px cell-height-px> -> $m {
    say sprintf('  %-18s %s', $m, $ts."$m"());
}
say '';
say 'this page is built with no controlling terminal, so every value is 0';
say 'and populate returns a Failure. On a real terminal the same six';
say 'accessors answer the window size.';

# Output:
#     STDOUT is a tty : False
#     populate failed : True
#       message       : Failed to get term size
#     
#       term-width-cells   0
#       term-height-cells  0
#       term-width-px      0
#       term-height-px     0
#       cell-width-px      0
#       cell-height-px     0
#     
#     this page is built with no controlling terminal, so every value is 0
#     and populate returns a Failure. On a real terminal the same six
#     accessors answer the window size.
