#!/usr/bin/env rakupp
# Digest::SHA256::Native — Both subs
# https://raku.online/modules/digest-sha256-native/#both-subs
#
# Install what it needs, then run it:
#     rakupp install Digest::SHA256::Native
#     rakupp 01-hash.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::SHA256::Native;

say sha256-hex('hello');
say sha256-hex('');
say sha256-hex('hello').chars;

# Output:
#     2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
#     e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
#     64
