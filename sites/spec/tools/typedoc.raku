#!/usr/bin/env raku
# typedoc.raku — extract the Raku type & routine reference from the official
# documentation source, so the Types section of the Rules site reflects the
# real signatures rather than a retelling of them.
#
#   rakupp tools/typedoc.raku --doc=/Users/ash/doc
#
# What each doc file gives us, and why it matters here:
#
#   =begin pod :kind("Type") :subkind("class") :category("basic")
#       the type's classification — becomes the section it is filed under
#   =TITLE class Int / =SUBTITLE Integer (arbitrary-precision)
#       name and one-line purpose
#   the declaration line, `class Int is Cool does Real { }`
#       parents and roles — the class hierarchy, straight from the source
#   =head2 routine chars   followed by an indented block
#       every signature the routine has, including `--> Int:D` return types
#   the first prose paragraph after those signatures
#       what the routine is expected to DO
#   indented code carrying `# OUTPUT: «…␤»`
#       a runnable example with its expected output already stated
#
# That last one is the reason this tool exists: 5000-odd examples whose correct
# output the documentation already asserts. Running them on both interpreters
# turns the whole standard library into a differential conformance surface.
#
# Output: src/data/typedoc.raku

# Takes Any, not Str: the documentation is inconsistent enough that some field
# is always missing somewhere, and a typed parameter turns that into a crash
# deep in the writer rather than an empty string in one cell.
sub rk-str($v --> Str) {
    my $s = $v.defined ?? ~$v !! '';
    "'" ~ $s.subst('\\', '\\\\', :g).subst("'", "\\'", :g) ~ "'"
}

# `# OUTPUT: «True␤»` — the documented result of the line it annotates. ␤ stands
# for a newline; the fragments of one code block concatenate into its full
# expected stdout. Text after the closing » (an aside like "NOTE: …") is dropped.
sub output-fragment(Str $line) {
    my $at = $line.index('# OUTPUT:');
    return Str unless $at.defined;
    my $rest = $line.substr($at);
    my $open = $rest.index('«');
    return Str unless $open.defined;
    my $close = $rest.rindex('»');
    return Str unless $close.defined && $close > $open;
    $rest.substr($open + 1, $close - $open - 1).subst('␤', "\n", :g)
}

# The declaration line of a type page: `class Int is Cool does Real { }`.
# Returns one hash, not two lists: `return @a, @b` flattens into a single list
# in rakupp, so a two-value return would silently lose the split.
sub parse-decl(Str $line) {
    my @isa;
    my @does;
    my @w = $line.words;
    loop (my $i = 0; $i < @w.elems; $i++) {
        if @w[$i] eq 'is' && $i + 1 < @w.elems {
            my $t = @w[$i + 1].subst(/ <[{}]> /, '', :g);
            @isa.push($t) if $t.chars && $t ne 'export';
        }
        if @w[$i] eq 'does' && $i + 1 < @w.elems {
            my $t = @w[$i + 1].subst(/ <[{}]> /, '', :g);
            @does.push($t) if $t.chars;
        }
    }
    %( isa => @isa, does => @does )
}

# A signature line looks like `multi method chars(Str:D: --> Int:D)`. The return
# type is whatever follows `-->` before the closing paren.
sub return-of(Str $sig) {
    my $at = $sig.index('-->');
    return Str unless $at.defined;
    my $rest = $sig.substr($at + 3);
    my $close = $rest.rindex(')');
    ($close.defined ?? $rest.substr(0, $close) !! $rest).trim
}

sub sig-like(Str $l --> Bool) {
    my $t = $l.trim;
    return False unless $t.chars;
    so $t.starts-with('multi ') || $t.starts-with('method ') || $t.starts-with('sub ')
       || $t.starts-with('proto ') || $t.starts-with('routine ') || $t.starts-with('submethod ')
       || $t.starts-with('only ')
}

my @ROUTINE-KINDS = <method routine sub multi infix prefix postfix circumfix
                     postcircumfix trait term attribute submethod>;

