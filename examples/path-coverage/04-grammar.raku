#!/usr/bin/env rakupp
# path-coverage — Where the two engines differ
# https://raku.online/modules/path-coverage/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install path-coverage
#     rakupp 04-grammar.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

say 'one implementation detail worth knowing, because it explains the';
say 'shape of the output: the grammar`s TOP requires a `unit` declaration';
say 'immediately followed by a `my unit` declaration on the same line,';
say 'which a real line of source essentially never satisfies.';
say '';
say 'the tool produces output anyway, because Raku action methods fire';
say 'for sub-rules that matched even when the overall parse fails. The';
say 'entire output is a side effect of a parse that never succeeds.';
say '';
say 'both scripts start #!/usr/bin/env perl6. That works through the';
say 'installed ~/.raku/bin wrappers on both engines, but the shebang';
say 'itself would need a perl6 on PATH if you ran the file directly.';

# Output:
#     one implementation detail worth knowing, because it explains the
#     shape of the output: the grammar`s TOP requires a `unit` declaration
#     immediately followed by a `my unit` declaration on the same line,
#     which a real line of source essentially never satisfies.
#     
#     the tool produces output anyway, because Raku action methods fire
#     for sub-rules that matched even when the overall parse fails. The
#     entire output is a side effect of a parse that never succeeds.
#     
#     both scripts start #!/usr/bin/env perl6. That works through the
#     installed ~/.raku/bin wrappers on both engines, but the shebang
#     itself would need a perl6 on PATH if you ran the file directly.
