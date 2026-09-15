#!/usr/bin/env rakupp
# P5chr — Scoping the Perl semantics
# https://raku.online/modules/p5chr/#scoping-the-perl-semantics
#
# Install what it needs, then run it:
#     rakupp install P5chr
#     rakupp 03-scoping.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

{
    use P5chr;
    say 'inside a block with `use P5chr`:';
    say '  ord("abc")  = ', ord('abc'), '   <- the first character';
    say '  chr(200).ords = ', chr(200).ords.raku;
}
say '';
say 'outside it, core Raku is back:';
say '  "abc".ord   = ', 'abc'.ord;
say '  200.chr.ords= ', 200.chr.ords.raku;
say '';
say 'and `use P5chr ()` loads the distribution without importing either';
say 'name, which is how you take one of a pair — or neither:';
{
    use P5chr ();
    say '  with an empty import list, 200.chr.ords = ', 200.chr.ords.raku;
}

# Output:
#     inside a block with `use P5chr`:
#       ord("abc")  = 97   <- the first character
#       chr(200).ords = (63,).Seq
#     
#     outside it, core Raku is back:
#       "abc".ord   = 97
#       200.chr.ords= (200,).Seq
#     
#     and `use P5chr ()` loads the distribution without importing either
#     name, which is how you take one of a pair — or neither:
#       with an empty import list, 200.chr.ords = (200,).Seq
