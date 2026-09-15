#!/usr/bin/env rakupp
# Shareable — The one thing to know
# https://raku.online/modules/shareable/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Shareable
#     rakupp 03-unlink.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Shareable;

class Note is Shareable { has Str $.title }

my $dir = $*TMPDIR.add("shareable2-{$*PID}");
LEAVE { $dir.add('a.store').unlink; $dir.add('b.store').unlink; $dir.rmdir }
$dir.mkdir;
my $a = $dir.add('a.store');
my $b = $dir.add('b.store');

my $n = Note.new(title => 'kept');
$n.to-file($a.Str);
say 'file A written : ', $a.e;
$n.set-store-file($b.Str);
say 'after set-store-file(B):';
say '  store is now : ', $n.show-store.IO.basename;
say '  file A       : ', $a.e ?? 'still there' !! 'GONE';
say '';
say 'the source is  method set-store-file($path) { unlink $storefile;';
say '$storefile = $path }. Nothing in the name suggests a deletion.';
say '';
say 'and the FIRST call in a fresh program unlinks whatever is at';
say '$HOME/.Shareable-store-file, because that is the default. "Point this';
say 'object at my own file" is spelled "delete the shared default store,';
say 'then point at my own file".';

# Output:
#     file A written : True
#     after set-store-file(B):
#       store is now : b.store
#       file A       : still there
#     
#     the source is  method set-store-file($path) { unlink $storefile;
#     $storefile = $path }. Nothing in the name suggests a deletion.
#     
#     and the FIRST call in a fresh program unlinks whatever is at
#     $HOME/.Shareable-store-file, because that is the default. "Point this
#     object at my own file" is spelled "delete the shared default store,
#     then point at my own file".
