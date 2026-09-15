#!/usr/bin/env rakupp
# Scientist — Two shapes to plan around
# https://raku.online/modules/scientist/#two-shapes-to-plan-around
#
# Install what it needs, then run it:
#     rakupp install Scientist
#     rakupp 04-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Scientist;

my $s = Scientist.new(experiment => 'first', use => sub { 1 }, try => sub { 2 });
$s.run;
say 'after a run, result<experiment> : ', $s.result<experiment>.raku;
$s.enabled = False;
say 'run with enabled = False        : ', $s.run;
say 'result<experiment> is STILL     : ', $s.result<experiment>.raku;
say 'result<mismatched> is STILL     : ', $s.result<mismatched>;
say '';
say 'enabled = False short-circuits before %!result is touched, so result';
say 'keeps reporting the PREVIOUS run`s verdict, name and all.';
say '';
say 'and the order of the two calls is RANDOMISED per run — Bool.pick —';
say 'so a candidate with side effects, shared state or a warm cache will';
say 'produce unstable timings and results.';
say '';
say 'publish() is an empty method; the "publish your results" story needs';
say 'a subclass:';
class Loud is Scientist {
    method publish { note "  {$.experiment}: mismatched={$.result<mismatched>}" }
}
Loud.new(experiment => 'loud', use => sub { 1 }, try => sub { 2 }).run;
say '  (publish writes to stderr above; it is called on agreement too)';

# Output:
#     after a run, result<experiment> : "first"
#     run with enabled = False        : 1
#     result<experiment> is STILL     : "first"
#     result<mismatched> is STILL     : True
#     
#     enabled = False short-circuits before %!result is touched, so result
#     keeps reporting the PREVIOUS run`s verdict, name and all.
#     
#     and the order of the two calls is RANDOMISED per run — Bool.pick —
#     so a candidate with side effects, shared state or a warm cache will
#     produce unstable timings and results.
#     
#     publish() is an empty method; the "publish your results" story needs
#     a subclass:
#       (publish writes to stderr above; it is called on agreement too)
