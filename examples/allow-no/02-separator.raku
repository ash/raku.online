#!/usr/bin/env rakupp
# allow-no — The one thing to know
# https://raku.online/modules/allow-no/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install allow-no
#     rakupp 02-separator.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use allow-no;

my @args = <-- --no-brainer>;
say 'a user typed:  -- --no-brainer';
say '  the "--" means "everything after this is a positional".';
say '';
say 'the INIT block rewrites every element unconditionally:';
say '  ', @args.map({ .subst(/^ '--no-' /, '--/') }).raku;
say '';
say 'so a filename, a search term, a branch name — anything that happens';
say 'to start with --no- — is silently corrupted, even when the user';
say 'explicitly ended option parsing.';
say '';
say 'Rakudo`s own %*SUB-MAIN-OPTS<allow-no> shares this bug, so it is not';
say 'a reason to prefer one over the other — but it is a reason to reach';
say 'for a real option parser once your CLI has positional arguments that';
say 'come from users.';

# Output:
#     a user typed:  -- --no-brainer
#       the "--" means "everything after this is a positional".
#     
#     the INIT block rewrites every element unconditionally:
#       ("--", "--/brainer").Seq
#     
#     so a filename, a search term, a branch name — anything that happens
#     to start with --no- — is silently corrupted, even when the user
#     explicitly ended option parsing.
#     
#     Rakudo`s own %*SUB-MAIN-OPTS<allow-no> shares this bug, so it is not
#     a reason to prefer one over the other — but it is a reason to reach
#     for a real option parser once your CLI has positional arguments that
#     come from users.
