---
title: Matching with ~~
slug: matching
status: full
order: 10
summary: Test a string against a regex; the result is a Match object (truthy) or Nil.
---

A regex is written between `/ … /`. Smartmatching a string against one with `~~`
runs the regex and returns a **Match object** on success (falsy `Nil` on failure).
The Match stringifies to the matched text.

## A basic match

```raku
say "hello" ~~ /ell/;
```
```output
｢ell｣
```

The `｢ ｣` corner brackets are how a Match displays — they delimit the matched
substring, here `ell`.

## Match as a Boolean

In Boolean context a Match is true and a failed match is false. `so` forces that
Boolean view.

```raku
say so "hello" ~~ /xyz/;
say so "hello" ~~ /ell/;
```
```output
False
True
```

## Notes

- Inside a regex, whitespace is insignificant by default, so you can space things
  out for clarity. Match a literal space with `' '` or `\s`.
- Bare identifiers in a regex match **literally** only when quoted (`'ell'`) or via
  a subrule; unquoted `\w`, `\d`, etc. are metacharacters.
- A successful match also sets the `$/` "match variable" in the current scope,
  which the capture syntax reads from — see [Captures](/regexes/captures/).
