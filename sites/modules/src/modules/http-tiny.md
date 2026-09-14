---
name: HTTP::Tiny
version: 0.2.6
auth: zef:jjatria
kind: Distribution · web
summary: An HTTP/1.1 client with no dependencies — one object, one method
  per verb, a hash back with the status, the headers and the body — for the
  program that has to fetch or post something and would rather not carry a
  framework to do it.
status: full
suite: 10 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:jjatria/HTTP::Tiny
source: https://gitlab.com/jjatria/http-tiny
---

## What it is for

Most programs that talk HTTP do one thing with it: fetch a JSON document,
post a form, check that a URL answers. Cro is a web framework; this is a
client and nothing else, modelled on the Perl module of the same name and
written against core Raku only, which is why twenty-six other distributions
reach for it when they need a request made. The object holds the defaults —
a user agent, a timeout, a cookie jar if you want one, keep-alive — and each
verb is a method.

The examples below start a **web server inside the program**, on a port the
operating system picks, so that they run identically on any machine and
touch no network. That server is ten lines of `IO::Socket::INET`; it is not
part of the module, and the request/response half of each example is.

## A request, and what comes back

```raku name="get"
use HTTP::Tiny;

# a one-request web server, so the example needs no network
my $listener = IO::Socket::INET.new(:listen, :localhost<127.0.0.1>, :localport(0));
my $server = start {
    my $conn = $listener.accept;
    my $request = '';
    while $conn.get -> $line { last if $line eq ''; $request ~= "$line\n" }
    my $body = 'you asked for ' ~ $request.lines[0].words[1];
    $conn.print("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n"
              ~ "Content-Length: {$body.chars}\r\nX-Served-By: example\r\n\r\n$body");
    $conn.close;
    $listener.close;
}

my $res = HTTP::Tiny.new.get("http://127.0.0.1:{$listener.localport}/towns?sort=name");
await $server;
say $res<status>, ' ', $res<reason>, ' success=', $res<success>;
say $res<headers><content-type>, ' | ', $res<headers><x-served-by>;
say $res<content>.decode;
say $res.keys.sort.join(' ');
```

```output
200 OK success=True
text/plain | example
you asked for /towns?sort=name
content headers protocol reason status success url
```

The response is a plain hash, and those seven keys are all of it. `status`
is an `Int`, `success` is the 2xx test already done for you, `headers` has
its names lowercased, and `content` is a `Blob` — bytes, not a string,
because the client does not know the encoding and will not guess. Decode it
yourself, as the example does.

A body goes in as `content`. Hand it a hash and it is sent as a form; hand
it a `Str` or a `Blob` and it is sent as it is, with whatever
`content-type` you put in `headers`:

```raku name="post-and-errors"
use HTTP::Tiny;

my $listener = IO::Socket::INET.new(:listen, :localhost<127.0.0.1>, :localport(0));
my $server = start {
    for ^2 {
        my $conn = $listener.accept;
        my $raw = '';
        $raw ~= $conn.recv until $raw.contains("\r\n\r\n");
        my ($head, $body) = $raw.split("\r\n\r\n", 2);
        my ($request-line, @header-lines) = $head.split("\r\n");
        my %h = @header-lines.map({ .split(': ', 2) }).map({ .[0].lc => .[1] });
        $body ~= $conn.recv while $body.chars < (%h<content-length> // 0);
        my ($status, $reply) = $request-line.starts-with('GET /missing')
            ?? ('404 Not Found', 'no such page')
            !! ('200 OK', "{$request-line.words[0]} {%h<content-type>} {$body}");
        $conn.print("HTTP/1.1 $status\r\nContent-Type: text/plain\r\nConnection: close\r\n"
                  ~ "Content-Length: {$reply.chars}\r\n\r\n$reply");
        $conn.close;
    }
    $listener.close;
}

my $base = "http://127.0.0.1:{$listener.localport}";
my $http = HTTP::Tiny.new(:!keep-alive);
my $res = $http.post("$base/login", content => { user => 'ada' });
say $res<status>, ' ', $res<content>.decode;
$res = $http.get("$base/missing");
say $res<status>, ' ', $res<reason>, ' success=', $res<success>, ' ', $res<content>.decode;
await $server;
say (try { HTTP::Tiny.new(:throw-exceptions).get('http://127.0.0.1:1/') }) // $!.^name;
```

```output
200 POST application/x-www-form-urlencoded user=ada
404 Not Found success=False no such page
X::HTTP::Tiny
```

## The one thing to know

A 404 is not an error. The request succeeded — the server answered — and
`success` is `False`, `status` is 404 and `content` holds whatever the
server said; nothing is thrown. Only a failure to *make* the request throws,
and only if you ask: with `:throw-exceptions` a refused connection is
`X::HTTP::Tiny` (the last line above), and without it the same event comes
back as a response with a **599** status and the message in `content`,
which is the Perl original's convention too. So a program that checks
`$res<success>` sees both cases, and a program that wraps the call in
`try` sees neither unless it turned exceptions on.

The other default to know is keep-alive: the object reuses its connection
for the next request to the same host, which is what you want against a
real server and a hang waiting to happen against one that closes after
each answer without saying so — the client writes the next request into a
socket the other side has already shut, and waits for a reply that never
comes. The second example turns it off with `HTTP::Tiny.new(:!keep-alive)`
and has its server say `Connection: close`; do one or the other whenever
the server is not a real one.
