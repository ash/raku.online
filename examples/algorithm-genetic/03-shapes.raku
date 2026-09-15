#!/usr/bin/env rakupp
# Algorithm::Genetic — Three more shapes
# https://raku.online/modules/algorithm-genetic/#three-more-shapes
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Genetic
#     rakupp 03-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Genetic;

say 'two things the examples above do deliberately.';
say '';
say 'first, `use Algorithm::Genetic::Genotype` as well — the `is mutable`';
say 'trait is exported from THAT unit, and Rakudo will not compile an';
say 'attribute carrying it without the second use line.';
say '';
say 'second, they supply selection-strategy directly rather than composing';
say 'Selection::Roulette. Composing both roles trips';
say 'Algorithm::Genetic`s own required-method check before Roulette has';
say 'supplied the method, whichever order you write them in.';
say '';
say 'Algorithm::Genetic and friends are ROLES, not classes — punning is';
say 'not usable, and only Rakudo tells you why ("Method is-finished must';
say 'be implemented").';
say '';
say '`is mutable` requires a Callable — `is mutable(42)` dies with the';
say 'module`s own message, spelling and all.';
say '';
say '.score CACHES on first call, so a mutated genotype keeps a stale';
say 'score until you call .re-score. crossover calls .?re-score on the';
say 'children; mutate does not.';
say '';
say '!sort-population sorts ASCENDING and Roulette selects from the top of';
say 'that order — so HIGHER score means fitter. The distribution`s own';
say 'example scores with a squared error, where lower is better, which';
say 'inverts the search. Negate your error.';
say '';
say 'and evolve only re-initialises when the population is EMPTY, so';
say 'calling it twice continues rather than restarts.';

# Output:
#     two things the examples above do deliberately.
#     
#     first, `use Algorithm::Genetic::Genotype` as well — the `is mutable`
#     trait is exported from THAT unit, and Rakudo will not compile an
#     attribute carrying it without the second use line.
#     
#     second, they supply selection-strategy directly rather than composing
#     Selection::Roulette. Composing both roles trips
#     Algorithm::Genetic`s own required-method check before Roulette has
#     supplied the method, whichever order you write them in.
#     
#     Algorithm::Genetic and friends are ROLES, not classes — punning is
#     not usable, and only Rakudo tells you why ("Method is-finished must
#     be implemented").
#     
#     `is mutable` requires a Callable — `is mutable(42)` dies with the
#     module`s own message, spelling and all.
#     
#     .score CACHES on first call, so a mutated genotype keeps a stale
#     score until you call .re-score. crossover calls .?re-score on the
#     children; mutate does not.
#     
#     !sort-population sorts ASCENDING and Roulette selects from the top of
#     that order — so HIGHER score means fitter. The distribution`s own
#     example scores with a squared error, where lower is better, which
#     inverts the search. Negate your error.
#     
#     and evolve only re-initialises when the population is EMPTY, so
#     calling it twice continues rather than restarts.
