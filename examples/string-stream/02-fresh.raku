#!/usr/bin/env rakupp
# String::Stream — Using it
# https://raku.online/modules/string-stream/#using-it
#
# Install what it needs, then run it:
#     rakupp install String::Stream
#     rakupp 02-fresh.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Stream;

my $fresh = String::Stream.new;
say 'a fresh .get : ', $fresh.get.raku, '   (an undefined Str, not "")';
say '';
say '.buffer is a read-only public accessor:';
say '  reading it : ', String::Stream.new('x').buffer.raku;
my $ok = try { $fresh.buffer = 'zap'; True };
say '  writing it : ', $ok ?? 'succeeded' !! 'refused';
say '';
say '.flush exists and its body is EMPTY. It does not clear, drain or';
say 'commit anything — the name implies otherwise:';
my $f = String::Stream.new('');
$f.print('still here');
$f.flush;
say '  after .flush : ', $f.get.raku;

# Output:
#     a fresh .get : Any   (an undefined Str, not "")
#     
#     .buffer is a read-only public accessor:
#       reading it : "x"
#       writing it : refused
#     
#     .flush exists and its body is EMPTY. It does not clear, drain or
#     commit anything — the name implies otherwise:
#       after .flush : "still here"
