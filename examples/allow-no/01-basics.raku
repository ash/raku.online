#!/usr/bin/env rakupp
# allow-no — What `use` changes
# https://raku.online/modules/allow-no/#what-use-changes
#
# Install what it needs, then run it:
#     rakupp install allow-no
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

# this example drives MAIN by hand so the page can show both sides
use allow-no;

my @before = <--no-bar init --no-baz>;
my @rewritten = @before.map({ .subst(/^ '--no-' /, '--/') });
say 'what the INIT block does to @*ARGS:';
for @before Z @rewritten -> ($b, $a) {
    say sprintf('  %-12s -> %s', $b, $a);
}
say '';
say 'and that is all it does. There is no class, no sub, no exported';
say 'symbol — ::("allow-no") is not a package on either engine.';
say '';
say 'in a real script:';
say '  use allow-no;';
say '  sub MAIN(:$bar, *@rest) { … }';
say '  $ script --no-bar        # $bar is False';

# Output:
#     what the INIT block does to @*ARGS:
#       --no-bar     -> --/bar
#       init         -> init
#       --no-baz     -> --/baz
#     
#     and that is all it does. There is no class, no sub, no exported
#     symbol — ::("allow-no") is not a package on either engine.
#     
#     in a real script:
#       use allow-no;
#       sub MAIN(:$bar, *@rest) { … }
#       $ script --no-bar        # $bar is False
