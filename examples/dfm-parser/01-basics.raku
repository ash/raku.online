#!/usr/bin/env rakupp
# DFM::Parser — Parsing
# https://raku.online/modules/dfm-parser/#parsing
#
# Install what it needs, then run it:
#     rakupp install DFM::Parser
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use DFM::Parser;

my $dfm = q:to/END/;
object Form1: TForm1
  Left = 192
  Caption = 'Hello'
  Font.Height = -11
  object Panel1: TPanel
    Align = alTop
  end
end
END

my $m = DFM::Parser.parse($dfm);
say 'parsed      : ', $m.defined;
say 'id          : ', $m<object><id>.Str;
say 'classname   : ', $m<object><classname>.Str;
say '';
for $m<object><component>.list -> $c {
    if $c<object> {
        say '  nested object: ', $c<object><classname>.Str;
    } else {
        say sprintf('  %-14s = %s', $c<component-name>.Str, $c<component-value>.Str.trim);
    }
}

# Output:
#     parsed      : True
#     id          : Form1
#     classname   : TForm1
#     
#       Left           = 192
#       Caption        = 'Hello'
#       Font.Height    = -11
#       nested object: TPanel
