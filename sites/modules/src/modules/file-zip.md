---
name: File::Zip
version: 0.1.2
auth: gitlab:tyil
kind: Distribution · archives
summary: Read a zip archive by shelling out to the system unzip — validate the
  path, list the members, extract to a directory.
status: full
suite: 1 file, green
tested: 2026-09-15
license: AGPL-3.0
depends: File::Temp, File::Which
raku-land: https://raku.land/gitlab:tyil/File::Zip
source: git@gitlab.com:tyil/perl6-file-zip.git
---

## What it is for

Reading a zip file from Raku without a bundled decompressor means running
`unzip`, and running `unzip` means parsing its output. This distribution wraps
both: the constructor validates that the path is a real file that `file(1)`
calls a zip archive, `files` turns the columns of `unzip -l` into a hash, and
`extract` runs `unzip -d`.

It reads archives. There is no method that writes one.

## Opening and listing

```raku name="list"
use File::Zip;

my $root = $*TMPDIR.add("zip-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('src/nested');
$root.add('src/alpha.txt').spurt("alpha\n");
$root.add('src/beta.txt').spurt("beta beta\n");
$root.add('src/nested/gamma.txt').spurt("gamma gamma gamma\n");
# pin the timestamps so the listing is the same everywhere
run 'touch', '-t', '202401021530',
    $root.add('src/alpha.txt').Str, $root.add('src/beta.txt').Str,
    $root.add('src/nested/gamma.txt').Str, $root.add('src/nested').Str,
    $root.add('src').Str;
run 'zip', '-q', '-r', '-X', $root.add('bundle.zip').Str, 'src', :cwd($root.Str);

my $zip = File::Zip.new($root.add('bundle.zip'));
say 'object : ', $zip.^name;
say 'path   : ', $zip.path.basename, '  (a ', $zip.path.^name, ')';
say '';
my %f = $zip.files;
say 'members : ', %f.keys.elems;
for %f.keys.sort -> $k {
    say sprintf('  %-22s %d bytes  %s %s', $k, %f{$k}<length>, %f{$k}<date>, %f{$k}<time>);
}
```

```output
object : File::Zip
path   : bundle.zip  (a IO::Path)

members : 5
  src/                   0 bytes  01-02-2024 15:30
  src/alpha.txt          6 bytes  01-02-2024 15:30
  src/beta.txt           10 bytes  01-02-2024 15:30
  src/nested/            0 bytes  01-02-2024 15:30
  src/nested/gamma.txt   18 bytes  01-02-2024 15:30
```

## Extracting

```raku name="extract"
use File::Zip;

my $root = $*TMPDIR.add("zip2-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('src');
$root.add('src/one.txt').spurt("one\n");
run 'zip', '-q', '-r', '-X', $root.add('bundle.zip').Str, 'src', :cwd($root.Str);

mkdir $root.add('out');
my $zip = File::Zip.new($root.add('bundle.zip'));
say 'extract to a directory : ', $zip.extract($root.add('out'));
say '';
sub walk($d) { $d.dir.sort(*.basename).map({ .d ?? ($_, |walk($_)) !! $_ }).flat }
say 'what landed there:';
say '  ', .Str.subst($root.add('out').Str ~ '/', '') for walk($root.add('out'));
```

```output
extract to a directory : True

what landed there:
  src
  src/one.txt
```

`extract` with **no** argument writes into `$*CWD`, which nothing in the name
suggests. Always pass a destination.

## What the constructor refuses

```raku name="refuses"
use File::Zip;

my $root = $*TMPDIR.add("zip3-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }
$root.mkdir;
$root.add('adir').mkdir;
$root.add('notazip.txt').spurt("I am plain text\n");

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-26s %s', $label, $! ?? 'refused' !! 'accepted');
}

attempt 'a missing path',   { File::Zip.new($root.add('nope.zip')) };
attempt 'a directory',      { File::Zip.new($root.add('adir')) };
attempt 'a plain text file',{ File::Zip.new($root.add('notazip.txt')) };
```

```output
a missing path             refused
a directory                refused
a plain text file          refused
```

The constructor also refuses to build unless **both** `zip` and `unzip` are on
your `PATH`, though only `unzip` is ever run.

## The one thing to know

`extract` blocks forever on an archive whose files are already at the
destination.

`unzip` is run without `-o` and with stdin inherited, so it asks the user to
confirm each replacement and waits. In a service, a cron job or a test that
extracts the same archive twice, the process wedges — and the prompt text goes
to the terminal, where nothing the caller controls can see it.

With stdin redirected from `/dev/null` it does not hang; it answers "none" to
its own question and silently extracts nothing, returning `False`. So the
behaviour depends on what stdin happens to be, and neither outcome is the one
you wanted.

Extract to a fresh directory every time, or remove the destination first.

## Where the two engines differ

Nowhere in this module's own behaviour — the listing, the extraction, the
three rejections and the hang were identical on Raku++ and Rakudo.

One difference in the scaffolding around it: when a `run` of `zip` fails,
Rakudo throws `The spawned command 'zip' exited unsuccessfully` where Raku++
merely prints the error. Worth knowing if you script around this module rather
than only using it.

The thing to guard on both engines is the listing. `files` parses `unzip -l`
with `.words`, so **any archived name containing a space is truncated at the
first space** — and the truncated key also carries the wrong `length`, because
the columns have shifted. Names with spaces are common in real archives.

`files(:!cache)` reads fresh but does **not** refresh the cache, so the very
next `files()` returns the stale list again.
