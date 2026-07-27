---
title: Grammars
chapter: Regexes & grammars
summary: Grammars organise regexes into named rules — a real parser as a language feature.
---

A grammar is a class whose methods are regexes. `TOP` is the entry point, and
`.parse` matches the whole string against it:

```raku
grammar Numbers {
    token TOP { <num>+ % [',' \s*] }
    token num { \d+ }
}

my $m = Numbers.parse('1, 22, 333');
say so $m;
say $m<num>.map(+*).sum;
```
```output
True
356
```

`<num>` calls the `num` token by name; `+ % [',' \s*]` means "one or more,
separated by commas". Every named rule that matched is available on the match
object — `$m<num>` is the list of all three numbers.

## A tiny config parser

Nested rules build real structure. Here's an entire key–value file format:

```raku
grammar Config {
    token TOP   { <entry>+ }
    token entry { <key> '=' <value> \n? }
    token key   { \w+ }
    token value { <-[\n]>+ }
}

my $conf = Config.parse("name=Camelia\ncolor=purple\n");
for $conf<entry>.list -> $e {
    say "{ $e<key> } is { $e<value> }";
}
```
```output
name is Camelia
color is purple
```

`<-[\n]>` is a negated character class — "anything but a newline". Grammars
are how Raku programs parse configuration files, log lines, and — in more
than one real project — entire programming languages.

## Try it

Extend `Sums` so it also allows `-` between numbers (square brackets group
alternatives: `['+' || '-']`), then make the test string parse.

```raku exercise
grammar Sums {
    token TOP { <num>+ % '+' }
    token num { \d+ }
}

say so Sums.parse('1+2-3');
```

```solution
grammar Sums {
    token TOP { <num>+ % ['+' || '-'] }
    token num { \d+ }
}

say so Sums.parse('1+2-3');
```
```output
True
```
