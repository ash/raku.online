---
name: App::Rakus
version: 0.0.1
auth: zef:ash
kind: Distribution · command line
summary: A static HTTP file server as one installable command, on nothing but
  IO::Socket::INET — with the routing exposed as a pure function you can test
  without opening a port.
status: full
license: Artistic-2.0
suite: 3 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:ash/App::Rakus
source: https://github.com/ash/raku-modules
---

## What it is for

A directory that needs to answer HTTP. The site you just built and want to
click through before publishing, a WebAssembly bundle that will not load off
`file://`, a folder of PDFs to hand to the laptop across the room. The job
`python3 -m http.server` does — as one installed command, written in Raku, on
nothing but the `IO::Socket::INET` that ships with the language:

```sh
$ rakus                      # serve . on http://127.0.0.1:8080/
$ rakus 9000                 # choose the port
$ rakus 9000 ~/site          # choose the port and the directory
$ rakus --quiet 9000 ~/site  # without the request log
```

Installing the distribution puts `rakus` on `PATH` — a script in `bin/` is
discovered and wrapped by the installer on its own, nothing to declare. What
it serves: files with the `Content-Type` their extension implies, read and
written as **bytes**, so images and WebAssembly arrive intact and
`Content-Length` is always the true byte count; `index.html` when a directory
has one, a generated listing when it does not; `GET` and `HEAD`, and nothing
else. No TLS, no compression, no caching headers, no keep-alive — it is a
development and local-network server, in the same spirit as the Python
one-liner, and it says so rather than implying otherwise.

## The routing is a pure function

The part of a file server that has opinions — which path answers what — is
`handle`, and it is a pure function from (method, target, root) to the whole
response. It touches no socket, so what the server would answer is something
you can simply compute, in a program that never opens a port:

```raku name="tour"
use App::Rakus;

my $site = $*TMPDIR.add("rakus-page-$*PID");
mkdir $site;
$site.add('index.html').spurt("<h1>served</h1>\n");

my ($status, $type, $body, $) = handle('GET', '/', $site.Str);
say $status;
say $type;
print $body.decode;

$site.add('index.html').unlink;
rmdir $site;
```

```output
200
text/html; charset=utf-8
<h1>served</h1>
```

`handle` returns four things: the status, the `Content-Type`, the body as a
`Buf`, and one extra header or `Nil`. A `HEAD` gets the same answer as a
`GET`, body included — the caller drops the bytes but keeps the
`Content-Length`, which is what `HEAD` means. This function is where 18 of the
suite's 37 assertions live: ordinary calls, no port, no race, no cleanup.

## Every refusal, by status

```raku name="routing"
use App::Rakus;

my $root = $*TMPDIR.add("rakus-routes-$*PID");
mkdir $root;
mkdir $root.add('docs');

for ['POST', '/'], ['GET', '/../secret'], ['GET', '/docs'], ['GET', '/missing.png'] -> ($method, $target) {
    my ($status, $, $, $extra) = handle($method, $target, $root.Str);
    say "$status $method $target" ~ ($extra ?? "  {$extra.key}: {$extra.value}" !! '');
}

rmdir $root.add('docs');
rmdir $root;
```

```output
405 POST /
403 GET /../secret
301 GET /docs  Location: /docs/
404 GET /missing.png
```

Three of those lines carry the correctness of a static server. A `..` segment
is **refused rather than resolved** — a served root is a boundary, and the
cheapest way to keep it one is never to leave it. A directory URL without its
trailing slash gets a `301` to the slashed form, because until it has one,
every relative link inside the page resolves one level too high. And a method
the server does not implement is a `405`, not a surprise.

## `Content-Type` by extension — or honestly not

```raku name="mime"
use App::Rakus;

say mime-for($_) for <page.html app.wasm chart.svg data.json notes.md movie.mkv>;
```

```output
text/html; charset=utf-8
application/wasm
image/svg+xml
application/json; charset=utf-8
text/markdown; charset=utf-8
application/octet-stream
```

An extension it does not recognise is served as `application/octet-stream`
rather than guessed at. The entry worth noticing is `application/wasm`:
browsers stream-compile WebAssembly only when the server says exactly that,
and with anything else the engine behind this site falls back to a slower
non-streaming compile. A development server that gets the header right by
default is much of the point of having one.

## What a directory answers

`index.html` wins when it is present — that is the first example on this
page. Without one the directory answers a generated listing:

```raku name="listing"
use App::Rakus;

my $root = $*TMPDIR.add("rakus-list-$*PID");
mkdir $root;
$root.add('README.md').spurt('x' x 2048);
$root.add('.env').spurt('SECRET=1');
mkdir $root.add('assets');

my ($status, $type, $body, $) = handle('GET', '/', $root.Str);
my $page = $body.decode;
say $page.contains('README.md');
say $page.contains('2.0 KB');
say $page.contains('assets/');
say $page.contains('.env');

.unlink for $root.add('README.md'), $root.add('.env');
rmdir $root.add('assets');
rmdir $root;
```

