#!/usr/bin/env rakupp
# Dictionary::Create — The accumulator
# https://raku.online/modules/dictionary-create/#the-accumulator
#
# Install what it needs, then run it:
#     rakupp install Dictionary::Create
#     rakupp 03-accumulator.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Dictionary::Create;

my $a = Dictionary::Create::DSL::Article.new;
say 'give() on a fresh article : ', $a.give.raku, '   <- the Str TYPE OBJECT';
say '  .defined                : ', $a.give.defined;
say '';
$a.append('hello');
say 'append before set-title   : ', $a.give.raku;
say '  (append unconditionally prefixes a space; append-line prefixes';
say '   "\n\t". There is no way to append without whitespace.)';
say '';
$a.set-title('one');
$a.append('body');
$a.set-title('two');
say 'set-title REPLACES the whole body : ', $a.give.raku;
say '';
say 'so call set-title first, once.';
say '';
say 'set-title accepts Str or Int and nothing else:';
for 42, 1.5 -> $t {
    my $b = Dictionary::Create::DSL::Article.new;
    my $r = try $b.set-title($t);
    say sprintf('  set-title(%-6s) -> %s', $t.raku, $! ?? 'refused' !! $b.give.raku);
}

# Output:
#     give() on a fresh article : Str   <- the Str TYPE OBJECT
#       .defined                : False
#     
#     append before set-title   : " hello"
#       (append unconditionally prefixes a space; append-line prefixes
#        "\n\t". There is no way to append without whitespace.)
#     
#     set-title REPLACES the whole body : "two"
#     
#     so call set-title first, once.
#     
#     set-title accepts Str or Int and nothing else:
#       set-title(42    ) -> "42"
#       set-title(1.5   ) -> refused
