#!/usr/bin/env rakupp
# Texas::To::Uni — Converting a file
# https://raku.online/modules/texas-to-uni/#converting-a-file
#
# Install what it needs, then run it:
#     rakupp install Texas::To::Uni
#     rakupp 03-file.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Texas::To::Uni;

my $f = $*TMPDIR.add("texas-{$*PID}.raku");
my $out = $*TMPDIR.add("texas-{$*PID}.uni.raku");
LEAVE { $f.unlink; $out.unlink }
$f.spurt("say (1,2) (<=) (3,4);\n");

# convert-file prints the destination path to stdout, so capture that
my $noise = String::Stream.new('') if False;   # (no dependency; just a note)
{
    my $*OUT = class { method print(*@) { } ; method say(*@) { } }.new;
    convert-file($f.Str);
}
say 'wrote a .uni.raku beside it : ', $out.e ?? 'yes' !! 'no';
say 'body                        : ', $out.slurp.trim;
say '';
say 'without :rewrite it writes foo.uni.raku beside foo.raku; :rewrite';
say 'overwrites in place; :new-path writes where you say. It also prints';
say 'the destination path and a sentence to STDOUT — silenced above, so';
say 'this page shows the same thing on both engines.';

# Output:
#     wrote a .uni.raku beside it : yes
#     body                        : say (1,2) ⊆ (3,4);
#     
#     without :rewrite it writes foo.uni.raku beside foo.raku; :rewrite
#     overwrites in place; :new-path writes where you say. It also prints
#     the destination path and a sentence to STDOUT — silenced above, so
#     this page shows the same thing on both engines.
