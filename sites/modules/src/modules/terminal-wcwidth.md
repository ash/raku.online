---
name: Terminal::WCWidth
version: 0.1.5
auth: zef:raku-community-modules
kind: Distribution · terminal
summary: How many columns a character really takes up on a terminal — two for
  CJK, none for a combining mark, and a refusal for a control code — so that
  padded columns survive text that is not ASCII.
status: full
suite: 1 file, green
tested: 2026-09-14
license: MIT
raku-land: https://raku.land/zef:raku-community-modules/Terminal::WCWidth
source: https://github.com/raku-community-modules/Terminal-WCWidth
---

## What it is for

`.chars` counts characters and a terminal draws columns, and the two numbers
stop agreeing the moment the text leaves ASCII. `世` is one character and two
columns wide. A combining acute accent is one character and no columns at all —
it is drawn on top of the letter before it. Pad a column to width with
`.chars` and every row containing either of them comes out crooked.

This distribution is the C `wcwidth(3)` table, transcribed and kept as Raku
data: one function for a single codepoint, one for a whole string.

## Two subs, one question

`wcwidth` takes a codepoint as an `Int` — note that it wants `.ord`, not a
character — and `wcswidth` takes the `Str`:

```raku name="widths"
use Terminal::WCWidth;

say wcwidth('A'.ord);
say wcwidth('世'.ord);
say wcwidth("\c[COMBINING ACUTE ACCENT]".ord);
say wcwidth(7);

say wcswidth('hello 世界');
say 'hello 世界'.chars;
```

```output
1
2
0
-1
10
8
```

The last pair is the whole point: eight characters, ten columns. Feed
`wcswidth` into the padding instead of `.chars` and the columns line up:

```raku name="align"
use Terminal::WCWidth;

sub pad(Str $s, Int $w) { $s ~ ' ' x ($w - wcswidth($s)) }

for 'apple', '世界', 'café' -> $label {
    say '|', pad($label, 8), '| ', $label.chars, ' chars';
}
```

```output
|apple   | 5 chars
|世界    | 2 chars
|café    | 4 chars
```

## The one thing to know

`-1` is not a width, it is an error, and it is contagious. A control character
has no sensible column count, so `wcwidth` answers `-1` for one — and
`wcswidth` answers `-1` for the *whole string* if it contains one anywhere:

```raku name="refusal"
use Terminal::WCWidth;

say wcswidth("plain");
say wcswidth("a\tb");
```

```output
5
-1
```

A tab is enough to trigger it. Since the natural thing to write is
`$w - wcswidth($s)`, an un-sanitised string turns a padding calculation into a
number one larger than you wanted, silently. Check for the negative before you
subtract, or strip control characters on the way in.
