#!/usr/bin/env rakupp
# Text::Lorem — Where the two engines differ
# https://raku.online/modules/text-lorem/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::Lorem
#     rakupp 05-vocabulary.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Lorem;

my $tiny = Text::Lorem.new(lorem-words => <alpha beta gamma>);
say 'a three-word vocabulary, asked for three words:';
say '  ', $tiny.words(3).subst(/'.'$/, '').words.sort.join(' '), ' plus a full stop';
say '';
say 'asked for ten:';
say '  ', $tiny.words(10).words.elems, ' words — the cap again, at 3 this time';

# Output:
#     a three-word vocabulary, asked for three words:
#       alpha beta gamma plus a full stop
#     
#     asked for ten:
#       3 words — the cap again, at 3 this time