```output
True
True
True
False
```

Directories first, sizes humanised, and that last `False` is a decision:
dotfiles stay out of the listing. What the machine across the room can browse
is what you meant to publish, not your `.env`.

## The response head is data too

```raku name="response-head"
use App::Rakus;

my $head = head-for(301, 'text/html; charset=utf-8', 0, ('Location' => '/docs/'));
.say for $head.lines;
```

```output
HTTP/1.1 301 Moved Permanently
Content-Type: text/html; charset=utf-8
Content-Length: 0
Location: /docs/
Server: rakus
Connection: close
```

`head-for` builds the status line and headers from the four values `handle`
returns, so the wire format is one function deep and testable like everything
else. Every response says `Connection: close` — one request per connection is
part of the deliberately small scope.

## A real request, in-process

The pure function settles what is answered; what is left to prove is that the
bytes survive TCP. This is the whole server and a raw client in one program —
and its shape is worth copying, because two lines of it are rules:

```raku name="live"
use App::Rakus;

my $root = $*TMPDIR.add("rakus-live-$*PID");
mkdir $root;
$root.add('hello.txt').spurt("hello over HTTP\n");

my ($listener, $port);
for 31_700 .. 31_800 -> $candidate {
    $listener = try listen-on($candidate, '127.0.0.1');
    if $listener { $port = $candidate; last }
}
Thread.start({ accept-loop($listener, $root.Str, :!log) }, :app_lifetime);

my $c = IO::Socket::INET.new(:host<127.0.0.1>, :$port);
$c.print("GET /hello.txt HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n");
my $reply = Buf.new;
loop {
    my $chunk = $c.recv(2048, :bin);
    last unless $chunk.defined && $chunk.bytes;
    $reply.append($chunk);
}
$c.close;

my $text = $reply.decode;
say $text.lines.head;
say $text.lines.grep(*.starts-with('Content-Type')).head;
print $text.split("\r\n\r\n")[1];

$root.add('hello.txt').unlink;
rmdir $root;
```

```output
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
hello over HTTP
```

The accept loop runs on `Thread.start(…, :app_lifetime)`, because a thread
blocked in `accept()` never returns on its own — without that flag the program
prints its three lines and then waits for ever for a connection nobody will
make. And the reply is read as **binary chunks** that stop on an empty one,
not as a string loop. Both rules exist for a reason the next section owes you.

## Where the two engines differ

Nothing the module answers: every example above prints the same bytes under
Raku++ and under Rakudo, twice on each, and the site build fails if that stops
being true. The differences sit in the *client and lifecycle code around* an
in-process server, and the live example is shaped by two of them — both
re-checked the day this page was built.

**`.recv` in string mode does not return at connection close under Rakudo.**
The natural loop — `while my $chunk = $c.recv { … }` — finishes under Raku++,
where `recv` answers an empty string once the server has closed, and blocks
for ever under Rakudo. Read with `$c.recv($n, :bin)` and stop on an empty
chunk, as the example does, and both engines finish.

**Closing a listener another thread is blocked accepting on wedges Rakudo.**
The tidy-up you want to write — `$listener.close` on the way out — returns at
once under Raku++ and puts Rakudo's main thread into a wait *inside the
close*. So the example never closes it: `:app_lifetime` lets the process end
with the accept thread still blocked, and process exit reclaims the socket. A
descriptor leaked for the last milliseconds of a program is the cheaper of the
two evils, which is also how the distribution's own server test is written.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install App::Rakus`, nothing to pull; the installer
   writes the `rakus` wrapper onto `PATH`.
3. **Test** — the distribution's own suite: 3 files, 37 assertions, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Nothing had to be fixed to put this page here — a first for this site, and
before that reads as praise it should read as disclosure: this distribution
and the engine share an author, and it was released only once its suite passed
on both engines. The road was not smooth; it was walked earlier. Writing the
module found four Raku++ bugs, all fixed before release: a synchronous socket
reported its type as `Socket`, so `sub accept-loop(IO::Socket::INET
$listener)` — the one signature a server naturally writes — rejected its own
listener; `$( … )` interpolated nothing inside a regex, so a test like
`/'Content-Length: ' $($body.bytes)/` silently matched nothing;
`IO::Handle.flush` did not exist; and the usage text a multi-candidate `MAIN`
generates differed from Rakudo's in five ways. That last fix is why
`rakus --help` now prints the same bytes under `rakupp` and under `raku` — a
comparison worth stealing for anything that ships a command.

It began as
[`showcase/rakus`](https://github.com/ash/rakupp/tree/main/showcase/rakus) in
the engine's repository — a demonstration that raw `IO::Socket::INET` is
enough for a real server — and that copy stays, runnable straight from a
checkout. This one exists to be installed.
