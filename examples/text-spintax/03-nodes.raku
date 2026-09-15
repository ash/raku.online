#!/usr/bin/env rakupp
# Text::Spintax — The node classes
# https://raku.online/modules/text-spintax/#the-node-classes
#
# Install what it needs, then run it:
#     rakupp install Text::Spintax
#     rakupp 03-nodes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Spintax;

say 'the tree is built from four classes, all with a no-argument .render:';
say '  SequenceNode  has @.children';
say '  TextNode      has $.text';
say '  SpinNode      has @.children';
say '  NullNode      declared, never constructed by the parser';
say '';
my $tree = Text::Spintax.parse('plain text');
say 'a template with no groups still comes back as a SequenceNode:';
say '  ', $tree.^name, ' -> ', $tree.render.raku;
say '';
say 'the grammar and actions are reachable by name too, as';
say 'Text::Spintax::Spintax and Text::Spintax::Spinaction.';

# Output:
#     the tree is built from four classes, all with a no-argument .render:
#       SequenceNode  has @.children
#       TextNode      has $.text
#       SpinNode      has @.children
#       NullNode      declared, never constructed by the parser
#     
#     a template with no groups still comes back as a SequenceNode:
#       Text::Spintax::SequenceNode -> "plain text"
#     
#     the grammar and actions are reachable by name too, as
#     Text::Spintax::Spintax and Text::Spintax::Spinaction.