sub parse-type(Str $path) {
    my @lines = slurp($path).lines;
    my %t = file => $path.IO.basename.subst(/ '.rakudoc' $ /, '');
    my @routines;
    my @examples;

    my %cur;                  # the routine currently being described
    my @curex;                # code lines of the block being collected
    my @curout;               # its documented output fragments
    my $in-code = False;      # inside an explicit =begin code
    my $for-code = False;     # inside a `=for code` paragraph (ends at a blank line)
    my $code-opts = '';
    my $seen-sig = False;     # have we taken this routine's signature block yet
    my $want-summary = False;

    sub flush-example() {
        if @curex.grep({ .trim.chars }) {
            my $code = @curex.join("\n").trim-trailing;
            my $exp  = @curout.join('');
            # `:preamble<my $str = "…">` is setup the example needs but the page
            # does not show; without it the snippet cannot run standalone.
            my $pre = '';
            if $code-opts ~~ / ':preamble<' (<-[>]>*) '>' / { $pre = ~$0 }
            @examples.push: %(
                code => $code,
                expect => $exp,
                routine => (%cur ?? %cur<name> !! ''),
                opts => $code-opts,
                preamble => $pre,
            ) if $code.chars;
        }
        @curex = ();
        @curout = ();
        $code-opts = '';
    }

    sub flush-routine() {
        if %cur {
            # .clone, not %cur: pushing the variable stores the container itself,
            # and the `%cur = %()` on the next line would then empty the record
            # that was just pushed.
            @routines.push: %cur.clone;
            %cur = %();
        }
    }

    for @lines -> $line {
        # ---- pod directives ------------------------------------------------
        if $line.starts-with('=begin pod') {
            for <kind subkind category> -> $k {
                if $line ~~ / $k '("' (<-[\x22]>*) '")' / { %t{$k} = ~$0 }
            }
            next;
        }
        if $line.starts-with('=TITLE') {
            my $rest = $line.substr(6).trim;
            my @w = $rest.words;
            %t<declkind> = @w[0] if @w.elems > 1;
            %t<name> = @w.elems > 1 ?? @w[1 .. *].join(' ') !! $rest;
            next;
        }
        if $line.starts-with('=SUBTITLE') { %t<subtitle> = $line.substr(9).trim; next }

        # `=for code` introduces ONE paragraph of code, unindented, running to
        # the next blank line. 500-odd of them in doc/Type, many carrying the
        # `:preamble<…>` an example needs to run at all.
        if $line.starts-with('=for code') {
            flush-example();
            $for-code = True;
            $code-opts = $line.substr(9).trim;
            next;
        }
        if $line.starts-with('=begin code') {
            flush-example();
            $in-code = True;
            $code-opts = $line.substr(11).trim;
            next;
        }
        if $line.starts-with('=end code') {
            $in-code = False;
            flush-example();
            next;
        }
        if $line.starts-with('=head') {
            flush-example();
            my $level = $line.substr(5, 1);
            my $text = $line.substr(6).trim;
            if $level eq '2' {
                flush-routine();
                my @w = $text.words;
                if @w.elems >= 2 && @ROUTINE-KINDS.first({ $_ eq @w[0] }).defined {
                    %cur = name => @w[1].subst(/ ^ 'X<' /, '').subst(/ '|' .* $ /, ''),
                           kind => @w[0], sigs => [], returns => [], summary => '';
                    $seen-sig = False;
                    $want-summary = True;
                }
            }
            next;
        }
        next if $line.starts-with('=');

        # ---- indented blocks: signatures, then examples ---------------------
        # A `=for code` paragraph ends at the first blank line. This has to be
        # checked BEFORE the code-capture branch below, which would otherwise
        # swallow the blank line, never reach the blank-line handler, and leave
        # the flag set — turning every following paragraph of prose into code.
        if $for-code && !$line.trim.chars {
            $for-code = False;
            flush-example();
            next;
        }

        my $indented = $line.starts-with('    ') || $line.starts-with("\t");
        if $in-code || $for-code || ($indented && $line.trim.chars) {
            my $body = $line.trim;
            # The first indented block under a routine heading is its signature.
            if %cur && !$seen-sig && !$in-code && sig-like($line) {
                %cur<sigs>.push($body);
                my $r = return-of($body);
                %cur<returns>.push($r) if $r.defined && $r.chars;
                next;
            }
            @curex.push($line.subst(/ ^ '    ' /, ''));
            my $frag = output-fragment($line);
            @curout.push($frag) if $frag.defined;
            next;
        }

        # ---- blank line or prose -------------------------------------------
        if !$line.trim.chars {
            # a blank line ends a signature block, a `=for code` paragraph, and
            # an example — but not a `=begin code` block, which runs to =end code
            $seen-sig = True if %cur && %cur<sigs>.elems;
            $for-code = False;
            flush-example() unless $in-code;
            next;
        }

        # prose: the first paragraph after the signatures is the summary
        if %cur && $want-summary {
            %cur<summary> = %cur<summary>.chars
                ?? %cur<summary> ~ ' ' ~ $line.trim
                !! $line.trim;
            $want-summary = False if %cur<summary>.chars > 400;
        }
        # the declaration line may also appear as prose-adjacent `=for code`
        if !(%t<decl>:exists) && ($line.trim.starts-with('class ') ||
                                  $line.trim.starts-with('role ') ||
                                  $line.trim.starts-with('enum ')) {
            %t<decl> = $line.trim;
        }
    }
    flush-example();
    flush-routine();

    if %t<decl>:exists {
        my %d = parse-decl(%t<decl>);
        %t<isa>  = @(%d<isa>);
        %t<does> = @(%d<does>);
    }
    %t<routines> = @routines;
    %t<examples> = @examples;
    %t
}

