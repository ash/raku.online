---
name: Avolution::Emoji
version: 0.1.1
auth: github:XiKuuKy
kind: Distribution · text
summary: 251 shortcode substitutions turning `:smile:` into an emoji — two of
  them mis-escaped, including the most-typed one of all.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/github:XiKuuKy/Avolution::Emoji
source: git://github.com/XiKuuKy/Avolution-Emoji.git
---

## What it is for

Chat systems let you type `:tada:` and see 🎉. This distribution is the
substitution table behind that: one method that runs 251 case-insensitive
global replacements over a string, leaving anything it does not recognise
alone.

## Using it

```raku name="basics"
use Avolution::Emoji;

say Avolution::Emoji.emoji('hi :smile: there');
say Avolution::Emoji.emoji(':SMILE: works too — the match is case-insensitive');
say Avolution::Emoji.emoji('and it is global: :smile: :smile:');
say Avolution::Emoji.emoji('unknown markers pass through: :not-an-emoji:');
say '';
say 'it works on the type object and on an instance:';
say '  type     : ', Avolution::Emoji.emoji(':tada:');
say '  instance : ', Avolution::Emoji.new.emoji(':tada:');
say '  returns  : ', Avolution::Emoji.emoji(':tada:').WHAT.^name;
```

```output
hi 😀 there
😀 works too — the match is case-insensitive
and it is global: 😀 😀
unknown markers pass through: :not-an-emoji:

it works on the type object and on an instance:
  type     : :tada:
  instance : :tada:
  returns  : Str
```

There is no lookup table you can read, no way to ask which shortcodes exist,
and no way to add one. Every call runs all 251 substitutions over the whole
string regardless of what is in it.

## The one thing to know

Two of the substitution patterns are mis-escaped, so the two most-typed
shortcodes in the list do nothing — and one of them instead rewrites ordinary
prose.

```raku name="broken"
use Avolution::Emoji;

say 'the thumbs-up shortcode:';
for ':+1:', ':1:', '::::1:', ':thumbsup:', ':-1:' -> $s {
    say sprintf('  %-12s -> %s', $s.raku, Avolution::Emoji.emoji($s).raku);
}
say '';
say 'the pattern is written \:+1\: — the + quantifies the ESCAPED COLON';
say 'instead of being a literal +. So it matches one-or-more colons';
say 'followed by 1:, and the :+1: a user actually types does not match.';
say 'the thumbs-DOWN partner is fine.';
say '';
say 'the crying shortcode:';
for ':sob:', ' ob:', "a\tob::b" -> $s {
    say sprintf('  %-12s -> %s', $s.raku, Avolution::Emoji.emoji($s).raku);
}
say '';
say 'that one is \sob:\: — \s is the WHITESPACE class. It matches';
say 'whitespace, then "ob", then a colon. Any string containing a space';
say 'followed by "ob:" gets rewritten.';
```

```output
the thumbs-up shortcode:
  ":+1:"       -> ":+1:"
  ":1:"        -> "👍"
  "::::1:"     -> "👍"
  ":thumbsup:" -> "👍"
  ":-1:"       -> "👎"

the pattern is written \:+1\: — the + quantifies the ESCAPED COLON
instead of being a literal +. So it matches one-or-more colons
followed by 1:, and the :+1: a user actually types does not match.
the thumbs-DOWN partner is fine.

the crying shortcode:
  ":sob:"      -> ":sob:"
  " ob:"       -> "😭"
  "a\tob::b"   -> "a😭:b"

that one is \sob:\: — \s is the WHITESPACE class. It matches
whitespace, then "ob", then a colon. Any string containing a space
followed by "ob:" gets rewritten.
```

## The table is not what the names say

```raku name="collisions"
use Avolution::Emoji;

say 'several shortcodes land on a different emoji than their name:';
for ':see-no-evil:', ':hear-no-evil:', ':speak-no-evil:',
    ':smile-cat:', ':kissing-cat:', ':grin:', ':grimacing:' -> $s {
    say sprintf('  %-18s -> %s', $s, Avolution::Emoji.emoji($s));
}
say '';
say 'hear-no-evil and speak-no-evil both give you the SEE-no-evil monkey;';
say 'kissing-cat gives the smiling cat; grin gives the grimacing face.';
say '';
say 'and one key is misspelled in the table, so the correct spelling';
say 'does nothing while the typo works:';
for ':disappointed-relieved:', ':dissapointed-relieved:' -> $s {
    say sprintf('  %-26s -> %s', $s, Avolution::Emoji.emoji($s).raku);
}
```

```output
several shortcodes land on a different emoji than their name:
  :see-no-evil:      -> 🙈
  :hear-no-evil:     -> 🙈
  :speak-no-evil:    -> 🙈
  :smile-cat:        -> 😺
  :kissing-cat:      -> 😺
  :grin:             -> 😬
  :grimacing:        -> 😬

hear-no-evil and speak-no-evil both give you the SEE-no-evil monkey;
kissing-cat gives the smiling cat; grin gives the grimacing face.

and one key is misspelled in the table, so the correct spelling
does nothing while the typo works:
  :disappointed-relieved:    -> ":disappointed-relieved:"
  :dissapointed-relieved:    -> "😥"
```

251 patterns produce only 160 distinct emoji: 73 of them are reachable by two
or more names, and many of those pairs are mistakes rather than synonyms.

## Where the two engines differ

Nothing. Every substitution, every miss and every mis-escape behaves
identically on both engines — this is a chain of `.subst` calls over a
literal table, with no container, no hash iteration and no arithmetic in it.

```raku name="portable"
use Avolution::Emoji;

# the shortcodes that work are the ones worth using; check before you ship
sub works(Str $code) { Avolution::Emoji.emoji($code) ne $code }

my @candidates = <:smile: :tada: :heart: :+1: :thumbsup: :sob: :fire: :rocket:>;
say 'shortcode      fires?  result';
for @candidates -> $c {
    say sprintf('  %-14s %-6s %s', $c, works($c),
                works($c) ?? Avolution::Emoji.emoji($c) !! '(unchanged)');
}
say '';
say 'the file extension is .pm6 and the unit is `module Avolution`, with';
say 'the class inside it — so the name you `use` and the name you call';
say 'are the same only by convention.';
```

```output
shortcode      fires?  result
  :smile:        True   😀
  :tada:         False  (unchanged)
  :heart:        True   ❤
  :+1:           False  (unchanged)
  :thumbsup:     True   👍
  :sob:          False  (unchanged)
  :fire:         True   🔥
  :rocket:       False  (unchanged)

the file extension is .pm6 and the unit is `module Avolution`, with
the class inside it — so the name you `use` and the name you call
are the same only by convention.
```

One metadata note: the META6 `auth` field is a malformed multi-value string
(`github:ccworld1000`-style, three identities joined by commas), so tooling
that builds a raku.land URL from it produces nonsense. The working link is
keyed on the first identity alone.
