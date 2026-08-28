#!/usr/bin/env rakupp
# App::Rakus — A real request, in-process
# https://raku.online/modules/app-rakus/#a-real-request-in-process
#
# Install what it needs, then run it:
#     rakupp install App::Rakus
#     rakupp 06-live.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     HTTP/1.1 200 OK
#     Content-Type: text/plain; charset=utf-8
#     hello over HTTP
