#!/usr/bin/env rakupp
# Prompt::Gruff — Driving it without a terminal
# https://raku.online/modules/prompt-gruff/#driving-it-without-a-terminal
#
# Install what it needs, then run it:
#     rakupp install Prompt::Gruff
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Prompt::Gruff;

my $p = Prompt::Gruff.new(:testing);
$p._test-input = ['Ada'];
say 'answer  : ', $p.prompt-for('Name: ').raku;
say 'prompts : ', $p._test-output.List.raku;
say '';
$p = Prompt::Gruff.new(:testing);
$p._test-input = ['blue'];
say 'with a default:';
say '  answer  : ', $p.prompt-for('Colour: ', default => 'blue').raku;
say '  prompts : ', $p._test-output.List.raku;
say '  (the default is shown in the prompt)';

# Output:
#     answer  : "Ada"
#     prompts : ("Name: ",)
#     
#     with a default:
#       answer  : "blue"
#       prompts : ("Colour: [blue] ",)
#       (the default is shown in the prompt)
