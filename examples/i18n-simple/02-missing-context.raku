#!/usr/bin/env rakupp
# I18n::Simple — The one thing to know
# https://raku.online/modules/i18n-simple/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install I18n::Simple
#     rakupp 02-missing-context.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use I18n::Simple;

my $dir = $*TMPDIR.add("i18nb-{$*PID}");
$dir.mkdir;
$dir.add('en.yml').spurt: qq:to/YAML/;
    greeting: "Hello, \$(name)!"
    YAML
i18n-init($dir.add('en.yml').Str);

say i18n('greeting', :name<Ada>);
say i18n('greeting');
say (try i18n('greeting', :other<x>)) // $!.message;

.unlink for $dir.dir;
$dir.rmdir;

# Output:
#     Hello, Ada!
#     Hello, $(name)!
#     Unknown variable used: name
