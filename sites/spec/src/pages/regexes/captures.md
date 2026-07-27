---
title: Captures
slug: captures
status: full
order: 20
summary: Pull pieces out of a match — positional $0, $1, … and named $<name>.
---

Parentheses in a regex **capture** the text they match. Positional groups land in
`$0`, `$1`, … (in order of their opening paren); named groups land in `$<name>`.

## Positional captures

```raku
if "2026-07-19" ~~ /(\d+) "-" (\d+) "-" (\d+)/ {
    say "$0 / $1 / $2";
}
```
```output
2026 / 07 / 19
```

Each `( … )` becomes the next `$n`, counting from zero.

## Named captures

`$<name>=( … )` labels a capture, which reads back as `$<name>`. Named captures
make the match self-documenting and order-independent.

```raku
if "John 42" ~~ / $<name>=(\w+) \s+ $<age>=(\d+) / {
    say ~$<name>;
    say ~$<age>;
}
```
```output
John
42
```

## Notes

- A capture is itself a Match object; prefix it with `~` to get its string
  (`~$0`), or `+` for its numeric value.
- `$0` and `$<name>` are shorthands into the match variable `$/`: `$0` is `$/[0]`
  and `$<name>` is `$/{'name'}`.
- Quantifying a capture makes it a list of matches: `(\d)+` leaves `$0` holding all
  the matched digits, indexable as `$0[0]`, `$0[1]`, ….
