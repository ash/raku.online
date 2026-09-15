#!/usr/bin/env rakupp
# Data::ICal — Four units that are empty files
# https://raku.online/modules/data-ical/#four-units-that-are-empty-files
#
# Install what it needs, then run it:
#     rakupp install Data::ICal
#     rakupp 04-empty-units.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::ICal;

say 'the distribution declares eight units. Four of them —';
say 'Data::ICal::Alarm, ::FreeBusy, ::Journal and ::Todo — are';
say 'ZERO-BYTE files.';
say '';
say '`use Data::ICal::Alarm;` succeeds and declares nothing; referring to';
say 'the name is an error on both engines (at run time on Raku++, at';
say 'compile time on Rakudo).';
say '';
say 'introspection tools that report "class Data::ICal::Alarm with no';
say 'methods" are showing you an artefact of a dynamic lookup, not a fact';
say 'about the distribution.';
say '';
say 'and Data::ICal.Str hard-codes VERSION:2.0 regardless of $.version.';

# Output:
#     the distribution declares eight units. Four of them —
#     Data::ICal::Alarm, ::FreeBusy, ::Journal and ::Todo — are
#     ZERO-BYTE files.
#     
#     `use Data::ICal::Alarm;` succeeds and declares nothing; referring to
#     the name is an error on both engines (at run time on Raku++, at
#     compile time on Rakudo).
#     
#     introspection tools that report "class Data::ICal::Alarm with no
#     methods" are showing you an artefact of a dynamic lookup, not a fact
#     about the distribution.
#     
#     and Data::ICal.Str hard-codes VERSION:2.0 regardless of $.version.
