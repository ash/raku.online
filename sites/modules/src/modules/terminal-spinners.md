---
name: Terminal::Spinners
version: 1.6.0
auth: github:ryn1x
kind: Distribution · terminal
summary: Progress spinners and percentage bars for a terminal — ten
  animations and four bar styles, drawn by backspacing over the previous
  frame.
status: full
suite: 5 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/github:ryn1x/Terminal::Spinners
source: https://github.com/ryn1x/Terminal-Spinners
---

## What it is for

A command-line program that takes ten seconds should say so while it does.
The cheapest way is one character that changes: a slash becoming a dash
becoming a backslash, with a backspace before each so the line never grows.
The second cheapest is a bar with a percentage on the end. Neither needs a
terminal library, a cursor address or a redraw loop — just the right
characters and a backspace, which is what this distribution supplies.

Ten frame sets and four bar styles, as two classes.

## Frames and bars

```raku name="frames"
use Terminal::Spinners;

my $s = Spinner.new;
say $s.type, ' at ', $s.speed, 's a frame';
say (^4).map({ $s.next(:nop, :now) }).raku;

for <classic bounce dots three-dots bar> -> $t {
    say sprintf('%-11s %s', $t,
                (^3).map({ Spinner.new(:type($t)).next(:nop, :now) }).raku);
}

my $b = Bar.new(:length(26));
say $b.show(0,   :nop, :now).raku;
say $b.show(40,  :nop, :now).raku;
say $b.show(100, :nop, :now).raku;
for <hash-dash equals bar> -> $t {
    say sprintf('%-10s %s', $t, Bar.new(:type($t), :length(22)).show(60, :nop, :now).raku);
}
```

```output
classic at 0.08s a frame
("|", "/", "-", "\\").Seq
classic     ("|", "|", "|").Seq
bounce      ("[=   ]", "[=   ]", "[=   ]").Seq
dots        ("⠋", "⠋", "⠋").Seq
three-dots  (".  ", ".  ", ".  ").Seq
bar         ("▁", "▁", "▁").Seq
"[.................]  0.00\%"
"[######...........] 40.00\%"
"[#################]100.00\%"
hash-dash  "[#######------] 60.00\%"
equals     "[=======      ] 60.00\%"
bar        "█████████░░░░░░ 60.00\%"
```

The two adverbs are what make those lines printable on a web page. `:nop`
returns the frame instead of printing it, and `:now` leaves off the
backspaces that would otherwise be at the front. In a real program you pass
neither, and the call draws.

## The one thing to know

Those adverbs are not decoration: without them, `.next` **prints** and
**sleeps**, and the value it returns is prefixed with backspaces.

```raku name="side-effects"
use Terminal::Spinners;

my $s = Spinner.new;
say $s.next(:now).raku;
say $s.next.raku;

my $t0 = now;
$s.next(:nop);
my $quiet = now - $t0;
my $t1 = now;
$s.next;
my $drew = now - $t1;
say $quiet < 0.02;
say $drew >= 0.05;

say Bar.new.show(10, :nop).comb.grep("\b").elems;
```

```output
|"|"
/"\b/"
\True
True
80
```

So `say $spinner.next` prints the frame twice — once as a side effect and
once as the value — and backspaces over whatever you printed before it. And
a peek at the current frame costs the animation delay, eighty milliseconds
by default, because the sleep is in the same method as the draw.

The last line is the sharper version of the same trap. A `Bar` emits one
backspace per character of its declared length, and the default length is
80 — so the very first `show` erases up to eighty characters of whatever
was already on the line, before it has drawn anything to erase. Pass `:now`
on the first call, or print a newline before you start.

Two smaller things: an unknown spinner type is accepted by the constructor
and only fails at the first frame, and an unknown *bar* type never fails at
all — it silently draws a percentage with no bar in front of it.
