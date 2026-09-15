#!/usr/bin/env rakupp
# String::Stream — The one thing to know
# https://raku.online/modules/string-stream/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install String::Stream
#     rakupp 03-capture.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Stream;

my $cap = String::Stream.new('');
{
    my $*OUT = $cap;
    say 'captured line';
    print 'captured print';
}
say 'nothing in the class advertises this.';
say '';
say 'what the capture holds:';
say '  ', $cap.get.raku;
say '';
say 'core say/print only need .print and .say on the handle, and this';
say 'class happens to have both. No role, no inheritance, no IO::Handle.';

# Output:
#     nothing in the class advertises this.
#     
#     what the capture holds:
#       "captured line\ncaptured print"
#     
#     core say/print only need .print and .say on the handle, and this
#     class happens to have both. No role, no inheritance, no IO::Handle.
