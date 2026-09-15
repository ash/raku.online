#!/usr/bin/env rakupp
# Constants::Netinet::In — The one thing to know
# https://raku.online/modules/constants-netinet-in/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Constants::Netinet::In
#     rakupp 03-blocks.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Constants::Netinet::In :IP, :IPPROTO;

say 'every platform branch is written  ?? do { my enum … ; NAME }';
say 'except the final !!, which is the macOS one and omits the `do`:';
say '';
say '  447: }';
say '  448: !! { #macosx';
say '';
say 'a bare { … } in term position is a Block LITERAL, so the body never';
say 'runs and `constant IP` is bound to the closure itself.';
say '';
say '  IP.^name   : ', IP.^name;
my $r = try IP.enums;
say '  IP.enums   : ', $r ?? 'works' !! 'No such method for a Block';
say '';
say 'this is the LAST branch in the chain, so any unrecognised OS gets it';
say 'too. Nothing catches it: the distribution ships zero test files.';
say '';
say 'the workaround, and it is engine-sensitive:';
say '  IP.()      works on Raku++ (block arity 0/0) and dies on Rakudo';
say '  IP.(Any)   works on BOTH — use this one';
say '';
say 'whether two calls mint the same enum type is engine-dependent, so';
say 'call it once and keep the result:';
my $IP = IP.(Any);
say '  $IP.enums.elems = ', $IP.enums.elems;

# Output:
#     every platform branch is written  ?? do { my enum … ; NAME }
#     except the final !!, which is the macOS one and omits the `do`:
#     
#       447: }
#       448: !! { #macosx
#     
#     a bare { … } in term position is a Block LITERAL, so the body never
#     runs and `constant IP` is bound to the closure itself.
#     
#       IP.^name   : Block
#       IP.enums   : No such method for a Block
#     
#     this is the LAST branch in the chain, so any unrecognised OS gets it
#     too. Nothing catches it: the distribution ships zero test files.
#     
#     the workaround, and it is engine-sensitive:
#       IP.()      works on Raku++ (block arity 0/0) and dies on Rakudo
#       IP.(Any)   works on BOTH — use this one
#     
#     whether two calls mint the same enum type is engine-dependent, so
#     call it once and keep the result:
#       $IP.enums.elems = 35
