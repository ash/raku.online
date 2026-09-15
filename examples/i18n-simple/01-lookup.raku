#!/usr/bin/env rakupp
# I18n::Simple — Keys, slots, and layering
# https://raku.online/modules/i18n-simple/#keys-slots-and-layering
#
# Install what it needs, then run it:
#     rakupp install I18n::Simple
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use I18n::Simple;

my $dir = $*TMPDIR.add("i18n-{$*PID}");
$dir.mkdir;
$dir.add('en.yml').spurt: q:to/YAML/;
    greeting: "Hello, $(name)!"
    invoice: "$(name), you owe $(amount) euro."
    plain: "No placeholders here"
    YAML
$dir.add('nl.yml').spurt: q:to/YAML/;
    greeting: "Hallo, $(name)!"
    YAML

i18n-init($dir.add('en.yml').Str);
say i18n('greeting', :name<Ada>);
say i18n('invoice', :name<Ada>, :amount(42));
say i18n('plain');

i18n-init($dir.add('nl.yml').Str);
say i18n('greeting', :name<Ada>);
say i18n('invoice', :name<Ada>, :amount(42));

.unlink for $dir.dir;
$dir.rmdir;

# Output:
#     Hello, Ada!
#     Ada, you owe 42 euro.
#     No placeholders here
#     Hallo, Ada!
#     Ada, you owe 42 euro.
