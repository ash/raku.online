---
title: Regexes
chapter: Regexes & grammars
summary: Match with ~~, capture with parentheses or names, and rewrite with subst.
---

The smartmatch operator `~~` matches a string against a regex. Whitespace
inside a regex is insignificant, and literal text goes in quotes:

```raku
my $line = 'error: disk full';
if $line ~~ / 'error:' / {
    say 'something went wrong';
}
say so 'camelia' ~~ / me /;
```
```output
something went wrong
True
```

`so` boolifies the match — handy for a quick yes/no.

## Captures

Parentheses capture into `$0`, `$1`, …; prefix a group with a name and it
lands in `$<name>` instead. `\d` matches a digit, `+` means one-or-more:

```raku
if '2026-07-23' ~~ / (\d+) '-' (\d+) '-' (\d+) / {
    say "year { ~$0 }, month { ~$1 }, day { ~$2 }";
}

if 'Bond, James Bond' ~~ / $<last> = [\w+] ',' \s $<first> = [\w+] / {
    say "{ ~$<first> } { ~$<last> }";
}
```
```output
year 2026, month 07, day 23
James Bond
```

## Substitution and global matching

`.subst` replaces (with `:g` for *every* occurrence), and `m:g/.../ ` finds
all matches:

```raku
say 'banana'.subst('a', 'o', :g);
my @nums = ('10 cats, 7 dogs, 3 parrots' ~~ m:g/ \d+ /);
say @nums.map(+*).sum;
```
```output
bonono
20
```

`+*` turns each match into a number — "whatever, numified".

## Try it

Extract the user and host from the address with named captures. (`\w+`
matches a word; you'll need `'@'` and `'.'` as quoted literals.)

```raku exercise
if 'camelia@raku.org' ~~ / / {
    say ~$<user>;
    say ~$<host>;
}
```

```solution
if 'camelia@raku.org' ~~ / $<user> = [\w+] '@' $<host> = [\w+ '.' \w+] / {
    say ~$<user>;
    say ~$<host>;
}
```
```output
camelia
raku.org
```
