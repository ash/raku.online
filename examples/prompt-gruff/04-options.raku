#!/usr/bin/env rakupp
# Prompt::Gruff — Every option resets the object
# https://raku.online/modules/prompt-gruff/#every-option-resets-the-object
#
# Install what it needs, then run it:
#     rakupp install Prompt::Gruff
#     rakupp 04-options.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Prompt::Gruff;

my $p = Prompt::Gruff.new(:testing, verify => 3, default => 'blue', required => False);
say 'attributes before : verify=', $p.verify, ' default=', $p.default.raku,
    ' required=', $p.required;
$p._test-input = ['first'];
say 'answer            : ', $p.prompt-for('Colour: ').raku;
say 'prompts           : ', $p._test-output.elems, ' — not 3';
say 'attributes after  : verify=', $p.verify, ' default=', $p.default.raku,
    ' required=', $p.required;
say '';
say 'every named option is bound straight to an attribute WITH A DEFAULT,';
say 'so omitting one silently resets it. Setting attributes on the object';
say 'and then calling prompt-for($prompt) throws those settings away.';
say '';
say 'pass everything at the call site, every time.';
say '';
say 'verify is destructive too — it counts down to 0 on the object and';
say 'stays there, so a second call asks once.';

# Output:
#     attributes before : verify=3 default="blue" required=False
#     answer            : "first"
#     prompts           : 1 — not 3
#     attributes after  : verify=0 default="" required=True
#     
#     every named option is bound straight to an attribute WITH A DEFAULT,
#     so omitting one silently resets it. Setting attributes on the object
#     and then calling prompt-for($prompt) throws those settings away.
#     
#     pass everything at the call site, every time.
#     
#     verify is destructive too — it counts down to 0 on the object and
#     stays there, so a second call asks once.
