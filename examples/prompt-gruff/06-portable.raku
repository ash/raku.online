#!/usr/bin/env rakupp
# Prompt::Gruff — Where the two engines differ
# https://raku.online/modules/prompt-gruff/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Prompt::Gruff
#     rakupp 06-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Prompt::Gruff;

say 'the functional interface is in a SEPARATE unit:';
say '  use Prompt::Gruff::Export;   # gives you prompt-for($prompt, |%opts)';
say '';
say 'and one more thing to plan around on both engines: :no-escape';
say 'defaults to True, which makes a regex failure or a verification';
say 'mismatch RECURSE into another prompt-for. With a non-interactive';
say 'stdin that is unbounded recursion on top of the unbounded loop.';
say '';
say 'the safe shape:';
sub ask(Str $prompt, *%opts) {
    return Nil unless $*IN.t;
    Prompt::Gruff.new.prompt-for($prompt, |%opts, no-escape => False)
}
say '  ask() returns Nil when stdin is not a terminal : ', ask('Name: ').raku;

# Output:
#     the functional interface is in a SEPARATE unit:
#       use Prompt::Gruff::Export;   # gives you prompt-for($prompt, |%opts)
#     
#     and one more thing to plan around on both engines: :no-escape
#     defaults to True, which makes a regex failure or a verification
#     mismatch RECURSE into another prompt-for. With a non-interactive
#     stdin that is unbounded recursion on top of the unbounded loop.
#     
#     the safe shape:
#       ask() returns Nil when stdin is not a terminal : Nil
