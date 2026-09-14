#!/usr/bin/env rakupp
# HTTP::Tiny — A request, and what comes back
# https://raku.online/modules/http-tiny/#a-request-and-what-comes-back
#
# Install what it needs, then run it:
#     rakupp install HTTP::Tiny
#     rakupp 01-get.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     200 OK success=True
#     text/plain | example
#     you asked for /towns?sort=name
#     content headers protocol reason status success url
