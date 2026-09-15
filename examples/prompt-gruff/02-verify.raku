#!/usr/bin/env rakupp
# Prompt::Gruff — Driving it without a terminal
# https://raku.online/modules/prompt-gruff/#driving-it-without-a-terminal
#
# Install what it needs, then run it:
#     rakupp install Prompt::Gruff
#     rakupp 02-verify.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Prompt::Gruff;

my $p = Prompt::Gruff.new(:testing);
$p._test-input = ['secret', 'secret', 'secret'];
say 'with :verify(3):';
say '  answer  : ', $p.prompt-for('Passphrase: ', verify => 3).raku;
say '  prompts : ', $p._test-output.List.raku;
say '';
$p = Prompt::Gruff.new(:testing);
$p._test-input = ['99'];
say 'with a :regex constraint:';
say '  digits  : ', $p.prompt-for('Port: ', regex => '^\d+$').raku;
$p = Prompt::Gruff.new(:testing);
$p._test-input = ['abc'];
say '  letters : ', $p.prompt-for('Port: ', regex => '^\d+$', no-escape => False).raku;
say '  output  : ', $p._test-output.List.raku;

# Output:
#     with :verify(3):
#       answer  : "secret"
#       prompts : ("Passphrase: ", "(verify) Passphrase: ", "(verify) Passphrase: ")
#     
#     with a :regex constraint:
#       digits  : "99"
#       letters : Bool::False
#       output  : ("Port: ", "Input does not match valid pattern")
