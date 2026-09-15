#!/usr/bin/env rakupp
# Cache::Async — Ages and validation
# https://raku.online/modules/cache-async/#ages-and-validation
#
# Install what it needs, then run it:
#     rakupp install Cache::Async
#     rakupp 03-ages.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Cache::Async;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-34s %s', $label, $! ?? $!.message !! 'accepted');
}

attempt 'max-age < refresh-after', {
    Cache::Async.new(producer => sub ($k) { $k },
        max-age => Duration.new(1), refresh-after => Duration.new(5))
};
attempt 'jitter with no age set', {
    Cache::Async.new(producer => sub ($k) { $k }, jitter => Duration.new(1))
};
attempt 'jitter >= max-age', {
    Cache::Async.new(producer => sub ($k) { $k },
        max-age => Duration.new(1), jitter => Duration.new(2))
};
attempt 'a consistent set', {
    Cache::Async.new(producer => sub ($k) { $k },
        max-age => Duration.new(10), refresh-after => Duration.new(5),
        jitter => Duration.new(1))
};

# Output:
#     max-age < refresh-after            max-age cannot be less than refresh-after
#     jitter with no age set             jitter set, but neither max-age nor refresh-after set
#     jitter >= max-age                  jitter cannot be larger or equals to refresh-after/max-age
#     a consistent set                   accepted
