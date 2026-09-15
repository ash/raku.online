#!/usr/bin/env rakupp
# Unicode::PRECIS — Enforcing a profile
# https://raku.online/modules/unicode-precis/#enforcing-a-profile
#
# Install what it needs, then run it:
#     rakupp install Unicode::PRECIS
#     rakupp 01-enforce.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;
use Unicode::PRECIS::Identifier::UsernameCasePreserved;
use Unicode::PRECIS::FreeForm::OpaqueString;

my $cm = Unicode::PRECIS::Identifier::UsernameCaseMapped.new;
my $cp = Unicode::PRECIS::Identifier::UsernameCasePreserved.new;
my $op = Unicode::PRECIS::FreeForm::OpaqueString.new;

sub show($name, $obj, $in) {
    my $r = $obj.enforce($in);
    say sprintf('%-14s %-26s -> %s', $name, $in.raku,
        $r ~~ Str ?? $r.raku !! 'rejected');
}

show 'CaseMapped',    $cm, 'BobSmith';
show 'CasePreserved', $cp, 'BobSmith';
show 'CaseMapped',    $cm, 'correct horse battery';
show 'OpaqueString',  $op, 'correct horse battery';
show 'OpaqueString',  $op, '';

# Output:
#     CaseMapped     "BobSmith"                 -> "bobsmith"
#     CasePreserved  "BobSmith"                 -> "BobSmith"
#     CaseMapped     "correct horse battery"    -> rejected
#     OpaqueString   "correct horse battery"    -> "correct horse battery"
#     OpaqueString   ""                         -> rejected
