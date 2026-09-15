#!/usr/bin/env rakupp
# Text::Caesar — Where the two engines differ
# https://raku.online/modules/text-caesar/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::Caesar
#     rakupp 05-qualified.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Caesar;

my $m = Text::Caesar::Message.new(key => 3, text => 'hi there');
say 'Message.encrypt : ', $m.encrypt;
my $s = Text::Caesar::Secret.new(key => 3, text => $m.encrypt);
say 'Secret.decrypt  : ', $s.decrypt;
say '';
say 'the classes are NOT exported — the fully qualified name is the';
say 'portable spelling. Rakudo rejects the short one at compile time.';

# Output:
#     Message.encrypt : KL WKHUH
#     Secret.decrypt  : HI THERE
#     
#     the classes are NOT exported — the fully qualified name is the
#     portable spelling. Rakudo rejects the short one at compile time.
