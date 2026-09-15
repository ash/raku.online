#!/usr/bin/env rakupp
# Shareable — A store file is executable code
# https://raku.online/modules/shareable/#a-store-file-is-executable-code
#
# Install what it needs, then run it:
#     rakupp install Shareable
#     rakupp 04-eval.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Shareable;

class Note is Shareable { has Str $.title }

my $f = $*TMPDIR.add("shareable3-{$*PID}.store");
LEAVE $f.unlink;
$f.spurt('do { say "  >>> code in the store file just ran <<<"; 42 }');

say 'loading a store file that contains an expression:';
my $r = Note.from-file($f.Str);
say '  result = ', $r.raku;
say '';
say 'Storable::Lite deserialises with EVAL under MONKEY-SEE-NO-EVAL.';
say 'Never point from-file or from-store at a file you did not write.';
say '';
say 'a missing file returns Bool::False after a warning — not Nil, not a';
say 'Failure — so `my $obj = $s.from-store;` silently yields False and';
say 'blows up somewhere else later:';
say '  from-file(missing) : ', Note.from-file('/no/such/store').raku;

# Output:
#     loading a store file that contains an expression:
#       >>> code in the store file just ran <<<
#       result = 42
#     
#     Storable::Lite deserialises with EVAL under MONKEY-SEE-NO-EVAL.
#     Never point from-file or from-store at a file you did not write.
#     
#     a missing file returns Bool::False after a warning — not Nil, not a
#     Failure — so `my $obj = $s.from-store;` silently yields False and
#     blows up somewhere else later:
#       from-file(missing) : Bool::False
