#!/usr/bin/env rakupp
# Data::DPath6 — What to use instead
# https://raku.online/modules/data-dpath6/#what-to-use-instead
#
# Install what it needs, then run it:
#     rakupp install Data::DPath6
#     rakupp 03-alternative.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

say 'Raku`s own postcircumfix and Hash/Array methods cover most of what';
say 'a DPath expression would:';
my %data = servers => [
    %( name => 'alpha', tags => <web prod> ),
    %( name => 'beta',  tags => <db staging> ),
    %( name => 'gamma', tags => <web staging> ),
];

say '  all server names        : ', %data<servers>.map(*<name>).join(', ');
say '  names tagged "web"      : ',
    %data<servers>.grep({ 'web' (elem) .<tags> }).map(*<name>).join(', ');
say '  deep, with a fallback   : ', (%data<servers>[9]<name> // '(none)');
say '';
say 'and for a genuine query language over nested data, the ecosystem has';
say 'JSON::Path and XML::XPath, both of which do the thing this name';
say 'suggests.';

# Output:
#     Raku`s own postcircumfix and Hash/Array methods cover most of what
#     a DPath expression would:
#       all server names        : alpha, beta, gamma
#       names tagged "web"      : alpha, gamma
#       deep, with a fallback   : (none)
#     
#     and for a genuine query language over nested data, the ecosystem has
#     JSON::Path and XML::XPath, both of which do the thing this name
#     suggests.
