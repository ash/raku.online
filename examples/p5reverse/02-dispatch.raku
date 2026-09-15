#!/usr/bin/env rakupp
# P5reverse — The one thing to know
# https://raku.online/modules/p5reverse/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5reverse
#     rakupp 02-dispatch.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5reverse;

say 'Perl:   my $s = reverse "hello";     # scalar context: "olleh"';
say '        my @l = reverse "hello";     # list context:   ("hello")';
say '';
say 'here the argument decides:';
say '  reverse("hello")        = ', reverse('hello').raku;
say '  reverse(("hello",))     = ', reverse(('hello',)).raku;
say '';
say 'so a ported line that fed a LIST to reverse and used the result as a';
say 'string now gets a reversed list, and one that fed a single string and';
say 'wanted a one-element list gets a reversed string.';
say '';
say 'a number goes through the Str(Any) coercion:';
say '  reverse(1234)           = ', reverse(1234).raku;
say '';
say 'and the join-then-reverse idiom is explicit:';
my @words = <alpha beta gamma>;
say '  reverse(@words.join)    = ', reverse(@words.join).raku;
say '  reverse(@words.List)    = ', reverse(@words.List).raku;

# Output:
#     Perl:   my $s = reverse "hello";     # scalar context: "olleh"
#             my @l = reverse "hello";     # list context:   ("hello")
#     
#     here the argument decides:
#       reverse("hello")        = "olleh"
#       reverse(("hello",))     = ("hello",)
#     
#     so a ported line that fed a LIST to reverse and used the result as a
#     string now gets a reversed list, and one that fed a single string and
#     wanted a one-element list gets a reversed string.
#     
#     a number goes through the Str(Any) coercion:
#       reverse(1234)           = "4321"
#     
#     and the join-then-reverse idiom is explicit:
#       reverse(@words.join)    = "ammagatebahpla"
#       reverse(@words.List)    = ("gamma", "beta", "alpha")
