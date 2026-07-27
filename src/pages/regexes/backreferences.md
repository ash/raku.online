---
title: Backreferences — $0 inside a pattern
slug: backreferences
status: full
order: 34
summary: Refer back to an earlier capture within the same regex to match a repeat.
---

A **backreference** uses a capture *inside the same regex* — writing `$0` in the
pattern means "match the exact text group 0 already captured". This is how you match
a doubled letter, a repeated word, or a palindrome: the second occurrence is required
to equal the first, something a fixed pattern can't express.

## A doubled character

`(.)` captures one character; `$0` right after it demands the same character again.

```raku
for <hello book tree rat> {
    say "$_ has a double" if / (.) $0 /;
}
```
```output
hello has a double
book has a double
tree has a double
```

`rat` has no adjacent repeat, so it prints nothing; the other three each contain a
doubled letter (`ll`, `oo`, `ee`).

## A palindrome

Numbered captures let you mirror a whole span. Here `$1 $0` replays the first two
characters in reverse, matching a four-character palindrome.

```raku
say so "noon" ~~ / ^ (.) (.) $1 $0 $ /;
say so "load" ~~ / ^ (.) (.) $1 $0 $ /;
```
```output
True
False
```

## A repeated word

Combined with word boundaries, a backreference finds an accidentally duplicated word.

```raku
"the the cat" ~~ / « (\w+) » \s+ $0 » /;
say ~$0;
```
```output
the
```

## Notes

- A backreference matches the *text* the capture holds, not the pattern that
  produced it — `(<[ab]>) $0` matches `aa` or `bb`, never `ab`.
- The numbers follow the same rule as reading captures out: `$0`, `$1`, … in order
  of opening parenthesis. See [Captures](/regexes/captures/).
- Backreferences work with the positional captures `$0`, `$1`, …; to require a
  repeat of a *named* piece, capture it positionally and refer to it by number.
