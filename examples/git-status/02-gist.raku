#!/usr/bin/env rakupp
# Git::Status — The gist
# https://raku.online/modules/git-status/#the-gist
#
# Install what it needs, then run it:
#     rakupp install Git::Status
#     rakupp 02-gist.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Git::Status;

my $repo = $*TMPDIR.add("gs2-{$*PID}");
$repo.mkdir;
LEAVE { run 'rm', '-rf', $repo.Str }

run 'git', 'init', '-q', $repo.Str, :out, :err;
run 'git', '-C', $repo.Str, 'config', 'user.email', 'f@example.invalid';
run 'git', '-C', $repo.Str, 'config', 'user.name',  'Fixture';
$repo.add('a.txt').spurt("x\n");
run 'git', '-C', $repo.Str, 'add', '.', :out, :err;
run 'git', '-C', $repo.Str, 'commit', '-qm', 'first', :out, :err;
$repo.add('a.txt').spurt("y\n");
$repo.add('b.txt').spurt("z\n");

say Git::Status.new(directory => $repo.Str).gist.subst($repo.Str, '<REPO>');

# Output:
#     Git::Status:
#       <REPO>
#     
#     Modified:
#       a.txt
#     
#     Untracked:
#       b.txt
