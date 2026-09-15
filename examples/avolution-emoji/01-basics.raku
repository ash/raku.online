#!/usr/bin/env rakupp
# Avolution::Emoji — Using it
# https://raku.online/modules/avolution-emoji/#using-it
#
# Install what it needs, then run it:
#     rakupp install Avolution::Emoji
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Avolution::Emoji;

say Avolution::Emoji.emoji('hi :smile: there');
say Avolution::Emoji.emoji(':SMILE: works too — the match is case-insensitive');
say Avolution::Emoji.emoji('and it is global: :smile: :smile:');
say Avolution::Emoji.emoji('unknown markers pass through: :not-an-emoji:');
say '';
say 'it works on the type object and on an instance:';
say '  type     : ', Avolution::Emoji.emoji(':tada:');
say '  instance : ', Avolution::Emoji.new.emoji(':tada:');
say '  returns  : ', Avolution::Emoji.emoji(':tada:').WHAT.^name;

# Output:
#     hi 😀 there
#     😀 works too — the match is case-insensitive
#     and it is global: 😀 😀
#     unknown markers pass through: :not-an-emoji:
#     
#     it works on the type object and on an instance:
#       type     : :tada:
#       instance : :tada:
#       returns  : Str