# type-graph.txt: `class Telemetry::Period is Telemetry does Associative`.
# Used only for the reverse edges — which types inherit from this one — since a
# type's own page already states its parents.
sub parse-graph(Str $path) {
    my %children;
    my %consumers;
    return %( children => %children, consumers => %consumers ) unless $path.IO.e;
    for slurp($path).lines -> $line {
        next if $line.starts-with('#') || $line.starts-with('[');
        my @w = $line.words;
        next unless @w.elems >= 2 && (@w[0] eq 'class' || @w[0] eq 'role');
        my $name = @w[1];
        loop (my $i = 2; $i < @w.elems; $i++) {
            if @w[$i] eq 'is' && $i + 1 < @w.elems {
                %children{ @w[$i + 1] } //= [];
                %children{ @w[$i + 1] }.push($name);
            }
            if @w[$i] eq 'does' && $i + 1 < @w.elems {
                %consumers{ @w[$i + 1] } //= [];
                %consumers{ @w[$i + 1] }.push($name);
            }
        }
    }
    %( children => %children, consumers => %consumers )
}

sub MAIN(
    Str :$doc = '/Users/ash/doc',
    Str :$out = 'src/data/typedoc.raku',
) {
    my $tdir = "$doc/doc/Type";
    die "no doc/Type at $tdir" unless $tdir.IO.d;

    my @files;
    sub walk(Str $d) {
        for dir($d).sort -> $e {
            if $e.IO.d { walk($e.Str) }
            elsif $e.Str.ends-with('.rakudoc') { @files.push($e.Str) }
        }
    }
    walk($tdir);

    my %graph = parse-graph("$doc/type-graph.txt");
    my %children  = %(%graph<children>);
    my %consumers = %(%graph<consumers>);

    my @types;
    for @files -> $f {
        my %t = parse-type($f);
        next unless %t<name>:exists && %t<name>.chars;
        %t<children>  = @(%children{ %t<name> } // []);
        %t<consumers> = @(%consumers{ %t<name> } // []);
        @types.push(%t);
    }

    my @l;
    @l.push('# Generated by tools/typedoc.raku — do not edit.');
    @l.push("\{");
    @l.push("  'types' => [");
    for @types -> %t {
        @l.push('    {');
        for <name file subkind category subtitle decl declkind> -> $k {
            @l.push("      '$k' => " ~ rk-str(~%t{$k}) ~ ',') if %t{$k}:exists;
        }
        for <isa does children consumers> -> $k {
            my @v = @(%t{$k} // []);
            @l.push("      '$k' => [" ~ @v.map({ rk-str($_) }).join(', ') ~ '],') if @v;
        }
        @l.push("      'routines' => [");
        for @(%t<routines>) -> %r {
            @l.push('        { ' ~
                "'name' => " ~ rk-str(%r<name>) ~ ', ' ~
                "'kind' => " ~ rk-str(%r<kind>) ~ ', ' ~
                "'summary' => " ~ rk-str(%r<summary>) ~ ', ' ~
                "'sigs' => [" ~ @(%r<sigs>).map({ rk-str($_) }).join(', ') ~ '], ' ~
                "'returns' => [" ~ @(%r<returns>).map({ rk-str($_) }).join(', ') ~ '] },');
        }
        @l.push('      ],');
        @l.push("      'examples' => [");
        for @(%t<examples>) -> %e {
            @l.push('        { ' ~
                "'code' => " ~ rk-str(%e<code>) ~ ', ' ~
                "'expect' => " ~ rk-str(%e<expect>) ~ ', ' ~
                "'routine' => " ~ rk-str(%e<routine>) ~ ', ' ~
                "'opts' => " ~ rk-str(%e<opts>) ~ ', ' ~
                "'preamble' => " ~ rk-str(%e<preamble>) ~ ' },');
        }
        @l.push('      ],');
        @l.push('    },');
    }
    @l.push('  ],');
    @l.push('}');
    spurt $out, @l.join("\n") ~ "\n";

    my $routines = @types.map({ @(.<routines>).elems }).sum;
    my $examples = @types.map({ @(.<examples>).elems }).sum;
    my $withexp  = @types.map({ @(.<examples>).grep({ .<expect>.chars }).elems }).sum;
    say "types      : {@types.elems}";
    say "routines   : $routines";
    say "examples   : $examples  ($withexp with documented output)";
    say "wrote $out";
}
