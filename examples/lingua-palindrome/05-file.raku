#!/usr/bin/env rakupp
# Lingua::Palindrome — Where the two engines differ
# https://raku.online/modules/lingua-palindrome/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Lingua::Palindrome
#     rakupp 05-file.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Palindrome;

my $f = $*TMPDIR.add("palindrome-{$*PID}.txt");
LEAVE $f.unlink;
$f.spurt("alpha\nbeta\nalpha\n");

say 'line-palindrome on an IO::Path : ', line-palindrome($f);
$f.spurt('');
say 'an empty file                  : ', line-palindrome($f);
say '';
say 'the empty string is a palindrome on both engines, and so is any';
say 'single character — worth guarding if "is this interesting?" is the';
say 'question you actually meant to ask.';

# Output:
#     line-palindrome on an IO::Path : True
#     an empty file                  : True
#     
#     the empty string is a palindrome on both engines, and so is any
#     single character — worth guarding if "is this interesting?" is the
#     question you actually meant to ask.
