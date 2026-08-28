#!/usr/bin/env rakupp
# Data::Dump — What it is for
# https://raku.online/modules/data-dump/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Data::Dump
#     rakupp 01-dump-a-structure.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Dump;

class Server { has $.host; has $.port; has @.tags }
my $s = Server.new(:host<db1>, :port(5432), :tags<primary ssd>);
say Dump($s, :!color, :skip-methods);
say Dump([1, 'two', 3.5], :!color);

# Output:
#     Server :: (
#       $!host => "db1".Str,
#       $!port => 5432.Int,
#       @!tags => [
#         "primary".Str,
#         "ssd".Str,
#       ],
#     
#     )
#     [
#       1.Int,
#       "two".Str,
#       3.5.Rat,
#     ]
