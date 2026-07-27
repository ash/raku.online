---
title: Classes
chapter: Objects
summary: Define classes with has and method; construct with named arguments; accessors come free.
---

A class declares attributes with `has` and behaviour with `method`. The
default constructor takes named arguments, and `$.x` gives you a read
accessor for free:

```raku
class Point {
    has $.x;
    has $.y;

    method distance-from-origin() {
        sqrt($!x ** 2 + $!y ** 2)
    }
}

my $p = Point.new(x => 3, y => 4);
say $p.x;
say $p.distance-from-origin;
```
```output
3
5
```

Inside a method, `$!x` is the attribute itself; outside, `$p.x` goes through
the accessor.

## Read-only by default

Attributes can't be assigned from outside unless you say `is rw`:

```raku
class Counter {
    has $.count is rw = 0;

    method bump() { $!count++ }
}

my $c = Counter.new;
$c.bump for ^3;
$c.count += 10;
say $c.count;
```
```output
13
```

The `= 0` is a default value, so `Counter.new` needs no arguments at all.

## Methods calling methods

`self` is the current object:

```raku
class Rectangle {
    has $.width;
    has $.height;

    method area() { $!width * $!height }
    method describe() { "a { self.area }-square-unit rectangle" }
}

say Rectangle.new(width => 3, height => 5).describe;
```
```output
a 15-square-unit rectangle
```

## Try it

Give `Circle` an `area` method (π is spelled `pi`; rounding to 2 decimals is
`.round(0.01)`).

```raku exercise
class Circle {
    has $.radius;
}

say Circle.new(radius => 2).area;
```

```solution
class Circle {
    has $.radius;

    method area() { (pi * $!radius ** 2).round(0.01) }
}

say Circle.new(radius => 2).area;
```
```output
12.57
```
