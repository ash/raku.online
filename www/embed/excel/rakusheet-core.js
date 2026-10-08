// rakusheet-core.js — what the Excel add-in and the Google Sheets sidebar share.
//
// A plain script that defines one global, RakuSheet, because a Web Worker
// loads it with importScripts. It turns spreadsheet values into the JSON
// request rakusheet.raku reads, runs one batch of formulas through Raku.js's
// rakupp_run, and turns the answer back into cell values. Each host keeps
// only what is its own: how the engine is loaded, where the definitions come
// from, and how an error is shown.

var RakuSheet = (function () {
  'use strict';

  // build.raku puts rakusheet.raku here as a JSON string.
  var DRIVER = "# rakusheet.raku — evaluates one batch of spreadsheet formulas.\n#\n# The host (the Excel add-in or the Google Sheets script) builds one program:\n# the workbook's own definitions (the \"Raku\" sheet, column A) first, so that\n# a line number in an error is the row it came from, then this file. The\n# batch arrives on standard input as JSON:\n#\n#     {\"calls\": [{\"code\": \"$^a * 2\", \"args\": [21]}, ...]}\n#\n# and the answer is one line on standard output, after a record separator so\n# that whatever a formula prints itself cannot be mistaken for it:\n#\n#     \\x1E[{\"ok\": [[42]]}, {\"err\": \"...\", \"kind\": \"value\"}, ...]\n#\n# Every \"ok\" is a matrix (a list of rows), because that is what a cell range\n# takes; the host unwraps a 1x1 matrix for a single cell.\n\nuse MONKEY-SEE-NO-EVAL;\n\n# The code of a formula is the body of an anonymous sub: $^a, $^b, ... are\n# its arguments in order and @_ is all of them, ranges flattened. Each\n# distinct code is compiled once per batch.\nmy %rakusheet-compiled;\n\nsub rakusheet-compile(Str $code) {\n    %rakusheet-compiled{$code} //= do {\n        # Raku++ 5.2 flattens an implicit @_ only one level, where Rakudo\n        # flattens it as *@_ does; spelling the slurpy out gives both engines\n        # the same @_. A placeholder forbids a signature, so only without one.\n        my $slurpy = $code.contains('@_') && $code !~~ / <[$@%&]> <[^:]> <.alpha> /;\n        EVAL $slurpy ?? \"sub (*\\@_) \\{ $code \\}\" !! \"sub \\{ $code \\}\"\n    }\n}\n\n# A range arrives as nested JSON arrays. Lists rather than Arrays, so that\n# @_ flattens a range into its cells instead of counting its rows.\nsub rakusheet-arg($v) {\n    $v ~~ Positional ?? $v.map(&rakusheet-arg).List !! $v\n}\n\n# One cell's worth of a result. A spreadsheet holds a double, a string or a\n# boolean: an exact rational becomes the nearest double here, once, and an\n# integer a double cannot hold becomes its digits.\nsub rakusheet-cell($v) {\n    given $v {\n        when Failure  { .exception.throw }\n        when !.defined { Any }\n        when Bool     { ?$v }\n        when Int      { $v.abs < 2 ** 53 ?? $v !! ~$v }\n        when Rational {\n            die \"#DIV/0: the result divides by zero\" if $v.denominator == 0;\n            rakusheet-cell($v.Num)\n        }\n        when Num {\n            die \"#NUM: the result is $v\" if $v.isNaN || $v == Inf | -Inf;\n            $v\n        }\n        when Str      { $v }\n        when Callable { die \"the formula returned code, not a value (is a * left over?)\" }\n        when Match    { ~$v }\n        default       { .Str }\n    }\n}\n\nsub rakusheet-is-list($v) {\n    $v.defined && $v !~~ Str && $v !~~ Match && ($v ~~ Positional || $v ~~ Seq)\n}\n\n# The whole result as rows. A flat list goes down one column; a list of\n# lists is a table, padded so that every row has the same width; a hash is\n# two columns of keys and values.\nsub rakusheet-matrix($r) {\n    if rakusheet-is-list($r) {\n        die \"the result is a lazy list; keep part of it with .head(N)\" if $r.is-lazy;\n        my @items = $r.list;\n        return [[\"\",],] unless @items;\n        if @items.first(&rakusheet-is-list).defined {\n            my @rows = @items.map: { rakusheet-is-list($_) ?? .list.map(&rakusheet-cell).eager.Array !! [rakusheet-cell($_)] };\n            my $width = @rows.map(*.elems).max;\n            return @rows.map({ [|$_, |(\"\" xx ($width - .elems))] }).eager.Array;\n        }\n        return @items.map({ [rakusheet-cell($_)] }).eager.Array;\n    }\n    if $r ~~ Pair {\n        return [[rakusheet-cell($r.key), rakusheet-cell($r.value)],];\n    }\n    if $r.defined && $r ~~ Associative {\n        return $r.sort(*.key).map({ [rakusheet-cell(.key), rakusheet-cell(.value)] }).eager.Array;\n    }\n    [[rakusheet-cell($r)],]\n}\n\n# An exception's message, or its type's name when it has none to give.\nsub rakusheet-text($e) {\n    ((try $e.message) // $e.^name).Str\n}\n\nsub rakusheet-kind($e) {\n    my $m = rakusheet-text($e);\n    return 'div0' if $e ~~ X::Numeric::DivideByZero || $m.starts-with('#DIV/0');\n    return 'name' if $e ~~ X::Undeclared | X::Undeclared::Symbols;\n    return 'num'  if $m.starts-with('#NUM');\n    'value'\n}\n\nsub rakusheet-message($e) {\n    my $m = rakusheet-text($e).subst(/^ '===SORRY!===' \\N* \\n/, '').lines.map(*.trim).grep(*.chars).join(' ');\n    $m.chars > 250 ?? $m.substr(0, 247) ~ '...' !! $m\n}\n\nsub rakusheet-call(%call) {\n    CATCH { default { return %( err => rakusheet-message($_), kind => rakusheet-kind($_) ) } }\n    my &formula = rakusheet-compile(%call<code> // '');\n    my $result = formula(|(%call<args> // []).map(&rakusheet-arg));\n    %( ok => rakusheet-matrix($result) )\n}\n\nsub rakusheet-run(Str $request) {\n    use Data::Native <json>;   # the engine's own JSON, answered with nothing installed\n    my %request = from-json($request);\n    # A loop, not a map: Raku.js 5.2.0's to-json does not reify an Array\n    # that a map over a sub with a CATCH filled lazily, and writes [].\n    my @answers;\n    for (%request<calls> // []).list -> %call { @answers.push: rakusheet-call(%call) }\n    put \"\\x1E\" ~ to-json(@answers, :!pretty);\n}\n\nrakusheet-run($*IN.slurp);\n";

  var RS = '\x1E';               // marks the driver's answer line
  var MAX_REQUEST = 8 * 1024 * 1024;   // ccall copies strings onto a 16 MB stack

  // What a new "Raku" sheet starts with, in column A, one line per row.
  // `fn` is how the host spells the formula: RAKU.EVAL in Excel, RAKU in Sheets.
  function exampleDefinitions(fn) {
    return [
    '# Raku definitions: every ' + fn + ' formula in this file can call these subs.',
    '# One line of Raku per row, in column A. Start a line with \' when it begins with = + or -.',
    '',
    '# =' + fn + '("iban-ok($^s)", A2) is TRUE for a valid IBAN: 30 digits, modulo 97, exactly.',
    'sub iban-ok(Str $iban) {',
    '    my $t = $iban.uc.comb(/<alnum>/).join;',
    '    my $digits = ($t.substr(4) ~ $t.substr(0, 4)).comb.map({ /\\d/ ?? $_ !! .ord - 55 }).join;',
    '    $digits % 97 == 1',
    '}',
    '',
    '# =' + fn + '("split-cents($^a, $^n)", 100, 3) fills three cells: 33.34, 33.33, 33.33.',
    'sub split-cents($amount, $n) {',
    '    my $cents = ($amount * 100).round;',
    '    (^$n).map({ ($cents div $n + ($_ < $cents mod $n ?? 1 !! 0)) / 100 })',
    '}'
    ];
  }

  // ---- values in -----------------------------------------------------------

  // One cell. An empty cell (Excel passes null, Sheets '') is Raku's Any. A
  // number goes as JSON prints it, the shortest decimal that is the same
  // double, which the driver reads as that exact decimal: 0.1 is 1/10.
  function scalar(v) {
    if (v === null || v === undefined || v === '') return null;
    if (typeof v === 'number') return isFinite(v) ? v : null;
    if (typeof v === 'boolean' || typeof v === 'string') return v;
    if (v instanceof Date) return isNaN(v.getTime()) ? null : v.toISOString();
    return String(v);
  }

  // One argument: a single cell is its value, a row or a column one list,
  // and anything wider a list of rows.
  function arg(v) {
    if (!Array.isArray(v)) return scalar(v);
    var rows = v.map(function (r) { return Array.isArray(r) ? r : [r]; });
    if (rows.length === 0) return [];
    if (rows.length === 1 && rows[0].length === 1) return scalar(rows[0][0]);
    if (rows.length === 1) return rows[0].map(scalar);
    if (rows.every(function (r) { return r.length === 1; }))
      return rows.map(function (r) { return scalar(r[0]); });
    return rows.map(function (r) { return r.map(scalar); });
  }

  // ---- one batch ------------------------------------------------------------

  // The definitions come first, so that line N of an error is row N of the
  // Raku sheet.
  function program(definitions) {
    return (definitions ? definitions + '\n' : '') + DRIVER;
  }

  function request(calls) {
    return JSON.stringify({
      calls: calls.map(function (c) {
        return { code: String(c.code == null ? '' : c.code), args: (c.args || []).map(arg) };
      })
    });
  }

  // The first line of what the engine printed to stderr that says something,
  // for a batch that never got as far as answering.
  function failure(lines) {
    var text = lines.map(function (l) { return l.replace(/\x1B\[[0-9;]*m/g, '').trim(); })
      .filter(function (l) { return l && !/^===SORRY!===\s*$/.test(l); });
    var first = (text[0] || 'the program stopped without an answer').replace(/^===SORRY!===\s*/, '');
    var where = text.filter(function (l) { return /^at web:\d+/.test(l); })[0];
    return first + (where ? ' (' + where.replace(/^at web:/, 'row ') + ')' : '');
  }

  // An engine is a loaded Raku.js module plus the sink its print callbacks
  // write to. run() is synchronous, as rakupp_run is.
  function Engine(module, sink) {
    this.module = module;
    this.sink = sink;
    this.broken = false;
    this.version = module.ccall('rakupp_version', 'string', [], []);
  }

  // Runs one batch. Returns { answers, printed, warnings, ms }: one answer
  // per call, each { ok: matrix } or { err: message, kind }. A throw out of
  // here (a JavaScript stack overflow, an abort) leaves the engine unusable;
  // `broken` says so, and the host makes a new one.
  Engine.prototype.run = function (definitions, calls) {
    var src = program(definitions);
    var req = request(calls);
    if (src.length + req.length > MAX_REQUEST) {
      return everyone(calls, 'too much data for one batch: ' + Math.round((src.length + req.length) / 1048576) + ' MB');
    }
    var out = [], err = [];
    var t0 = Date.now();
    this.sink.out = function (t) { out.push(t); };
    this.sink.err = function (t) { err.push(t); };
    try {
      this.module.ccall('rakupp_run', 'number', ['string', 'string'], [src, req]);
    } catch (e) {
      this.broken = true;
      throw e;
    } finally {
      this.sink.out = this.sink.err = function () {};
    }
    var answer = null, printed = [];
    out.forEach(function (line) {
      if (line.charAt(0) === RS) answer = line.slice(1); else printed.push(line);
    });
    var ms = Date.now() - t0;
    if (answer === null) {
      var r = everyone(calls, 'Raku sheet: ' + failure(err));
      r.printed = printed; r.warnings = err; r.ms = ms;
      return r;
    }
    return { answers: JSON.parse(answer), printed: printed, warnings: err, ms: ms };
  };

  function everyone(calls, message) {
    return {
      answers: calls.map(function () { return { err: message, kind: 'value' }; }),
      printed: [], warnings: [], ms: 0
    };
  }

  // Loads the engine. `factory` is the RakuJS function rakujs.js defines.
  // In a browser it fetches rakujs.wasm itself (options.locateFile says
  // where); a test that holds the module already passes options.wasmBytes.
  // The glue reads no wasmBinary option, so the bytes go in through
  // its instantiateWasm hook, whose failure would otherwise leave the load
  // waiting forever.
  function start(factory, options) {
    var sink = { out: function () {}, err: function () {} };
    var opts = {}, failed;
    var failure = new Promise(function (resolve, reject) { failed = reject; });
    Object.keys(options || {}).forEach(function (k) { if (k !== 'wasmBytes') opts[k] = options[k]; });
    opts.print = function (t) { sink.out(t); };
    opts.printErr = function (t) { sink.err(t); };
    if (options && options.wasmBytes) {
      var bytes = options.wasmBytes;
      opts.instantiateWasm = function (imports, done) {
        WebAssembly.instantiate(bytes, imports).then(function (r) { done(r.instance, r.module); }, failed);
        return {};
      };
    }
    return Promise.race([factory(opts), failure]).then(function (module) { return new Engine(module, sink); });
  }

  // ---- values out -------------------------------------------------------------

  // A matrix with Raku's Any (null) as an empty cell.
  function cells(matrix) {
    return matrix.map(function (row) {
      return row.map(function (v) { return v === null ? '' : v; });
    });
  }

  return {
    start: start,
    cells: cells,
    exampleDefinitions: exampleDefinitions,
    // exposed for the tests
    arg: arg,
    program: program,
    request: request
  };
})();
