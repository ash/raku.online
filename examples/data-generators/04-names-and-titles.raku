#!/usr/bin/env rakupp
# Data::Generators — Words
# https://raku.online/ecosystem/data-generators/#words
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 04-names-and-titles.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

say random-pet-name(4, species => 'Cat');
say random-pretentious-job-title(2);

# One run printed:
#     (Polly Butchie Quinn Maggie)
#     (Relational Factors Representative Interactive Operations Orchestrator)
