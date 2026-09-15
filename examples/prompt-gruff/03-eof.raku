#!/usr/bin/env rakupp
# Prompt::Gruff — The one thing to know
# https://raku.online/modules/prompt-gruff/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Prompt::Gruff
#     rakupp 03-eof.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Prompt::Gruff;

say 'the body is';
say '  while !($response = $prompter($!_prompt) || $!default) { }';
say '';
say 'at EOF core prompt returns Nil on every call, so nothing ever';
say 'becomes true. Fed /dev/null, a required prompt writes the prompt';
say 'string until you kill it — tens of megabytes in a few seconds.';
say '';
say ':required(False) returns the empty string cleanly instead:';
my $p = Prompt::Gruff.new(:testing);
$p._test-input = [];                # an exhausted input array stands in for EOF
say '  required => False -> ', $p.prompt-for('Name: ', required => False).raku;
say '';
say 'the multi-line path does the same thing, so guard both. If your';
say 'program can run non-interactively, check $*IN.t before you ask:';
say '  $*IN.t : ', $*IN.t;
say '  (and fall back to a default, an argument, or an exit)';

# Output:
#     the body is
#       while !($response = $prompter($!_prompt) || $!default) { }
#     
#     at EOF core prompt returns Nil on every call, so nothing ever
#     becomes true. Fed /dev/null, a required prompt writes the prompt
#     string until you kill it — tens of megabytes in a few seconds.
#     
#     :required(False) returns the empty string cleanly instead:
#       required => False -> ""
#     
#     the multi-line path does the same thing, so guard both. If your
#     program can run non-interactively, check $*IN.t before you ask:
#       $*IN.t : False
#       (and fall back to a default, an argument, or an exit)
