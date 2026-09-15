---
name: Inline::BASIC
version: 0.0.2
auth: zef:slavenskoj
kind: Distribution · languages
summary: Runs a line-numbered BASIC program from a Raku string — where every
  expression goes through EVAL, so `2 ^ 10` prints 210.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:slavenskoj/Inline::BASIC
source: https://github.com/slavenskoj/raku-inline-basic.git
---

## What it is for

Running a line-numbered BASIC program — the kind that starts `10 PRINT` — from
inside a Raku program. Nostalgia, teaching material, a retro-computing toy, or
reviving a listing from a magazine.

## Running a program

```raku name="basics"
use Inline::BASIC;

basic(q:to/END/);
10 PRINT "HELLO, WORLD!"
20 LET A = 42
30 PRINT A
40 IF A > 10 THEN PRINT "A IS BIG"
50 FOR I = 1 TO 3
60 PRINT I
70 NEXT I
80 END
END
```

```output
HELLO, WORLD!
42
A IS BIG
1
2
3
```

```raku name="statements"
use Inline::BASIC;

basic(q:to/END/);
10 REM the statements it knows
20 DATA 11, 22
30 READ X
40 READ Y
50 PRINT X + Y
60 GOSUB 100
70 FOR I = 10 TO 1 STEP -3
80 PRINT I;
90 NEXT I
95 END
100 PRINT "IN SUBROUTINE"
110 RETURN
END
say '';
say 'PRINT INPUT LET GOTO GOSUB RETURN IF/THEN FOR/TO/STEP NEXT END STOP';
say 'REM DATA READ RESTORE DIM, plus a bare VAR = expr.';
```

```output
33
IN SUBROUTINE
10741
PRINT INPUT LET GOTO GOSUB RETURN IF/THEN FOR/TO/STEP NEXT END STOP
REM DATA READ RESTORE DIM, plus a bare VAR = expr.
```

## The one thing to know

Expressions are not interpreted. Variable names are textually substituted into
the expression string and the result is handed to Raku's `EVAL` — so BASIC
operators mean whatever Raku says they mean.

```raku name="eval"
use Inline::BASIC;

basic(q:to/END/);
10 PRINT 7 / 2
20 PRINT 2 ** 10
30 PRINT 2 ^ 10
40 PRINT 1 / 3
END
say '';
say 'line 30 is the one to look at. BASIC`s exponent operator becomes';
say 'Raku`s one() junction constructor, and PRINT autothreads it — so';
say 'both operands come out in sequence and 2^10 prints 210.';
say '';
say 'a user writing 2^10 gets a plausible-looking number that is neither';
say '1024 nor an error. Write ** instead.';
say '';
say 'and because expressions go through EVAL, arbitrary Raku runs from';
say 'what looks like BASIC source. Do not feed this untrusted input.';
```

```output
3.5
1024
210
0.333333

line 30 is the one to look at. BASIC`s exponent operator becomes
Raku`s one() junction constructor, and PRINT autothreads it — so
both operands come out in sequence and 2^10 prints 210.

a user writing 2^10 gets a plausible-looking number that is neither
1024 nor an error. Write ** instead.

and because expressions go through EVAL, arbitrary Raku runs from
what looks like BASIC source. Do not feed this untrusted input.
```

## The three built-in functions are broken

```raku name="builtins"
use Inline::BASIC;

basic(q:to/END/);
10 PRINT RND()
20 PRINT INT(3.7)
30 PRINT ABS(-9)
40 PRINT floor(3.7)
50 PRINT abs(-9)
END
say '';
say 'RND() is rewritten to the text `rand()`, which Raku rejects outright;';
say 'evaluate-expression swallows the failure in a bare try and returns 0.';
say 'So RND() is a constant zero — forty consecutive PRINT RND() lines';
say 'produce forty identical zeros.';
say '';
say 'INT(x) and ABS(x) are rewritten by an s/// whose replacement is a';
say 'STRING, so the expression becomes the literal text "floor(3.7)" and';
say 'EVALs to that string rather than to 3.';
say '';
say 'the workaround is on lines 40 and 50: write the Raku names in lower';
say 'case and they pass straight through EVAL.';
```

```output
0
floor(3.7)
abs(-9)
3
9

RND() is rewritten to the text `rand()`, which Raku rejects outright;
evaluate-expression swallows the failure in a bare try and returns 0.
So RND() is a constant zero — forty consecutive PRINT RND() lines
produce forty identical zeros.

INT(x) and ABS(x) are rewritten by an s/// whose replacement is a
STRING, so the expression becomes the literal text "floor(3.7)" and
EVALs to that string rather than to 3.

the workaround is on lines 40 and 50: write the Raku names in lower
case and they pass straight through EVAL.
```

## Silent zeros and hard dies

```raku name="failures"
use Inline::BASIC;

basic(q:to/END/);
10 PRINT SQR(9)
20 PRINT LEN("hello")
30 PRINT 1 +
40 PRINT "abc" x 3
END
say '';
say 'any expression Raku cannot evaluate becomes 0, with no warning.';
say '(line 40 prints abc0 — the string-literal branch consumes "abc" and';
say 'the remaining ` x 3` fails its own EVAL to 0.)';
say '';
say 'but an unrecognised STATEMENT aborts the whole program:';
my $r = try basic("10 PRINT \"one\"\n20 FROBNICATE\n30 PRINT \"three\"\n");
say '  ', $! ?? $!.message !! 'completed';
say '';
say 'and a string assignment needs LET while a numeric one does not,';
say 'because the bare-assignment branch is ^ (\\w+) \\s* "=" and \\w';
say 'excludes $:';
basic("10 LET A\$ = \"HI\"\n20 PRINT A\$\n30 B = 42\n40 PRINT B\n");
```

```output
0
0
0
abc0

any expression Raku cannot evaluate becomes 0, with no warning.
(line 40 prints abc0 — the string-literal branch consumes "abc" and
the remaining ` x 3` fails its own EVAL to 0.)

but an unrecognised STATEMENT aborts the whole program:
one
  ?SYNTAX ERROR IN 20: Unknown statement 'FROBNICATE'

and a string assignment needs LET while a numeric one does not,
because the bare-assignment branch is ^ (\w+) \s* "=" and \w
excludes $:
HI
42
```

## Where the two engines differ

Nothing. Every program on this page, including all three broken built-ins and
the junction, produces byte-identical output on both engines.

```raku name="portable"
use Inline::BASIC;

say 'the API is one exported sub, `basic(Str $code)`, with no useful';
say 'return value. Output goes to stdout as a side effect.';
say '';
say 'class Interpreter is NOT exported and is not reachable, so there is';
say 'no way to inspect variables, capture output, or reuse state between';
say 'programs. Capture stdout yourself if you need the result:';
my $out = class { has @.lines; method print(*@a) { @!lines.push(@a.join) };
                  method say(*@a) { @!lines.push(@a.join) } }.new;
{
    my $*OUT = $out;
    basic("10 PRINT 6 * 7\n");
}
say '  captured : ', $out.lines.raku;
say '';
say 'INPUT reads one line from $*IN and splits it on commas, so a program';
say 'with INPUT will block on an interactive terminal.';
```

```output
the API is one exported sub, `basic(Str $code)`, with no useful
return value. Output goes to stdout as a side effect.

class Interpreter is NOT exported and is not reachable, so there is
no way to inspect variables, capture output, or reuse state between
programs. Capture stdout yourself if you need the result:
  captured : ["42", "\n"]

INPUT reads one line from $*IN and splits it on commas, so a program
with INPUT will block on an interactive terminal.
```
