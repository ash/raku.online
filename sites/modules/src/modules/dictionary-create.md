---
name: Dictionary::Create
version: *
auth: github:prodotiscus
kind: Distribution · text
summary: A string builder for DSL dictionary markup — where one of its five
  tag methods cannot succeed with any argument.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Apache-License-2.0
depends: none beyond the core
raku-land: https://raku.land/github:prodotiscus/Dictionary::Create
source: git://github.com/prodotiscus/perl6-Dictionary-Create.git
---

## What it is for

DSL is the markup that Lingvo-family dictionaries use: `[m1]…[/m]` for an
indent level, `[trn]…[/trn]` for a translation, `[ex]…[/ex]` for an example.
Writing it by hand is error-prone; this distribution builds the strings for
you and accumulates an article body.

## Building an article

```raku name="basics"
use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
$a.set-title('rakupp');
$a.append-line($a.m-tag(1,
    $a.space([$a.translation('a Raku engine'), $a.example('rakupp foo.raku')])));
$a.set-newline;
$a.append-line($a.m-tag(2,
    $a.space([$a.comment('see also'), $a.url('https://example.invalid')])));

say $a.give;
```

```output
rakupp
	[m1][trn]a Raku engine[/trn] [ex]rakupp foo.raku[/ex][/m]

	[m2][com]see also[/com] [url]https://example.invalid[/url][/m]
```

## The tag builders

```raku name="tags"
use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
for <translation example comment index-exclude multimedia url popup accent
     reference mark-secondary> -> $m {
    say sprintf('  %-16s -> %s', $m, $a."$m"('X'));
}
say '';
say '  m-tag(3, "X")   -> ', $a.m-tag(3, 'X');
say '  space(<A B C>)  -> ', $a.space(<A B C>).raku;
say '';
say 'every one of those is a PURE function from a string to a wrapped';
say 'string — none of them touches the article.';
```

```output
  translation      -> [trn]X[/trn]
  example          -> [ex]X[/ex]
  comment          -> [com]X[/com]
  index-exclude    -> [!trs]X[/!trs]
  multimedia       -> [s]X[/s]
  url              -> [url]X[/url]
  popup            -> [p]X[/p]
  accent           -> [']X[/']
  reference        -> [ref]X[/ref]
  mark-secondary   -> [*]X[/*]

  m-tag(3, "X")   -> [m3]X[/m]
  space(<A B C>)  -> "A B C"

every one of those is a PURE function from a string to a wrapped
string — none of them touches the article.
```

## The accumulator

```raku name="accumulator"
use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
say 'give() on a fresh article : ', $a.give.raku, '   <- the Str TYPE OBJECT';
say '  .defined                : ', $a.give.defined;
say '';
$a.append('hello');
say 'append before set-title   : ', $a.give.raku;
say '  (append unconditionally prefixes a space; append-line prefixes';
say '   "\n\t". There is no way to append without whitespace.)';
say '';
$a.set-title('one');
$a.append('body');
$a.set-title('two');
say 'set-title REPLACES the whole body : ', $a.give.raku;
say '';
say 'so call set-title first, once.';
say '';
say 'set-title accepts Str or Int and nothing else:';
for 42, 1.5 -> $t {
    my $b = Dictionary::Create::DSL::Article.new;
    my $r = try $b.set-title($t);
    say sprintf('  set-title(%-6s) -> %s', $t.raku, $! ?? 'refused' !! $b.give.raku);
}
```

```output
give() on a fresh article : Str   <- the Str TYPE OBJECT
  .defined                : False

append before set-title   : " hello"
  (append unconditionally prefixes a space; append-line prefixes
   "\n\t". There is no way to append without whitespace.)

set-title REPLACES the whole body : "two"

so call set-title first, once.

set-title accepts Str or Int and nothing else:
  set-title(42    ) -> "42"
  set-title(1.5   ) -> refused
```

## The one thing to know

`add-font-tag` cannot succeed. With any argument, on either engine.

