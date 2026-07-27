---
title: Roles
chapter: Objects
summary: Package behaviour in roles and compose it into classes with does.
---

A *role* is a bundle of methods a class can compose in with `does` — Raku's
answer to "I want to share behaviour without inheritance":

```raku
role Greeter {
    method greet() { "Hi, I am { self.name }." }
}

class Robot does Greeter {
    has $.name;
}

class Human does Greeter {
    has $.name;
}

say Robot.new(name => 'R2-D2').greet;
say Human.new(name => 'Ada').greet;
```
```output
Hi, I am R2-D2.
Hi, I am Ada.
```

The role calls `self.name` and trusts whatever class it lands in to provide
it.

## Composing several roles

A class can do any number of roles, and roles can carry attributes too:

```raku
role CanFly {
    method fly() { "{ self.name } takes off!" }
}
role CanSwim {
    method swim() { "{ self.name } dives in!" }
}

class Duck does CanFly does CanSwim {
    has $.name;
}

my $d = Duck.new(name => 'Donald');
say $d.fly;
say $d.swim;
```
```output
Donald takes off!
Donald dives in!
```

## Checking for a role

The `.does` method asks any object whether it plays a role:

```raku
role Loud { }
class Drum does Loud { }
class Flute { }

say Drum.new.does(Loud);
say Flute.new.does(Loud);
```
```output
True
False
```

## Try it

Add a `Shouter` role with a `shout` method that returns the object's name
uppercased, with a `!` at the end.

```raku exercise
role Shouter {
}

class Coach does Shouter {
    has $.name;
}
say Coach.new(name => 'Bob').shout;
```

```solution
role Shouter {
    method shout() { self.name.uc ~ '!' }
}

class Coach does Shouter {
    has $.name;
}
say Coach.new(name => 'Bob').shout;
```
```output
BOB!
```
