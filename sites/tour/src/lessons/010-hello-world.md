---
title: Hello, world
chapter: Welcome
summary: Your first Raku program runs right here on this page — edit it and run it again.
---

Welcome to the tour. Every code block you'll see is a small working program,
running **in your browser** — nothing to install, nothing sent to a server.
This one has already run:

```raku run
say 'Hello, World!';
```
```output
Hello, World!
```

Click into the code, change the text, and press **Run** (or Ctrl-Enter).
The output updates instantly.

## say and print

`say` prints its arguments followed by a newline. `print` does the same without
the newline. `say` is what you'll use most.

```raku
print 'Hello, ';
print 'World';
say '!';
say 40 + 2;
```
```output
Hello, World!
42
```

As you can see, `say` is happy to print numbers too — and evaluates any
expression you give it.

## Comments

Anything from `#` to the end of the line is a comment.

```raku
# This line does nothing.
say 'But this one runs.';   # ...and this comment is ignored
```
```output
But this one runs.
```

## Try it

Make this program greet Raku instead of shouting into the void.

```raku exercise
# Print: Hello, Raku!
```

When you're ready, use the **Next** button below (or the → key) to continue.
