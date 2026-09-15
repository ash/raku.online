#!/usr/bin/env rakupp
# Pod::Tangle — Where the two engines differ
# https://raku.online/modules/pod-tangle/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Pod::Tangle
#     rakupp 04-scope.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Pod::Tangle;

say 'two more things worth knowing before you run this over a project.';
say '';
say '`=begin code` blocks INSIDE pod are stripped along with the prose, so';
say 'tangling a literate file removes its worked examples as well as its';
say 'explanation. If your examples are the code you wanted, this is not';
say 'the tool.';
say '';
say 'and the unit declares `unit module Pod::Tangle:ver<0.0.1>` while the';
say 'distribution META says 0.0.2 — the two disagree.';
say '';
say 'the API is one exported sub: tangle(IO::Path $file --> Str).';

# Output:
#     two more things worth knowing before you run this over a project.
#     
#     `=begin code` blocks INSIDE pod are stripped along with the prose, so
#     tangling a literate file removes its worked examples as well as its
#     explanation. If your examples are the code you wanted, this is not
#     the tool.
#     
#     and the unit declares `unit module Pod::Tangle:ver<0.0.1>` while the
#     distribution META says 0.0.2 — the two disagree.
#     
#     the API is one exported sub: tangle(IO::Path $file --> Str).
