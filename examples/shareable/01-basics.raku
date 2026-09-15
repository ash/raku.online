#!/usr/bin/env rakupp
# Shareable — Saving and loading
# https://raku.online/modules/shareable/#saving-and-loading
#
# Install what it needs, then run it:
#     rakupp install Shareable
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Shareable;

class Note is Shareable { has Str $.title; has Int $.n }

my $f = $*TMPDIR.add("shareable-{$*PID}.store");
LEAVE $f.unlink;

my $a = Note.new(title => 'hello', n => 3);
$a.to-file($f.Str);
say 'file contents : ', $f.slurp.trim;
say '';
my $b = $a.from-file($f.Str);
say 'round-tripped : ', $b.raku;
say '  same class  : ', $b.^name;
say '  equal       : ', $b.title eq $a.title && $b.n == $a.n;
say '  identical   : ', $b === $a;
say '';
say 'from-file returns a NEW object and leaves self untouched — it is not';
say 'an in-place load.';

# Output:
#     file contents : Note.new(title => "hello", n => 3)
#     
#     round-tripped : Note.new(title => "hello", n => 3)
#       same class  : Note
#       equal       : True
#       identical   : False
#     
#     from-file returns a NEW object and leaves self untouched — it is not
#     an in-place load.
