#!/usr/bin/env rakupp
# Scientist — Where the two engines differ
# https://raku.online/modules/scientist/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Scientist
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Scientist;

my %ctx = owner => 'spike';
my $s = Scientist.new(experiment => 'ctx', use => sub { 1 }, try => sub { 1 },
                      context => %ctx);
$s.run;
say 'copy the context before you touch it:';
my %mine = $s.result<context>;
%mine<owner> = 'someone else';
say '  my copy      : ', %mine<owner>;
say '  the object   : ', $s.result<context><owner>;
say '';
say 'the result Map is shallow, so its nested values are shared. Treat';
say 'everything that comes out of .result as read-only.';
say '';
say 'and `use` is required while `try` is not — leaving try unset is not';
say 'an error, it is a permanent mismatched => True.';

# Output:
#     copy the context before you touch it:
#       my copy      : someone else
#       the object   : spike
#     
#     the result Map is shallow, so its nested values are shared. Treat
#     everything that comes out of .result as read-only.
#     
#     and `use` is required while `try` is not — leaving try unset is not
#     an error, it is a permanent mismatched => True.
