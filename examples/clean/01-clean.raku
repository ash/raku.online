#!/usr/bin/env rakupp
# Clean — The convention
# https://raku.online/modules/clean/#the-convention
#
# Install what it needs, then run it:
#     rakupp install Clean
#     rakupp 01-clean.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Clean;

class TempResource does Cleanable {
    has Str  $.name;
    has Bool $.open is rw = True;
    method clean() { $!open = False; say "  clean: released $!name" }
}

my $r = TempResource.new(name => 'socket-7');
say 'before : open=', $r.open;
clean $r, -> $o { say "  block sees {$o.name}, open={$o.open}" };
say 'after  : open=', $r.open;

# Output:
#     before : open=True
#       block sees socket-7, open=True
#       clean: released socket-7
#     after  : open=False
