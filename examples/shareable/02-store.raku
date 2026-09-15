#!/usr/bin/env rakupp
# Shareable — The store file
# https://raku.online/modules/shareable/#the-store-file
#
# Install what it needs, then run it:
#     rakupp install Shareable
#     rakupp 02-store.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Shareable;

class Note is Shareable { has Str $.title }

say 'the module keeps ONE module-level store path, shared by every';
say 'instance and subclass, defaulting to $HOME/.Shareable-store-file.';
say '';
say '  .show-store  reads it';
say '  .save        writes self to it';
say '  .store       is the same method under another name';
say '  .from-store  reads it back';
say '';
say 'and .new(:store-file(...)) does NOTHING. The `multi new(:$store-file)`';
say 'in the class body has no `method` keyword, so it is a lexical SUB,';
say 'not a constructor candidate — .new falls through to Mu.new and the';
say 'named argument is dropped:';
say '  ', Note.new(store-file => '/tmp/mine').show-store.IO.basename;

# Output:
#     the module keeps ONE module-level store path, shared by every
#     instance and subclass, defaulting to $HOME/.Shareable-store-file.
#     
#       .show-store  reads it
#       .save        writes self to it
#       .store       is the same method under another name
#       .from-store  reads it back
#     
#     and .new(:store-file(...)) does NOTHING. The `multi new(:$store-file)`
#     in the class body has no `method` keyword, so it is a lexical SUB,
#     not a constructor candidate — .new falls through to Mu.new and the
#     named argument is dropped:
#       .Shareable-store-file
