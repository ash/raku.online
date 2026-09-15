#!/usr/bin/env rakupp
# Browser::Open — Where the two engines differ
# https://raku.online/modules/browser-open/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Browser::Open
#     rakupp 04-table.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Browser::Open;

say 'what the table holds for this kernel, in order, is an implementation';
say 'detail — but which one won is not:';
say '  chosen : ', open-browser-cmd();
say '';
say 'two dead branches worth knowing about, since they explain the shape';
say 'of the code: two entries carry an unused fourth field $no_search, and';
say 'no row ever sets it, so `next if $no_search && …` and';
say '`return $cmd if $no_search` are both unreachable.';
say '';
say 'on Windows the distribution declares a Win32::Registry dependency,';
say 'which is not in the ecosystem index — `rakupp test` reports it as';
say 'skipped by distro name, which is correct off Windows.';

# Output:
#     what the table holds for this kernel, in order, is an implementation
#     detail — but which one won is not:
#       chosen : /usr/bin/open
#     
#     two dead branches worth knowing about, since they explain the shape
#     of the code: two entries carry an unused fourth field $no_search, and
#     no row ever sets it, so `next if $no_search && …` and
#     `return $cmd if $no_search` are both unreachable.
#     
#     on Windows the distribution declares a Win32::Registry dependency,
#     which is not in the ecosystem index — `rakupp test` reports it as
#     skipped by distro name, which is correct off Windows.
