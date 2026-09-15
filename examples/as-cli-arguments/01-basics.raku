#!/usr/bin/env rakupp
# as-cli-arguments — Rendering
# https://raku.online/modules/as-cli-arguments/#rendering
#
# Install what it needs, then run it:
#     rakupp install as-cli-arguments
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use as-cli-arguments;

say 'capture       : ', as-cli-arguments(\('a', 'b', :verbose, :n<3>)).raku;
say 'named-anywhere: ', as-cli-arguments(\('a', :verbose, :n<3>), :named-anywhere).raku;
say 'nameds only   : ', as-cli-arguments(\(:a<1>, :b<2>)).raku;
say 'empty capture : ', as-cli-arguments(\()).raku;
say '';
say 'a false boolean renders as Raku`s --/name, not --no-name:';
say '  ', as-cli-arguments(\(:on, :!off)).raku;
say '';
say 'a name with a dash survives:';
say '  ', as-cli-arguments(\(:dry-run)).raku;

# Output:
#     capture       : "--n=3 --verbose a b"
#     named-anywhere: "a --n=3 --verbose"
#     nameds only   : "--a=1 --b=2"
#     empty capture : ""
#     
#     a false boolean renders as Raku`s --/name, not --no-name:
#       "--/off --on"
#     
#     a name with a dash survives:
#       "--dry-run"
