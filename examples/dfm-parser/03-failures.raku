#!/usr/bin/env rakupp
# DFM::Parser — Every failure is `Nil`
# https://raku.online/modules/dfm-parser/#every-failure-is-nil
#
# Install what it needs, then run it:
#     rakupp install DFM::Parser
#     rakupp 03-failures.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DFM::Parser;

my %cases =
    'well formed'      => "object A: TA\n  X = 1\nend\n",
    'missing end'      => "object A: TA\n  X = 1\n",
    'total garbage'    => "not a form at all\n",
    'empty string'     => '',
    'unterminated str' => "object A: TA\n  X = 'oops\nend\n";

for %cases.keys.sort -> $k {
    my $m = DFM::Parser.parse(%cases{$k});
    say sprintf('  %-18s -> defined=%-6s isFailure=%s',
                $k, $m.defined, ($m ~~ Failure).so);
}
say '';
say 'never an exception, never a Failure — always Nil. And the failure is';
say 'easy to miss, because indexing the result gives silent garbage:';
my $bad = DFM::Parser.parse('garbage');
say '  $bad<object>          : ', $bad<object>.raku;
say '  $bad<o><c>.elems      : ', $bad<o><c>.elems, '   <- Any.elems is 1';
say '';
say 'test .defined on the result; never trust .elems of a chained subscript.';

# Output:
#       empty string       -> defined=False  isFailure=False
#       missing end        -> defined=False  isFailure=False
#       total garbage      -> defined=False  isFailure=False
#       unterminated str   -> defined=False  isFailure=False
#       well formed        -> defined=True   isFailure=False
#     
#     never an exception, never a Failure — always Nil. And the failure is
#     easy to miss, because indexing the result gives silent garbage:
#       $bad<object>          : Any
#       $bad<o><c>.elems      : 1   <- Any.elems is 1
#     
#     test .defined on the result; never trust .elems of a chained subscript.
