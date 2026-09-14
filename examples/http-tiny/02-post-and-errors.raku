#!/usr/bin/env rakupp
# HTTP::Tiny — A request, and what comes back
# https://raku.online/modules/http-tiny/#a-request-and-what-comes-back
#
# Install what it needs, then run it:
#     rakupp install HTTP::Tiny
#     rakupp 02-post-and-errors.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

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

# Output:
#     200 POST application/x-www-form-urlencoded user=ada
#     404 Not Found success=False no such page
#     X::HTTP::Tiny
