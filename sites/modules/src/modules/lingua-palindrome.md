---
name: Lingua::Palindrome
version: 0.1.0
auth: github:sfischer13
kind: Distribution · linguistics
summary: Palindromy at three granularities — characters, words, lines —
  behind a filter with four flags and one character class it cannot remove.
status: full
suite: 3 files, green
tested: 2026-09-15
license: MIT
depends: Pod::To::Text (declared, unused, and not in the ecosystem index)
raku-land: https://raku.land/github:sfischer13/Lingua::Palindrome
source: git://github.com/sfischer13/perl6-Lingua-Palindrome.git
---

## What it is for

"A man, a plan, a canal: Panama" is a palindrome if you ignore punctuation,
whitespace and case — which is the convention, and which means every
palindrome test is really a question about what you strip first.

This distribution makes the stripping explicit: four flags say which character
classes survive, and three functions then ask the question at three
granularities.

## The three granularities

```raku name="basics"
use Lingua::Palindrome;

say 'char-palindrome("racecar")                  = ', char-palindrome('racecar');
say 'char-palindrome("A man, a plan, a canal: Panama") = ',
    char-palindrome('A man, a plan, a canal: Panama');
say '';
say 'word-palindrome("you can cage a swallow can you") = ',
    word-palindrome('you can cage a swallow can you');
say 'word-palindrome("this is not one")               = ',
    word-palindrome('this is not one');
say '';
my $lines = "alpha\nbeta\nalpha";
say 'line-palindrome(three lines, outer two equal)    = ', line-palindrome($lines);
say 'line-palindrome("a\nb\nc")                       = ', line-palindrome("a\nb\nc");
```

```output
char-palindrome("racecar")                  = True
char-palindrome("A man, a plan, a canal: Panama") = True

word-palindrome("you can cage a swallow can you") = False
word-palindrome("this is not one")               = False

line-palindrome(three lines, outer two equal)    = True
line-palindrome("a\nb\nc")                       = False
```

## The flags

Every flag means **keep**. `:alpha` and `:digit` default to keeping,
`:punct` and `:space` to dropping, and `:case` defaults to `False` meaning
*fold case* — so passing `:case` makes the test case-**sensitive**.

```raku name="flags"
use Lingua::Palindrome;

my $s = 'A man, a plan, a canal: Panama';
say 'default (fold case, drop punct+space) : ', char-palindrome($s);
say ':case (case-SENSITIVE)                : ', char-palindrome($s, :case);
say ':punct (keep punctuation)             : ', char-palindrome($s, :punct);
say ':space (keep whitespace)              : ', char-palindrome($s, :space);
say '';
say 'digits are kept by default:';
say '  char-palindrome("1a2a1")            : ', char-palindrome('1a2a1');
say '  char-palindrome("1a2a1", :!digit)   : ', char-palindrome('1a2a1', :!digit);
say '';
say 'a filter that empties the string is vacuously true:';
say '  char-palindrome("hello 42", :!alpha, :!digit) : ',
    char-palindrome('hello 42', :!alpha, :!digit);
```

```output
default (fold case, drop punct+space) : True
:case (case-SENSITIVE)                : False
:punct (keep punctuation)             : False
:space (keep whitespace)              : False

digits are kept by default:
  char-palindrome("1a2a1")            : True
  char-palindrome("1a2a1", :!digit)   : True

a filter that empties the string is vacuously true:
  char-palindrome("hello 42", :!alpha, :!digit) : True
```

`word-palindrome` has no `:space` flag — it always splits on `.words` first —
and `line-palindrome` takes an `IO::Path` as well as a `Str`.

## The one thing to know

"Drop punctuation" is not "drop everything that is not a letter or a digit".
Symbols are a fifth class with no flag, and they always survive.

```raku name="symbols"
use Lingua::Palindrome;

for 'Madam, I\'m Adam',
    "A man, a plan, a canal \c[EM DASH] Panama!",
    'Level +',
    '+Level+',
    "Step on no pets \c[COPYRIGHT SIGN]",
    '2 + 2 = 2 + 2',
    'a_ba' -> $s {
    say sprintf('  %-5s %s', char-palindrome($s), $s);
}
say '';
say '"+" is Sm and "©" is So — neither is <alpha>, <digit>, <punct> or \s,';
say 'so no filter can remove them and an otherwise perfect palindrome comes';
say 'back False. The em dash IS Pd and does get stripped, and "_" is Pc,';
say 'so it is stripped as punctuation — which is the mirror-image surprise.';
```

```output
  True  Madam, I'm Adam
  True  A man, a plan, a canal — Panama!
  False Level +
  True  +Level+
  False Step on no pets ©
  True  2 + 2 = 2 + 2
  True  a_ba

"+" is Sm and "©" is So — neither is <alpha>, <digit>, <punct> or \s,
so no filter can remove them and an otherwise perfect palindrome comes
back False. The em dash IS Pd and does get stripped, and "_" is Pc,
so it is stripped as punctuation — which is the mirror-image surprise.
```

The second surprise lives in the same place: foldcase changes string length.

```raku name="foldcase"
use Lingua::Palindrome;

say q{'ß'.fc is }, "\c[LATIN SMALL LETTER SHARP S]".fc.raku, ', so:';
for "\c[LATIN SMALL LETTER SHARP S]",
    "s\c[LATIN SMALL LETTER SHARP S]",
    "\c[LATIN SMALL LETTER SHARP S]s",
    "Stra\c[LATIN SMALL LETTER SHARP S]e" -> $s {
    say sprintf('  default %-5s  :case %-5s  %s',
                char-palindrome($s), char-palindrome($s, :case), $s);
}
say '';
say 'sß and ßs are reported as palindromes under the default';
say 'case-insensitive filter. Pass :case to stop it.';
```

```output
'ß'.fc is "ss", so:
  default True   :case True   ß
  default True   :case False  sß
  default True   :case False  ßs
  default False  :case False  Straße

sß and ßs are reported as palindromes under the default
case-insensitive filter. Pass :case to stop it.
```

## Where the two engines differ

Nothing in the library: every flag combination, every Unicode edge and both
file paths agree. As with its sibling `Lingua::Lipogram`, only the shipped
`bin/` script differs, because it pulls in `Pod::To::Text` — core on Rakudo,
absent on Raku++.

```raku name="file"
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
```

```output
line-palindrome on an IO::Path : True
an empty file                  : True

the empty string is a palindrome on both engines, and so is any
single character — worth guarding if "is this interesting?" is the
question you actually meant to ask.
```
