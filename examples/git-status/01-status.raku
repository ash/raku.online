#!/usr/bin/env rakupp
# Git::Status — Reading a repository
# https://raku.online/modules/git-status/#reading-a-repository
#
# Install what it needs, then run it:
#     rakupp install Git::Status
#     rakupp 01-status.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Git::Status;

my $repo = $*TMPDIR.add("gs-{$*PID}");
$repo.mkdir;
LEAVE { run 'rm', '-rf', $repo.Str }

run 'git', 'init', '-q', $repo.Str, :out, :err;
run 'git', '-C', $repo.Str, 'config', 'user.email', 'f@example.invalid';
run 'git', '-C', $repo.Str, 'config', 'user.name',  'Fixture';
$repo.add('tracked.txt').spurt("one\n");
$repo.add('todelete.txt').spurt("two\n");
run 'git', '-C', $repo.Str, 'add', '.', :out, :err;
run 'git', '-C', $repo.Str, 'commit', '-qm', 'first', :out, :err;

say 'a clean tree:';
my $clean = Git::Status.new(directory => $repo.Str);
say '  is-clean : ', $clean.is-clean;
say '  gist     : ', $clean.gist.raku;

$repo.add('tracked.txt').spurt("one\nchanged\n");
$repo.add('untracked.txt').spurt("three\n");
run 'git', '-C', $repo.Str, 'rm', '-q', 'todelete.txt', :out, :err;

say '';
say 'after changing, adding and removing a file:';
my $st = Git::Status.new(directory => $repo.Str);
say '  is-clean  : ', $st.is-clean;
say '  modified  : ', $st.modified.sort.join(' ');
say '  deleted   : ', $st.deleted.sort.join(' ');
say '  untracked : ', $st.untracked.sort.join(' ');

# Output:
#     a clean tree:
#       is-clean : True
#       gist     : ""
#     
#     after changing, adding and removing a file:
#       is-clean  : False
#       modified  : tracked.txt
#       deleted   : todelete.txt
#       untracked : untracked.txt
