#!/usr/bin/env rakupp
# Inline::BASIC — Where the two engines differ
# https://raku.online/modules/inline-basic/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Inline::BASIC
#     rakupp 06-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Inline::BASIC;

say 'the API is one exported sub, `basic(Str $code)`, with no useful';
say 'return value. Output goes to stdout as a side effect.';
say '';
say 'class Interpreter is NOT exported and is not reachable, so there is';
say 'no way to inspect variables, capture output, or reuse state between';
say 'programs. Capture stdout yourself if you need the result:';
my $out = class { has @.lines; method print(*@a) { @!lines.push(@a.join) };
                  method say(*@a) { @!lines.push(@a.join) } }.new;
{
    my $*OUT = $out;
    basic("10 PRINT 6 * 7\n");
}
say '  captured : ', $out.lines.raku;
say '';
say 'INPUT reads one line from $*IN and splits it on commas, so a program';
say 'with INPUT will block on an interactive terminal.';

# Output:
#     the API is one exported sub, `basic(Str $code)`, with no useful
#     return value. Output goes to stdout as a side effect.
#     
#     class Interpreter is NOT exported and is not reachable, so there is
#     no way to inspect variables, capture output, or reuse state between
#     programs. Capture stdout yourself if you need the result:
#       captured : ["42", "\n"]
#     
#     INPUT reads one line from $*IN and splits it on commas, so a program
#     with INPUT will block on an interactive terminal.
