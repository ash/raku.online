#!/usr/bin/env rakupp
# XML::Writer — What it refuses
# https://raku.online/modules/xml-writer/#what-it-refuses
#
# Install what it needs, then run it:
#     rakupp install XML::Writer
#     rakupp 04-refuses.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use XML::Writer;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-30s %s', $label, $! ?? $!.message !! $r.raku);
}

attempt 'no argument',          { XML::Writer.serialize() };
attempt 'two root elements',    { XML::Writer.serialize(:a[1], :b[2]) };
attempt 'a bare string',        { XML::Writer.serialize('plain') };
attempt 'one root element',     { XML::Writer.serialize(:a[1]) };

# Output:
#     no argument                    Please pass exactly one argument to XML::Writer.serialize
#     two root elements              Please pass exactly one argument to XML::Writer.serialize
#     a bare string                  The XML tree must have a single root node
#     one root element               "<a>1</a>"
