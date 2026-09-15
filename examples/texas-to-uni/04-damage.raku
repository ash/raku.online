#!/usr/bin/env rakupp
# Texas::To::Uni — What it will do to your source
# https://raku.online/modules/texas-to-uni/#what-it-will-do-to-your-source
#
# Install what it needs, then run it:
#     rakupp install Texas::To::Uni
#     rakupp 04-damage.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Texas::To::Uni;

for 'my $sum = $a + $b;', 'say "pi is pi ok";', 'say $a ** 2;', 'say $a** 2;' -> $line {
    my $s = $line;
    convert-string($s);
    say sprintf('  %-24s -> %s', $line, $s);
}
say '';
say 'the first line is the sharp one: " + " becomes U+207A SUPERSCRIPT';
say 'PLUS SIGN, which is not valid Raku. Running this tool over real';
say 'source silently breaks addition.';
say '';
say 'the second shows it has no idea what a string literal is.';
say 'the third and fourth show it is whitespace-sensitive: ** 2 is left';
say 'alone and **2 becomes a superscript two.';

# Output:
#       my $sum = $a + $b;       -> my $sum = $a⁺$b;
#       say "pi is pi ok";       -> say "pi isπok";
#       say $a ** 2;             -> say $a ** 2;
#       say $a** 2;              -> say $a** 2;
#     
#     the first line is the sharp one: " + " becomes U+207A SUPERSCRIPT
#     PLUS SIGN, which is not valid Raku. Running this tool over real
#     source silently breaks addition.
#     
#     the second shows it has no idea what a string literal is.
#     the third and fourth show it is whitespace-sensitive: ** 2 is left
#     alone and **2 becomes a superscript two.
