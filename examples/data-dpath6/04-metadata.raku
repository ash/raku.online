#!/usr/bin/env rakupp
# Data::DPath6 — Where the two engines differ
# https://raku.online/modules/data-dpath6/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Data::DPath6
#     rakupp 04-metadata.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::DPath6;

say 'one thing about the distribution itself that is worth knowing:';
say 'it is not in the zef index. `rakupp test` resolves it from the REA';
say 'archive and notes that the index path carries no checksum, so TLS is';
say 'the only integrity check on the fetch.';
say '';
say 'its declared source URL uses the git:// scheme, which GitHub no';
say 'longer serves.';
say '';
say 'the version is 0.0.2 and the method is still `hello`.';
say '  ', Data::DPath6.hello;

# Output:
#     one thing about the distribution itself that is worth knowing:
#     it is not in the zef index. `rakupp test` resolves it from the REA
#     archive and notes that the index path carries no checksum, so TLS is
#     the only integrity check on the fetch.
#     
#     its declared source URL uses the git:// scheme, which GitHub no
#     longer serves.
#     
#     the version is 0.0.2 and the method is still `hello`.
#       42
