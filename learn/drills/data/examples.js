/* examples.js — the runnable demonstrations in the iOS app's Lab, plus the
 * starter files of the workspace they run in.
 *
 * Authored here rather than in Swift so that `node tools/verify-examples.js`
 * can lay down the very same starter files, run every program through the
 * native Raku++ interpreter and check that `expect` is what it really prints.
 * tools/export-examples.js turns this into examples.json for the app.
 *
 *   expect   what the program prints, exactly — omit for anything whose output
 *            is a timing or otherwise varies from run to run
 *   files    true if the program reads or writes the workspace
 */

// The workspace as a program first finds it. The app writes these on first
// launch and restores them on Reset, and the verifier writes them into a
// scratch directory, so the examples see identical bytes in both places.
const SEED = {
  'words.txt': 'alpha\nbeta\ngamma\ndelta\nepsilon\n',

  'inventory.csv':
    '# A tiny inventory, one item per line: name,quantity,price\n' +
    'rope,4,12.50\n' +
    'lantern,2,30.00\n' +
    'rations,12,3.75\n' +
    'compass,1,45.00\n',

  'README.txt':
    'Raku Drills workspace\n\n' +
    'This folder is the current directory of every program you run. Anything a\n' +
    'program writes with spurt or open lands here, and shows up in the Files app\n' +
    'under "Raku Drills".\n\n' +
    'Reset from the Files tab to bring these starter files back.\n',
};

