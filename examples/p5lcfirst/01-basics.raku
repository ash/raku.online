#!/usr/bin/env rakupp
# P5lcfirst — Using it
# https://raku.online/modules/p5lcfirst/#using-it
#
# Install what it needs, then run it:
#     rakupp install P5lcfirst
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5lcfirst;

say 'lcfirst("HELLO")  = ', lcfirst('HELLO').raku;
say 'ucfirst("hello")  = ', ucfirst('hello').raku;
say 'lcfirst("hello")  = ', lcfirst('hello').raku;
say 'ucfirst("HELLO")  = ', ucfirst('HELLO').raku;
say '';
say 'the REST of the string is untouched, which is the whole point:';
say '  ucfirst("mcDONALD") = ', ucfirst('mcDONALD').raku;
say '  lcfirst("XMLParser") = ', lcfirst('XMLParser').raku;
say '';
say 'edges:';
for '', 'a', '1abc' -> $s {
    say sprintf('  ucfirst(%-8s) = %-10s lcfirst(%-8s) = %s',
                $s.raku, ucfirst($s).raku, $s.raku, lcfirst($s).raku);
}

# Output:
#     lcfirst("HELLO")  = "hELLO"
#     ucfirst("hello")  = "Hello"
#     lcfirst("hello")  = "hello"
#     ucfirst("HELLO")  = "HELLO"
#     
#     the REST of the string is untouched, which is the whole point:
#       ucfirst("mcDONALD") = "McDONALD"
#       lcfirst("XMLParser") = "xMLParser"
#     
#     edges:
#       ucfirst(""      ) = ""         lcfirst(""      ) = ""
#       ucfirst("a"     ) = "A"        lcfirst("a"     ) = "a"
#       ucfirst("1abc"  ) = "1abc"     lcfirst("1abc"  ) = "1abc"
