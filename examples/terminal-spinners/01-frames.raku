#!/usr/bin/env rakupp
# Terminal::Spinners — Frames and bars
# https://raku.online/modules/terminal-spinners/#frames-and-bars
#
# Install what it needs, then run it:
#     rakupp install Terminal::Spinners
#     rakupp 01-frames.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     classic at 0.08s a frame
#     ("|", "/", "-", "\\").Seq
#     classic     ("|", "|", "|").Seq
#     bounce      ("[=   ]", "[=   ]", "[=   ]").Seq
#     dots        ("⠋", "⠋", "⠋").Seq
#     three-dots  (".  ", ".  ", ".  ").Seq
#     bar         ("▁", "▁", "▁").Seq
#     "[.................]  0.00\%"
#     "[######...........] 40.00\%"
#     "[#################]100.00\%"
#     hash-dash  "[#######------] 60.00\%"
#     equals     "[=======      ] 60.00\%"
#     bar        "█████████░░░░░░ 60.00\%"
