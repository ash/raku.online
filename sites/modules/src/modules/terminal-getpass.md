---
name: Terminal::Getpass
version: 0.0.11
auth: zef:titsuki
kind: Distribution · terminal
summary: Read a password from the terminal with echo switched off — one
  sub, a prompt, and the terminal restored afterwards however it ends.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: Term::termios
raku-land: https://raku.land/zef:titsuki/Terminal::Getpass
source: https://github.com/titsuki/raku-Terminal-Getpass
---

## What it is for

A program that asks for a password must not print it. The terminal echoes
every keystroke by default, so the program has to turn that off, read the
line, and turn it back on — including when the user presses Ctrl-C
halfway, which is when leaving a terminal with echo disabled is most
annoying.

That is three calls into the terminal driver and a signal handler, and it
is the same three calls in every program. This distribution is them, as one
sub.

## Reading a password

```raku fragment
use Terminal::Getpass;

my $password = getpass();
say 'got ', $password.chars, ' characters';

my $other = getpass('Repeat: ');
say $password eq $other ?? 'they match' !! 'they differ';
```

That example is shown rather than run, because it waits for a person to
type. The prompt is the first argument and goes to standard error, which
means it still appears when the program's output is being redirected — the
right default for something the user must see. The second argument chooses
a different stream for the prompt.

Two control characters are handled: delete removes the previous character,
and Ctrl-C restores the terminal before exiting, so the shell is not left
in a strange state.

## The one thing to know

It needs **standard output** to be a terminal, not standard input:

```raku name="needs-a-tty"
use Terminal::Getpass;

say (try { getpass('never asked: ') }) // $!.message;
say 'still running';
```

```output
tcgetattr failed
still running
```

The implementation asks the driver about file descriptor 1. So a user
sitting at a real terminal, with a real keyboard, running

```sh
$ myprogram | tee install.log
```

cannot type a password: standard input is still the terminal and standard
output is now a pipe, and the call fails before the prompt appears. The
message is `tcgetattr failed`, with no module name and no hint about which
descriptor it means.

It throws rather than hanging, which is the good news — the example above
catches it and carries on. Check `$*OUT.t` before calling, and when it is
false either refuse with a clear message or fall back to an environment
variable or a file, the way other tools do when they detect a pipe.
