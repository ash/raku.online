#!/usr/bin/env rakupp
# Doublephone — Coding a name
# https://raku.online/modules/doublephone/#coding-a-name
#
# Install what it needs, then run it:
#     rakupp install Doublephone
#     rakupp 01-phone.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Doublephone;

for <Smith Smyth Schmidt Wright Rait Knight Nite
     Jackson Jaxon Gonzalez Gonsalez Pfeiffer Xavier Czerny> -> $w {
    my ($p, $s) = double-metaphone($w);
    say sprintf('%-10s primary=%-6s secondary=%-6s same=%s', $w, $p, $s, $p eq $s);
}

# Output:
#     Smith      primary=SM0    secondary=XMT    same=False
#     Smyth      primary=SM0    secondary=XMT    same=False
#     Schmidt    primary=XMT    secondary=SMT    same=False
#     Wright     primary=RT     secondary=RT     same=True
#     Rait       primary=RT     secondary=RT     same=True
#     Knight     primary=NT     secondary=NT     same=True
#     Nite       primary=NT     secondary=NT     same=True
#     Jackson    primary=JKSN   secondary=AKSN   same=False
#     Jaxon      primary=JKSN   secondary=AKSN   same=False
#     Gonzalez   primary=KNSL   secondary=KNSL   same=True
#     Gonsalez   primary=KNSL   secondary=KNSL   same=True
#     Pfeiffer   primary=PFFR   secondary=PFFR   same=True
#     Xavier     primary=SF     secondary=SFR    same=False
#     Czerny     primary=SRN    secondary=XRN    same=False