const SECTIONS = [
  {
    title: 'Concurrency',
    caption: 'Real threads, on the phone. Every example here runs concurrently — the timing one proves it.',
    examples: [
      {
        title: 'start and await',
        blurb: 'A promise is work handed to the thread pool. `await` waits for its value.',
        code: `my $p = start {
    sleep 0.1;      # pretend this is slow
    6 * 7
}

say "the work is running…";
say "answer: ", await $p;`,
        expect: 'the work is running…\nanswer: 42',
      },
      {
        title: 'Four at once',
        blurb: 'Four sleeps of 0.2 s. One after another that is 0.8 s; started together, 0.2 s.',
        code: `my $t0 = now;
sleep 0.2 for 1..4;
say "one after another: ", ((now - $t0) * 1000).Int, " ms";

my $t1 = now;
await (1..4).map: { start { sleep 0.2 } };
say "all at once:       ", ((now - $t1) * 1000).Int, " ms";`,
      },
      {
        title: 'Parallel map',
        blurb: 'A promise per item, then await the lot. The results keep their order.',
        code: `my @jobs = (1..8).map: -> $n { start { $n ** 2 } };
say "squares: ", (await @jobs).join(", ");`,
        expect: 'squares: 1, 4, 9, 16, 25, 36, 49, 64',
      },
      {
        title: 'Promise.allof',
        blurb: 'One promise, kept once every promise it was given has been kept.',
        code: `my @p = (1..3).map: -> $n { start { sleep 0.05 * $n; $n * 10 } };

await Promise.allof(@p);
say "all finished: ", @p.map(*.result).join(",");`,
        expect: 'all finished: 10,20,30',
      },
      {
        title: 'Channel',
        blurb: 'A thread-safe queue: one thread sends, another receives. Closing it ends the loop.',
        code: `my $c = Channel.new;

my $producer = start {
    for 1..5 { $c.send($_ * $_) }
    $c.close;
}

my $sum = 0;
for $c.list -> $v {
    say "got $v";
    $sum += $v;
}
await $producer;
say "sum: $sum";`,
        expect: 'got 1\ngot 4\ngot 9\ngot 16\ngot 25\nsum: 55',
      },
      {
        title: 'react and whenever',
        blurb: 'Reactive style: `react` runs until the stream is done, firing the block per value.',
        code: `react {
    whenever Supply.from-list(1..5) -> $v {
        print "$v ";
        done if $v == 5;
    }
}
say "";`,
        expect: '1 2 3 4 5 ',
      },
      {
        title: 'Supply.interval',
        blurb: 'A supply that emits on a timer — the reactive way to write a clock.',
        code: `my $ticks = 0;
react {
    whenever Supply.interval(0.05) {
        $ticks++;
        say "tick $ticks";
        done if $ticks == 3;
    }
}
say "stopped after $ticks ticks";`,
        expect: 'tick 1\ntick 2\ntick 3\nstopped after 3 ticks',
      },
      {
        title: 'Lock',
        blurb: 'Eight threads, one counter. `protect` lets exactly one of them in at a time.',
        code: `my $lock = Lock.new;
my $count = 0;

await (1..8).map: {
    start {
        for 1..1000 {
            $lock.protect: { $count++ }
        }
    }
}

say "counter: $count";`,
        expect: 'counter: 8000',
      },
      {
        title: 'Thread',
        blurb: 'The layer underneath. Usually you want `start`, but the raw thread is there.',
        code: `my $t = Thread.start({ say "hello from a thread" });
$t.finish;
say "joined";`,
        expect: 'hello from a thread\njoined',
      },
    ],
  },

  {
    title: 'Files',
    caption: 'Every program runs with the workspace as its current directory. What it writes is real — look in the Files tab.',
    examples: [
      {
        title: 'Read a file',
        blurb: '`slurp` takes the whole file; `.IO.lines` gives it a line at a time.',
        files: true,
        code: `say slurp("words.txt").chars, " characters";

for "words.txt".IO.lines.kv -> $i, $line {
    say "{$i + 1}: $line";
}`,
        expect: '31 characters\n1: alpha\n2: beta\n3: gamma\n4: delta\n5: epsilon',
      },
      {
        title: 'Write a file',
        blurb: '`spurt` writes a whole string at once. Look for squares.txt in the Files tab afterwards.',
        files: true,
        code: `spurt "squares.txt",
      (1..5).map({ "$_ => {$_ ** 2}" }).join("\\n") ~ "\\n";

say "wrote squares.txt:";
say slurp("squares.txt").trim;`,
        expect: 'wrote squares.txt:\n1 => 1\n2 => 4\n3 => 9\n4 => 16\n5 => 25',
      },
      {
        title: 'Open, append, close',
        blurb: 'A handle, for writing as you go: `:w` truncates, `:a` appends.',
        files: true,
        code: `my $fh = open "log.txt", :w;
$fh.say("first line");
$fh.close;

my $more = open "log.txt", :a;
$more.say("second line");
$more.close;

say "log.txt now: ", slurp("log.txt").lines.join(" | ");`,
        expect: 'log.txt now: first line | second line',
      },
      {
        title: 'List the workspace',
        blurb: '`dir` hands back `IO::Path` objects, so each one can be asked what it is.',
        files: true,
        code: `for dir(".").sort -> $path {
    say $path.d ?? "$path/" !! "$path  ({$path.s} bytes)";
}`,
      },
      {
        title: 'Does it exist?',
        blurb: '`.e` exists, `.f` is a file, `.d` is a directory, `.s` is the size in bytes.',
        files: true,
        code: `for <words.txt inventory.csv nope.txt> -> $name {
    my $p = $name.IO;
    say $name, ": ", $p.e ?? "{$p.s} bytes" !! "not there";
}`,
        expect: 'words.txt: 31 bytes\ninventory.csv: 120 bytes\nnope.txt: not there',
      },
      {
        title: 'Parse a CSV',
        blurb: 'Read, split, total — the everyday shape of a file-handling program.',
        files: true,
        code: `my $total = 0;

for "inventory.csv".IO.lines -> $line {
    next if $line.starts-with('#') || !$line.trim;
    my ($name, $qty, $price) = $line.split(',');
    my $sum = $qty * $price;
    $total += $sum;
    say sprintf('%-10s %3d × %6.2f = %8.2f', $name, $qty, $price, $sum);
}

say '-' x 36;
say sprintf('%-10s %24.2f', 'total', $total);`,
        expect: 'rope         4 ×  12.50 =    50.00\nlantern      2 ×  30.00 =    60.00\nrations     12 ×   3.75 =    45.00\ncompass      1 ×  45.00 =    45.00\n' + '-'.repeat(36) + '\ntotal                        200.00',
      },
      {
        title: 'Word frequency',
        blurb: 'A hash counter over a file — and `unlink`, to clean up after itself.',
        files: true,
        code: `my %count;
%count{$_}++ for slurp("words.txt").words;

for %count.sort(*.key) {
    say .key, ": ", .value;
}

spurt "tmp.txt", "throwaway";
say "made tmp.txt: ", "tmp.txt".IO.e;
unlink "tmp.txt";
say "and removed it: ", !"tmp.txt".IO.e;`,
        expect: 'alpha: 1\nbeta: 1\ndelta: 1\nepsilon: 1\ngamma: 1\nmade tmp.txt: True\nand removed it: True',
      },
    ],
  },
];

const DATA = { seed: SEED, sections: SECTIONS };

if (typeof module !== 'undefined' && module.exports) module.exports = DATA;
if (typeof window !== 'undefined') window.EXAMPLES = DATA;
