---
name: HTML::EscapeUtils
version: 0.0.3
auth: zef:demanuel
kind: Distribution · encoding
summary: Escape five characters, unescape 2222 named and numeric entities —
  and throw on any entity it does not recognise.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: EUPL-1.2
depends: JSON::Fast
raku-land: https://raku.land/zef:demanuel/HTML::EscapeUtils
source: https://codeberg.org/demanuel/HTML-EscapeUtils.git
---

## What it is for

Putting user text into an HTML document safely, and reading entity-encoded
text back. Two subs, a bundled 2222-entry codepoint table, and nothing else.

## Escaping

```raku name="escape"
use HTML::EscapeUtils;

my $raw = q{<a href="x">Tom & Jerry's</a>};
say 'raw     : ', $raw;
say 'escaped : ', escape($raw);
say '';
say 'exactly five characters are escaped:';
for '&', '<', '>', '"', "'", '/', '`', '=', ' ' -> $c {
    say sprintf('  %-4s -> %s', $c.raku, escape($c).raku);
}
say '';
say '& is substituted first, so double-escaping does not occur and the';
say 'round trip is lossless:';
say '  unescape(escape($raw)) eq $raw : ', unescape(escape($raw)) eq $raw;
```

```output
raw     : <a href="x">Tom & Jerry's</a>
escaped : &lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&apos;s&lt;/a&gt;

exactly five characters are escaped:
  "\&" -> "\&amp;"
  "<"  -> "\&lt;"
  ">"  -> "\&gt;"
  "\"" -> "\&quot;"
  "'"  -> "\&apos;"
  "/"  -> "/"
  "`"  -> "`"
  "="  -> "="
  " "  -> " "

& is substituted first, so double-escaping does not occur and the
round trip is lossless:
  unescape(escape($raw)) eq $raw : True
```

There is no separate attribute-value routine — no `escape-attr`, no `:attr`
flag. `escape` is what you have for both text and attributes.

```raku name="attributes"
use HTML::EscapeUtils;

my $payload = q{x" onmouseover="alert(1)};
say 'double-quoted : <a title="', escape($payload), '">';
my $single = q{x' onmouseover='alert(1)};
say 'single-quoted : <a title=', "'", escape($single), "'", '>';
say 'unquoted      : <a title=', escape('x onmouseover=alert(1)'), '>';
say '';
say 'the first two are safe; the third is a live attribute injection.';
say 'ALWAYS quote your attribute values — this escape does not remove';
say 'spaces, backticks or equals signs, and an unquoted attribute needs';
say 'all three handled.';
```

```output
double-quoted : <a title="x&quot; onmouseover=&quot;alert(1)">
single-quoted : <a title='x&apos; onmouseover=&apos;alert(1)'>
unquoted      : <a title=x onmouseover=alert(1)>

the first two are safe; the third is a live attribute injection.
ALWAYS quote your attribute values — this escape does not remove
spaces, backticks or equals signs, and an unquoted attribute needs
all three handled.
```

## Unescaping

```raku name="unescape"
use HTML::EscapeUtils;

for '&amp;', '&lt;', '&nbsp;', '&copy;', '&hellip;', '&AMP;',
    '&#65;', '&#x41;', '&#8212;', '&#x1F600;', '&amp;;;', '&amp' -> $e {
    my $r = try unescape($e);
    say sprintf('  %-12s -> %s', $e.raku, $! ?? 'threw' !! $r.raku);
}
say '';
say 'the table has 2222 entries including 752 uppercase spellings, the';
say 'quantifier on the trailing semicolon eats every one of them, and an';
say 'entity with no semicolon is left alone.';
```

```output
  "\&amp;"     -> "\&"
  "\&lt;"      -> "<"
  "\&nbsp;"    -> " "
  "\&copy;"    -> "©"
  "\&hellip;"  -> "…"
  "\&AMP;"     -> "\&"
  "\&#65;"     -> "A"
  "\&#x41;"    -> "A"
  "\&#8212;"   -> "—"
  "\&#x1F600;" -> "😀"
  "\&amp;;;"   -> "\&"
  "\&amp"      -> "\&amp"

