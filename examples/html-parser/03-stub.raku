#!/usr/bin/env rakupp
# HTML::Parser — The one thing to know
# https://raku.online/modules/html-parser/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install HTML::Parser
#     rakupp 03-stub.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTML::Parser;

class Naive does HTML::Parser { }

say 'the role composes fine : ', (Naive.new ~~ HTML::Parser);
say 'xmldoc on a fresh one  : ', Naive.new.xmldoc.defined;
my $r = try Naive.new.parse('<p>hi</p>');
say 'calling parse          : ', $! ?? 'threw ' ~ $!.^name !! 'returned';
say '';
say 'the message names Whatever and mentions nothing about the method';
say 'being unimplemented — "Type check failed for return value; expected';
say 'XML::Document but got Whatever (*)".';
say '';
say 'a role stub that is meant to be required should be written  { ... }';
say 'rather than  {*}  — the yada form makes the engine enforce it at';
say 'composition time, with a message that names the method.';

# Output:
#     the role composes fine : True
#     xmldoc on a fresh one  : False
#     calling parse          : threw X::TypeCheck::Return
#     
#     the message names Whatever and mentions nothing about the method
#     being unimplemented — "Type check failed for return value; expected
#     XML::Document but got Whatever (*)".
#     
#     a role stub that is meant to be required should be written  { ... }
#     rather than  {*}  — the yada form makes the engine enforce it at
#     composition time, with a message that names the method.
