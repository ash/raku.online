#!/usr/bin/env rakupp
# Color::Scheme — The one thing to know
# https://raku.online/modules/color-scheme/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Color::Scheme
#     rakupp 04-debug-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Color;
use Color::Scheme;

my $dir = $*TMPDIR.add("cs-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

indir $dir, {
    say 'files before : ', $dir.dir.map(*.basename).sort.join(' ') || '(none)';
    my @p = color-scheme(Color.new('#1A3CFA'), 'triadic', :debug);
    say 'palette      : ', @p.map(*.to-string('hex')).join(' ');
    say 'files after  : ', $dir.dir.map(*.basename).sort.join(' ');
    say '';
    my $f = $dir.add('colors.html');
    say 'the file holds a swatch per colour, plus four empty ones:';
    say '  empty background-color rules : ',
        $f.slurp.comb('background-color:;').elems;
}

# Output:
#     files before : (none)
#     palette      : #1A3CFA #FA1A3C #3CFA1A
#     files after  : colors.html
#     
#     the file holds a swatch per colour, plus four empty ones:
#       empty background-color rules : 4
