#!/usr/bin/env rakupp
# Shareable — Where the two engines differ
# https://raku.online/modules/shareable/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Shareable
#     rakupp 05-leak.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Shareable;

say 'the other divergence is scoping: `use Shareable` re-exports its';
say 'dependency`s exports under Raku++ and not under Rakudo.';
say '';
say '  after `use Shareable` alone:';
say '    FileStore, to-file and from-file as SUBS are visible on Raku++';
say '    and "Undeclared name" on Rakudo';
say '';
say 'so code written against Raku++ that calls to-file($path, $obj) as a';
say 'sub does not compile on Rakudo. Use the METHODS the class gives you,';
say 'which are the same on both:';
class Note is Shareable { has Str $.title }
my $f = $*TMPDIR.add("shareable4-{$*PID}.store");
LEAVE $f.unlink;
my $n = Note.new(title => 'portable');
$n.to-file($f.Str);
say '  .to-file / .from-file : ', Note.from-file($f.Str).title;

# Output:
#     the other divergence is scoping: `use Shareable` re-exports its
#     dependency`s exports under Raku++ and not under Rakudo.
#     
#       after `use Shareable` alone:
#         FileStore, to-file and from-file as SUBS are visible on Raku++
#         and "Undeclared name" on Rakudo
#     
#     so code written against Raku++ that calls to-file($path, $obj) as a
#     sub does not compile on Rakudo. Use the METHODS the class gives you,
#     which are the same on both:
#       .to-file / .from-file : portable
