#!/usr/bin/env rakupp
# Data::Tree — The names are not what you type
# https://raku.online/modules/data-tree/#the-names-are-not-what-you-type
#
# Install what it needs, then run it:
#     rakupp install Data::Tree
#     rakupp 04-names.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Tree;

say 'the file says `unit module Tree;`, so:';
say '  RTree.^name  : ', RTree.^name;
say '  Forest.^name : ', Forest.^name;
say '';
say '  ::("Data::Tree::RTree").defined : ', ::('Data::Tree::RTree').defined;
say '  ::("Tree::RTree").defined       : ', ::('Tree::RTree').defined;
say '';
say 'the short names are exported, so you rarely need either — but a';
say 'fully qualified reference has to use Tree::, not Data::Tree::.';
say '';
say 'and the grep predicate takes the NODE, not the data:';
say '  $t.grep(* > 2)             dies';
say '  $t.grep({ .data > 2 })     is what you want';

# Output:
#     the file says `unit module Tree;`, so:
#       RTree.^name  : Tree::RTree
#       Forest.^name : Tree::Forest
#     
#       ::("Data::Tree::RTree").defined : False
#       ::("Tree::RTree").defined       : False
#     
#     the short names are exported, so you rarely need either — but a
#     fully qualified reference has to use Tree::, not Data::Tree::.
#     
#     and the grep predicate takes the NODE, not the data:
#       $t.grep(* > 2)             dies
#       $t.grep({ .data > 2 })     is what you want
