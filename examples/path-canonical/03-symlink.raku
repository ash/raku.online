#!/usr/bin/env rakupp
# Path::Canonical — It is not `.resolve`
# https://raku.online/modules/path-canonical/#it-is-not-resolve
#
# Install what it needs, then run it:
#     rakupp install Path::Canonical
#     rakupp 03-symlink.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Canonical;

my $base = $*TMPDIR.add("canon-{$*PID}");
LEAVE { $base.add('sibling/target.txt').unlink; $base.add('sibling').rmdir;
        $base.add('real/deep').rmdir; $base.add('real').rmdir;
        $base.add('link').unlink; $base.rmdir }
$base.add('real/deep').mkdir;
$base.add('sibling').mkdir;
$base.add('sibling/target.txt').spurt('x');
run 'ln', '-s', $base.add('real/deep').Str, $base.add('link').Str;

my $input = $base.add('link/../sibling/target.txt').Str;
say 'input           : ', $input.subst($base.Str, '<FIX>');
say 'canon-path      : ', canon-path($input).subst($base.Str, '<FIX>');
say '  exists?       : ', canon-path($input).IO.e;
say 'core .resolve   : ', $input.IO.resolve.Str.subst($base.Str, '<FIX>');
say '  exists?       : ', $input.IO.resolve.e;
say '';
say 'the module collapses .. textually, so it names a file that exists —';
say 'and is NOT the file the kernel would open. Core .resolve follows the';
say 'symlink first and gives the other answer. Use .resolve when the';
say 'filesystem is what you mean.';
say '';
say 'and on a path that does not exist, .cleanup and .resolve leave the';
say '.. in place while this module removes it:';
say '  canon-path : ', canon-path('/no/such/dir/../file');
say '  .cleanup   : ', '/no/such/dir/../file'.IO.cleanup;

# Output:
#     input           : <FIX>/link/../sibling/target.txt
#     canon-path      : <FIX>/sibling/target.txt
#       exists?       : True
#     core .resolve   : /private<FIX>/real/sibling/target.txt
#       exists?       : False
#     
#     the module collapses .. textually, so it names a file that exists —
#     and is NOT the file the kernel would open. Core .resolve follows the
#     symlink first and gives the other answer. Use .resolve when the
#     filesystem is what you mean.
#     
#     and on a path that does not exist, .cleanup and .resolve leave the
#     .. in place while this module removes it:
#       canon-path : /no/such/file
#       .cleanup   : "/no/such/dir/../file".IO
