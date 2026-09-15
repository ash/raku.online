#!/usr/bin/env rakupp
# DirsOfInterest — The getter that writes to disk
# https://raku.online/modules/dirsofinterest/#the-getter-that-writes-to-disk
#
# Install what it needs, then run it:
#     rakupp install DirsOfInterest
#     rakupp 04-ensure.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DirsOfInterest;

my $base = $*TMPDIR.add("doi-{$*PID}");
LEAVE { $base.add('demo/1.2').rmdir; $base.add('demo').rmdir; $base.rmdir }
$base.mkdir;

my $d = DirsOfInterest.new(app-name => 'demo', app-version => '1.2',
                           ensure-exists => True);
my $made = $d.append-stuff($base);
say 'append-stuff returned : …/', $made.parent.basename, '/', $made.basename;
say 'it exists on disk     : ', $made.d;
say '';
say ':ensure-exists silently mkdirs as a side effect of a GETTER. Asking';
say 'where a file should go creates the directory.';

# Output:
#     append-stuff returned : …/demo/1.2
#     it exists on disk     : True
#     
#     :ensure-exists silently mkdirs as a side effect of a GETTER. Asking
#     where a file should go creates the directory.
