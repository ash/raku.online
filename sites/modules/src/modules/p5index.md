---
name: P5index
version: 0.0.7
auth: zef:lizmat
kind: Distribution · Perl 5 compatibility
summary: Perl's `index` and `rindex` — returning -1 for "not found" where
  Raku returns Nil, and taking the position argument Perl's way.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5index
source: https://github.com/lizmat/P5index.git
---

## What it is for

Raku's `index` returns `Nil` when the substring is absent; Perl's returns
`-1`. Code being ported tests `>= 0`, and rewriting every such test is exactly
the kind of change that introduces bugs. This distribution supplies the Perl
semantics under the Perl names.

## Using it

```raku name="basics"
use P5index;

say 'index("foobar", "bar")  = ', index('foobar', 'bar');
say 'index("foobar", "zzz")  = ', index('foobar', 'zzz'), '   <- not Nil';
say 'index("foobar", "o", 2) = ', index('foobar', 'o', 2);
say 'index("foobar", "")     = ', index('foobar', '');
say '';
say 'rindex("foobarbar", "bar")    = ', rindex('foobarbar', 'bar');
say 'rindex("foobarbar", "bar", 5) = ', rindex('foobarbar', 'bar', 5);
say 'rindex("foobar", "zzz")       = ', rindex('foobar', 'zzz');
say '';
say 'so the Perl idiom ports unchanged:';
my $s = 'foobar';
say '  if index($s, "bar") >= 0 { … } -> ', (index($s, 'bar') >= 0);
say '  if index($s, "zzz") >= 0 { … } -> ', (index($s, 'zzz') >= 0);
```

```output
index("foobar", "bar")  = 3
index("foobar", "zzz")  = -1   <- not Nil
index("foobar", "o", 2) = 2
index("foobar", "")     = 0

rindex("foobarbar", "bar")    = 6
rindex("foobarbar", "bar", 5) = 3
rindex("foobar", "zzz")       = -1

so the Perl idiom ports unchanged:
  if index($s, "bar") >= 0 { … } -> True
  if index($s, "zzz") >= 0 { … } -> False
```

## The one thing to know

`rindex($s, "")` can never return `$s.chars` — the empty string is found at
the last position *before* the end, not at the end.

```raku name="empty"
use P5index;

my $s = 'foobar';
say 'chars           : ', $s.chars;
say 'index($s, "")   : ', index($s, '');
say 'rindex($s, "")  : ', rindex($s, '');
say '';
say 'Perl`s rindex($s, "") is length($s); this one is length($s) - 1.';
say '';
say 'the difference matters for the common "append at the last occurrence"';
say 'idiom, where an empty needle is a degenerate case you may not have';
say 'planned for:';
for 'bar', '' -> $needle {
    my $at = rindex($s, $needle);
    say sprintf('  needle %-6s -> splice at %d gives %s',
                $needle.raku, $at,
                ($s.substr(0, $at) ~ '|' ~ $s.substr($at)).raku);
}
```

```output
chars           : 6
index($s, "")   : 0
rindex($s, "")  : 5

Perl`s rindex($s, "") is length($s); this one is length($s) - 1.

the difference matters for the common "append at the last occurrence"
idiom, where an empty needle is a degenerate case you may not have
planned for:
  needle "bar"  -> splice at 3 gives "foo|bar"
  needle ""     -> splice at 5 gives "fooba|r"
```

## The position argument

```raku name="position"
use P5index;

my $s = 'abcabcabc';
say 'index from a position — the search STARTS there:';
for 0, 1, 3, 4, 20, -5 -> $pos {
    say sprintf('  index($s, "abc", %3d) = %s', $pos, index($s, 'abc', $pos));
}
say '';
say 'rindex from a position — the match must START at or before it:';
for 0, 3, 5, 6, 20 -> $pos {
    say sprintf('  rindex($s, "abc", %3d) = %s', $pos, rindex($s, 'abc', $pos));
}
say '';
say 'a negative position is clamped to 0 and an out-of-range one is';
say 'clamped to the end, as in Perl — neither is an error.';
```

```output
index from a position — the search STARTS there:
  index($s, "abc",   0) = 0
  index($s, "abc",   1) = 3
  index($s, "abc",   3) = 3
  index($s, "abc",   4) = 6
  index($s, "abc",  20) = -1
  index($s, "abc",  -5) = 0

rindex from a position — the match must START at or before it:
  rindex($s, "abc",   0) = 0
  rindex($s, "abc",   3) = 3
  rindex($s, "abc",   5) = 3
  rindex($s, "abc",   6) = 6
  rindex($s, "abc",  20) = 6

a negative position is clamped to 0 and an out-of-range one is
clamped to the end, as in Perl — neither is an error.
```

## Where the two engines differ

Nothing. The same answers, the same clamping and the same `-1` on both
engines.

One thing about importing, though, and it is the reason this page exists in
the form it does: `use P5index ()` — an explicit empty import list — leaves
the built-in `index` alone, and `need P5index` does the same.

```raku name="scoping"
{
    use P5index ();
    say 'inside a block with `use P5index ()`:';
    say '  index("foobar", "zzz") = ', index('foobar', 'zzz').raku, '   <- core Raku';
}
{
    use P5index;
    say 'and with a plain `use`:';
    say '  index("foobar", "zzz") = ', index('foobar', 'zzz').raku, '   <- Perl 5';
}
say '';
say 'that lets you load the distribution for its rindex and keep Raku`s';
say 'index, or scope the Perl semantics to the one routine being ported.';
say '';
say 'until Raku++ 3.28.0 the empty import list was ignored there, so';
say '`use P5index ()` installed &index anyway and the first line above';
say 'answered -1 instead of Nil.';
```

```output
inside a block with `use P5index ()`:
  index("foobar", "zzz") = Nil   <- core Raku
and with a plain `use`:
  index("foobar", "zzz") = -1   <- Perl 5

that lets you load the distribution for its rindex and keep Raku`s
index, or scope the Perl semantics to the one routine being ported.

until Raku++ 3.28.0 the empty import list was ignored there, so
`use P5index ()` installed &index anyway and the first line above
answered -1 instead of Nil.
```
