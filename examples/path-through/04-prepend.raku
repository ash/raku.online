#!/usr/bin/env rakupp
# Path::Through — Where the two engines differ
# https://raku.online/modules/path-through/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Path::Through
#     rakupp 04-prepend.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Through;

say 'prepend is $prepend.IO.add($path):';
say '  prepend("/b".IO, "a")  -> engine-dependent separator';
say '  prepend("b".IO,  "a")  -> ', prepend('b'.IO, 'a').Str, '   <- agrees';
say '';
say 'so prepend a RELATIVE path, or normalise afterwards:';
say '  .cleanup : ', prepend('/b'.IO, 'a').cleanup.Str;
say '';
say 'one more, introspection only: after importing this module,';
say '&pop.candidates lists the core candidates merged in under Rakudo and';
say 'only the module`s own under Raku++. Dispatch is correct on both —';
say 'core pop on an Array still works — but anything that reasons over';
say '.candidates will get the wrong answer on Raku++.';
my @a = 1, 2, 3;
say '  core pop still works : ', pop(@a), ' leaving ', @a.raku;

# Output:
#     prepend is $prepend.IO.add($path):
#       prepend("/b".IO, "a")  -> engine-dependent separator
#       prepend("b".IO,  "a")  -> a/b   <- agrees
#     
#     so prepend a RELATIVE path, or normalise afterwards:
#       .cleanup : a/b
#     
#     one more, introspection only: after importing this module,
#     &pop.candidates lists the core candidates merged in under Rakudo and
#     only the module`s own under Raku++. Dispatch is correct on both —
#     core pop on an Array still works — but anything that reasons over
#     .candidates will get the wrong answer on Raku++.
#       core pop still works : 3 leaving [1, 2]
