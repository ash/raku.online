#!/usr/bin/env rakupp
# Pod::Tangle — The one thing to know
# https://raku.online/modules/pod-tangle/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Pod::Tangle
#     rakupp 02-abbreviated.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Pod::Tangle;

my $f = $*TMPDIR.add("tangle2-{$*PID}.raku");
LEAVE $f.unlink;
$f.spurt("=head1 NAME\n\nmy \$x = 1;\nsay \$x;\n");

my $code = tangle($f);
say 'a file whose only Pod is `=head1 NAME`:';
say '  the code survived   : ', $code.contains('say');
say '  anything useful     : ', ($code.contains('say') ?? 'yes' !! 'no');
say '';
say 'Pod::Literate`s grammar only knows "=begin" … "=end", and its';
say '`token code` is [^^ <![=]> \N* \n]+ — so a line starting with "=" that';
say 'is not a =begin block can be matched by neither alternative.';
say '';
say '.parse needs a full match, so parsefile returns Nil, and Pod::Tangle';
say 'then does Nil.caps.map({ when … }) with NO default. On Raku++ that';
say 'yields nothing and you get ""; on Rakudo it yields one element which';
say 'falls out of the when chain, and you get the five-character string';
say '"False".';
say '';
say 'neither throws. And =head1 NAME is the most common Pod idiom in';
say 'Raku — so the failure you will actually hit produces an empty file';
say 'with exit status 0.';

# Output:
#     a file whose only Pod is `=head1 NAME`:
#       the code survived   : False
#       anything useful     : no
#     
#     Pod::Literate`s grammar only knows "=begin" … "=end", and its
#     `token code` is [^^ <![=]> \N* \n]+ — so a line starting with "=" that
#     is not a =begin block can be matched by neither alternative.
#     
#     .parse needs a full match, so parsefile returns Nil, and Pod::Tangle
#     then does Nil.caps.map({ when … }) with NO default. On Raku++ that
#     yields nothing and you get ""; on Rakudo it yields one element which
#     falls out of the when chain, and you get the five-character string
#     "False".
#     
#     neither throws. And =head1 NAME is the most common Pod idiom in
#     Raku — so the failure you will actually hit produces an empty file
#     with exit status 0.
