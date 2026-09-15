#!/usr/bin/env rakupp
# Dictionary::Create — The one thing to know
# https://raku.online/modules/dictionary-create/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Dictionary::Create
#     rakupp 04-font.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
for 'b', 'u', 'i', 'c', 'z', '' -> $tag {
    my $r = try $a.add-font-tag($tag, 'X');
    say sprintf('  add-font-tag(%-4s, "X") -> %s', $tag.raku,
                $! ?? 'threw ' ~ $!.^name !! $r.raku);
}
say '';
say 'the body is';
say '  my Str $left = not %params ?? "[$tag]" !! "[$tag " ~ … ~ "]";';
say 'and `not` binds LOOSER than ?? !!, so the whole ternary is negated';
say 'and a Bool is assigned to a Str.';
say '';
say 'there is a second precedence slip in the same method: the tag';
say 'validation reads  if ( ! $tag ~~ /^ [b||u||i||c] $/ )  which parses';
say 'as (!$tag) ~~ /…/ and is always falsy, so `die "Wrong tag was';
say 'given!"` is unreachable code.';
say '';
say 'one in five of the class`s methods is dead, and the validation it';
say 'advertises never runs. Build font tags yourself:';
sub font-tag(Str $tag, Str $text) { "[$tag]$text\[/$tag]" }
say '  font-tag("b", "X") = ', font-tag('b', 'X');

# Output:
#       add-font-tag("b" , "X") -> threw X::TypeCheck::Assignment
#       add-font-tag("u" , "X") -> threw X::TypeCheck::Assignment
#       add-font-tag("i" , "X") -> threw X::TypeCheck::Assignment
#       add-font-tag("c" , "X") -> threw X::TypeCheck::Assignment
#       add-font-tag("z" , "X") -> threw X::TypeCheck::Assignment
#       add-font-tag(""  , "X") -> threw X::TypeCheck::Assignment
#     
#     the body is
#       my Str $left = not %params ?? "[$tag]" !! "[$tag " ~ … ~ "]";
#     and `not` binds LOOSER than ?? !!, so the whole ternary is negated
#     and a Bool is assigned to a Str.
#     
#     there is a second precedence slip in the same method: the tag
#     validation reads  if ( ! $tag ~~ /^ [b||u||i||c] $/ )  which parses
#     as (!$tag) ~~ /…/ and is always falsy, so `die "Wrong tag was
#     given!"` is unreachable code.
#     
#     one in five of the class`s methods is dead, and the validation it
#     advertises never runs. Build font tags yourself:
#       font-tag("b", "X") = [b]X[/b]
