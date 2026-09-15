#!/usr/bin/env rakupp
# Pod::Tangle — Tangling
# https://raku.online/modules/pod-tangle/#tangling
#
# Install what it needs, then run it:
#     rakupp install Pod::Tangle
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Pod::Tangle;

my $f = $*TMPDIR.add("tangle-{$*PID}.raku");
LEAVE $f.unlink;
$f.spurt(q:to/END/);
my $x = 1;

=begin pod
Some documentation about $x.
=end pod

say $x + 1;

=begin comment
A comment block.
=end comment

say "done";
END

my $code = tangle($f);
say 'tangled:';
say '[[', $code, ']]';
say '';
say 'each removed block leaves TWO blank lines, and =begin comment is';
say 'stripped exactly like =begin pod.';

# Output:
#     tangled:
#     [[my $x = 1;
#     
#     
#     
#     
#     say $x + 1;
#     
#     
#     
#     
#     say "done";
#     ]]
#     
#     each removed block leaves TWO blank lines, and =begin comment is
#     stripped exactly like =begin pod.
