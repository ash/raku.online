#!/usr/bin/env rakupp
# Scientist — Running an experiment
# https://raku.online/modules/scientist/#running-an-experiment
#
# Install what it needs, then run it:
#     rakupp install Scientist
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Scientist;

my $s = Scientist.new(
    experiment => 'sum',
    use        => sub { (1..10).sum },
    try        => sub { 10 * 11 div 2 },
    context    => %( owner => 'spike' ),
);
say 'run returned : ', $s.run;
say '';
my %r = $s.result;
say 'result keys  : ', %r.keys.sort.join(', ');
say '  experiment : ', %r<experiment>.raku;
say '  mismatched : ', %r<mismatched>;
say '  context    : ', %r<context>.map({ .key ~ '=' ~ .value }).sort.join(', ');
say '  durations are Durations : ',
    so (%r<control><duration>, %r<candidate><duration>).all ~~ Duration;
say '';
say 'the value your program gets is always the CONTROL`s.';

# Output:
#     run returned : 55
#     
#     result keys  : candidate, context, control, experiment, mismatched
#       experiment : "sum"
#       mismatched : False
#       context    : owner=spike
#       durations are Durations : True
#     
#     the value your program gets is always the CONTROL`s.