the table has 2222 entries including 752 uppercase spellings, the
quantifier on the trailing semicolon eats every one of them, and an
entity with no semicolon is left alone.
```

## The one thing to know

`unescape` throws on any entity it does not recognise — with a type-check
error that says nothing about entities.

```raku name="unknown"
use HTML::EscapeUtils;

for '&notanentity;', '&123;', '&;', 'plain text', 'a & b' -> $s {
    my $r = try unescape($s);
    say sprintf('  %-18s -> %s', $s.raku, $! ?? 'threw ' ~ $!.^name !! $r.raku);
}
say '';
say 'the internal replace does  return $match if %codepoints{$match}:!exists;';
say '— returning the Match from a --> Str sub, so the RETURN type-check';
say 'fires.';
say '';
say 'you cannot run unescape over arbitrary HTML. One unknown entity, one';
say 'stray &…;, even a bare &;, and it explodes.';
say '';
say 'guard it:';
sub safe-unescape(Str $s) {
    $s.subst(/ '&' <-[&;\s]>+ ';' /, { (try unescape($/.Str)) // $/.Str }, :g)
}
say '  safe-unescape("&amp; &nope; &lt;") = ',
    safe-unescape('&amp; &nope; &lt;').raku;
```

```output
  "\&notanentity;"   -> threw X::TypeCheck::Return
  "\&123;"           -> threw X::TypeCheck::Return
  "\&;"              -> threw X::TypeCheck::Return
  "plain text"       -> "plain text"
  "a \& b"           -> "a \& b"

the internal replace does  return $match if %codepoints{$match}:!exists;
— returning the Match from a --> Str sub, so the RETURN type-check
fires.

you cannot run unescape over arbitrary HTML. One unknown entity, one
stray &…;, even a bare &;, and it explodes.

guard it:
  safe-unescape("&amp; &nope; &lt;") = "\& \&nope; <"
```

## Cost

```raku name="cost"
use HTML::EscapeUtils;

say 'unescape re-slurps and re-parses the 64 KB resource on EVERY call,';
say 'so the cost tracks the number of CALLS, not the size of the input.';
say '';
my $many = '&amp;' x 200;
my $t0 = now;
unescape($many);
my $one-call = now - $t0;
$t0 = now;
unescape('&amp;') for ^200;
my $many-calls = now - $t0;
say '  one call over 200 entities : ', $one-call < 1 ?? 'under a second' !! 'slow';
say '  200 calls over one entity  : ',
    $many-calls > $one-call * 20 ?? 'more than 20x slower' !! 'comparable';
say '';
say 'batch your text into one call.';
```

```output
unescape re-slurps and re-parses the 64 KB resource on EVERY call,
so the cost tracks the number of CALLS, not the size of the input.

  one call over 200 entities : under a second
  200 calls over one entity  : more than 20x slower

batch your text into one call.
```

## Where the two engines differ

One case, and it is a silent wrong answer. The entity regex is `:i`, so
`&#X41;` with a capital X matches, and the numeric conversion is then
`chr("0" ~ "X41")`. Rakudo raises `Cannot convert string to number`; Raku++
answers **U+0002**.

```raku name="portable"
use HTML::EscapeUtils;

say 'the lowercase form is fine on both:';
say '  unescape("&#x41;") = ', unescape('&#x41;').raku;
say '';
say 'the uppercase-X form is a Rakudo throw and a Raku++ U+0002. Reject';
say 'it before you get there:';
sub numeric-ok(Str $s) { $s !~~ / '&#' <[X]> / }
for '&#x41;', '&#X41;' -> $e {
    say sprintf('  %-10s acceptable ? %s', $e.raku, numeric-ok($e));
}
say '';
say 'and note what escape does NOT do: no numeric-reference escaping is';
say 'available at all, so if a consumer needs &#x27; rather than &apos;';
say 'you have to build it yourself.';
```

```output
the lowercase form is fine on both:
  unescape("&#x41;") = "A"

the uppercase-X form is a Rakudo throw and a Raku++ U+0002. Reject
it before you get there:
  "\&#x41;"  acceptable ? True
  "\&#X41;"  acceptable ? False

and note what escape does NOT do: no numeric-reference escaping is
available at all, so if a consumer needs &#x27; rather than &apos;
you have to build it yourself.
```
