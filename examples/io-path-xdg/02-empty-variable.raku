#!/usr/bin/env rakupp
# IO::Path::XDG — The one thing to know
# https://raku.online/modules/io-path-xdg/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install IO::Path::XDG
#     rakupp 02-empty-variable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

%*ENV<XDG_CONFIG_HOME> = '';

use IO::Path::XDG;

# the guard: treat an empty value as absent, as the specification says
sub config-home-or-default {
    my $set = %*ENV<XDG_CONFIG_HOME>;
    ($set // '').trim ?? $set.IO !! $*HOME.add('.config')
}

say config-home-or-default().add('app.toml').absolute.starts-with($*HOME.Str);
say (%*ENV<XDG_CONFIG_HOME> // '').chars;
say (%*ENV<XDG_CONFIG_HOME>:exists);

# Output:
#     True
#     0
#     True
