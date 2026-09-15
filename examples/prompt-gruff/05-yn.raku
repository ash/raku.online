#!/usr/bin/env rakupp
# Prompt::Gruff — `:yn` accepts more than y and n
# https://raku.online/modules/prompt-gruff/#yn-accepts-more-than-y-and-n
#
# Install what it needs, then run it:
#     rakupp install Prompt::Gruff
#     rakupp 05-yn.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Prompt::Gruff;

for <y n yes no nay nope maybe xyzzy> -> $answer {
    my $p = Prompt::Gruff.new(:testing);
    $p._test-input = [$answer];
    my $r = $p.prompt-for('Continue? ', yn => True, no-escape => False);
    say sprintf('  %-8s -> %s', $answer.raku, $r.raku);
}
say '';
say 'the generated regex is `:i y || n`, matched ANYWHERE in the answer,';
say 'and the verdict is then `$response ~~ /:i y/`.';
say '';
say 'so "nay", "maybe" and even "xyzzy" are read as YES, while an answer';
say 'with neither letter in it — "sure" — is rejected as invalid and';
say 'RE-ASKED, which on an exhausted input is an infinite loop.';
say '';
say 'constrain it yourself instead:';
my $p = Prompt::Gruff.new(:testing);
$p._test-input = ['y'];
say '  with :regex -> ', $p.prompt-for('Continue? ', regex => '^<[yYnN]>$').raku;

# Output:
#       "y"      -> Bool::True
#       "n"      -> Bool::False
#       "yes"    -> Bool::True
#       "no"     -> Bool::False
#       "nay"    -> Bool::True
#       "nope"   -> Bool::False
#       "maybe"  -> Bool::True
#       "xyzzy"  -> Bool::True
#     
#     the generated regex is `:i y || n`, matched ANYWHERE in the answer,
#     and the verdict is then `$response ~~ /:i y/`.
#     
#     so "nay", "maybe" and even "xyzzy" are read as YES, while an answer
#     with neither letter in it — "sure" — is rejected as invalid and
#     RE-ASKED, which on an exhausted input is an infinite loop.
#     
#     constrain it yourself instead:
#       with :regex -> "y"
