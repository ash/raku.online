#!/usr/bin/env rakupp
# P5index — Where the two engines differ
# https://raku.online/modules/p5index/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install P5index
#     rakupp 04-scoping.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

{
    use P5index ();
    say 'inside a block with `use P5index ()`:';
    say '  index("foobar", "zzz") = ', index('foobar', 'zzz').raku, '   <- core Raku';
}
{
    use P5index;
    say 'and with a plain `use`:';
    say '  index("foobar", "zzz") = ', index('foobar', 'zzz').raku, '   <- Perl 5';
}
say '';
say 'that lets you load the distribution for its rindex and keep Raku`s';
say 'index, or scope the Perl semantics to the one routine being ported.';
say '';
say 'until Raku++ 3.28.0 the empty import list was ignored there, so';
say '`use P5index ()` installed &index anyway and the first line above';
say 'answered -1 instead of Nil.';

# Output:
#     inside a block with `use P5index ()`:
#       index("foobar", "zzz") = Nil   <- core Raku
#     and with a plain `use`:
#       index("foobar", "zzz") = -1   <- Perl 5
#     
#     that lets you load the distribution for its rindex and keep Raku`s
#     index, or scope the Perl semantics to the one routine being ported.
#     
#     until Raku++ 3.28.0 the empty import list was ignored there, so
#     `use P5index ()` installed &index anyway and the first line above
#     answered -1 instead of Nil.