```raku name="font"
use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
for 'b', 'u', 'i', 'c', 'z', '' -> $tag {
    my $r = try $a.add-font-tag($tag, 'X');
    say sprintf('  add-font-tag(%-4s, "X") -> %s', $tag.raku,
                $! ?? 'threw ' ~ $!.^name !! $r.raku);
}
say '';
say 'the body is';
say '  my Str $left = not %params ?? "[$tag]" !! "[$tag " ~ … ~ "]";';
say 'and `not` binds LOOSER than ?? !!, so the whole ternary is negated';
say 'and a Bool is assigned to a Str.';
say '';
say 'there is a second precedence slip in the same method: the tag';
say 'validation reads  if ( ! $tag ~~ /^ [b||u||i||c] $/ )  which parses';
say 'as (!$tag) ~~ /…/ and is always falsy, so `die "Wrong tag was';
say 'given!"` is unreachable code.';
say '';
say 'one in five of the class`s methods is dead, and the validation it';
say 'advertises never runs. Build font tags yourself:';
sub font-tag(Str $tag, Str $text) { "[$tag]$text\[/$tag]" }
say '  font-tag("b", "X") = ', font-tag('b', 'X');
```

```output
  add-font-tag("b" , "X") -> threw X::TypeCheck::Assignment
  add-font-tag("u" , "X") -> threw X::TypeCheck::Assignment
  add-font-tag("i" , "X") -> threw X::TypeCheck::Assignment
  add-font-tag("c" , "X") -> threw X::TypeCheck::Assignment
  add-font-tag("z" , "X") -> threw X::TypeCheck::Assignment
  add-font-tag(""  , "X") -> threw X::TypeCheck::Assignment

the body is
  my Str $left = not %params ?? "[$tag]" !! "[$tag " ~ … ~ "]";
and `not` binds LOOSER than ?? !!, so the whole ternary is negated
and a Bool is assigned to a Str.

there is a second precedence slip in the same method: the tag
validation reads  if ( ! $tag ~~ /^ [b||u||i||c] $/ )  which parses
as (!$tag) ~~ /…/ and is always falsy, so `die "Wrong tag was
given!"` is unreachable code.

one in five of the class`s methods is dead, and the validation it
advertises never runs. Build font tags yourself:
  font-tag("b", "X") = [b]X[/b]
```

## Where the two engines differ

`language` takes `Hash %properties`, which means `Associative[Hash]` — a hash
whose *values* are Hashes — not "a Hash". Raku++ accepts a plain `Hash` there
and Rakudo refuses it, so the method is reachable on one engine and not the
other.

```raku name="language"
use Dictionary::Create;

say 'with no properties it works on Raku++ and is refused on Rakudo —';
say 'even an empty Hash is not an Associative[Hash].';
say '';
say 'with one property it works on Raku++ and is';
say '"expected Associative[Hash] but got Hash" on Rakudo. And passing';
say 'what the signature actually demands produces nonsense on both:';
say '  my Hash %one = k => %(v => 1);';
say '  $a.language(%one, "X")  ->  [lang k="v<TAB>1"]X[/lang]';
say '';
say 'so treat language as unusable, and write the tag yourself:';
sub lang-tag(Str $text, Str :$name) {
    $name.defined ?? "[lang name=\"$name\"]$text\[/lang]" !! "[lang]$text\[/lang]"
}
say '  lang-tag("X")               = ', lang-tag('X');
say '  lang-tag("X", name => "ru") = ', lang-tag('X', name => 'ru');
say '';
say 'one naming note: Dictionary::Create::DSL is an EMPTY class. Reach';
say 'for Dictionary::Create::DSL::Article, which is where everything is.';
```

```output
with no properties it works on Raku++ and is refused on Rakudo —
even an empty Hash is not an Associative[Hash].

with one property it works on Raku++ and is
"expected Associative[Hash] but got Hash" on Rakudo. And passing
what the signature actually demands produces nonsense on both:
  my Hash %one = k => %(v => 1);
  $a.language(%one, "X")  ->  [lang k="v<TAB>1"]X[/lang]

so treat language as unusable, and write the tag yourself:
  lang-tag("X")               = [lang]X[/lang]
  lang-tag("X", name => "ru") = [lang name="ru"]X[/lang]

one naming note: Dictionary::Create::DSL is an EMPTY class. Reach
for Dictionary::Create::DSL::Article, which is where everything is.
```
