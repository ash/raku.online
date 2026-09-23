# Written by `rakupp build.raku --record`. Do not edit by hand: re-record.
{
  recorded => "2026-09-23",
  oracle   => "Rakudo 2026.08",
  engine   => "Raku++ 4.0.1-132-g3e242220-modified",
  cases    => {
  "literals-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(:answer(7), :enabled, :!hidden, :count(8))\nSTR\tanswer\t7 enabled\tTrue hidden\tFalse count\t8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(:answer(7), :enabled, :!hidden, :count(8))\nSTR\tanswer\t7 enabled\tTrue hidden\tFalse count\t8\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::False, Nil, Any, Bool::False)\nSTR\tTrue False   False\nBOOL\tTrue\n", err => "Use of Nil in string context\n  in code  at literals-00000041.raku line 3\nUse of uninitialized value of type Any in string context.\nMethods .^name, .raku, .gist, or .say can be used to stringify it to something meaningful.\n  in code  at literals-00000041.raku line 3\n" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::False, Nil, Any, Bool::False)\nSTR\tTrue False   False\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(45, 493, 51966, 255)\nSTR\t45 493 51966 255\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(45, 493, 51966, 255)\nSTR\t45 493 51966 255\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"value=4\", \"next=5\", \"array=4,5\")\nSTR\tvalue=4 next=5 array=4,5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"value=4\", \"next=5\", \"array=4,5\")\nSTR\tvalue=4 next=5 array=4,5\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(<1/3>, <1/3>, 3.5, 1.0)\nSTR\t0.333333 0.333333 3.5 1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(<1/3>, <1/3>, 3.5, 1.0)\nSTR\t0.333333 0.333333 3.5 1\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tHash\nRAKU\t\$\{:alpha(2), :beta(3), :nested(\$\{:ok(Bool::True)})}\nSTR\talpha\t2\nbeta\t3\nnested\tok\tTrue\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tHash\nRAKU\t\$\{:alpha(2), :beta(3), :nested(\$\{:ok(Bool::True)})}\nSTR\talpha\t2\nbeta\t3\nnested\tok\tTrue\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(<2+3i>, <2-3i>, 5e0)\nSTR\t2+3i 2-3i 5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(<2+3i>, <2-3i>, 5e0)\nSTR\t2+3i 2-3i 5\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(v1.2.3, v1.2.4, v2.0.0, Bool::True)\nSTR\t1.2.3 1.2.4 2.0.0 True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"1.2.3\", \"1.2.4\", \"2.0.0\", Bool::True)\nSTR\t1.2.3 1.2.4 2.0.0 True\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"raw \\\$text\", \"double\\nline\", \"\\\\x52aku\", \"corner quotes\")\nSTR\traw \$text double\nline \\x52aku corner quotes\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"raw \\\$text\", \"double\\nline\", \"\\\\x52aku\", \"corner quotes\")\nSTR\traw \$text double\nline \\x52aku corner quotes\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1000000, 165, 12345.6789)\nSTR\t1000000 165 12345.6789\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1000000, 165, 12345.6789)\nSTR\t1000000 165 12345.6789\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[5, 6, [8, 13], \"raku\"]\nSTR\t5 6 8 13 raku\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[5, 6, [8, 13], \"raku\"]\nSTR\t5 6 8 13 raku\nBOOL\tTrue\n", err => "" },
  },
  "literals-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1000e0, 0.025e0, 6.022e+23, -0e0)\nSTR\t1000 0.025 6.022e+23 -0\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1000e0, 0.025e0, 6.022e+23, -0e0)\nSTR\t1000 0.025 6.022e+23 -0\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(8, 9, 9)\nSTR\t8 9 9\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(8, 9, 9)\nSTR\t8 9 9\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[:alpha(6), :beta(7), :gamma(13)]\nSTR\talpha\t6 beta\t7 gamma\t13\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[:alpha(6), :beta(7), :gamma(13)]\nSTR\talpha\t6 beta\t7 gamma\t13\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t16\nSTR\t16\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t16\nSTR\t16\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t45\nSTR\t45\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t45\nSTR\t45\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 7)\nSTR\t7 7\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 7)\nSTR\t7 7\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(4, 6, 4)\nSTR\t4 6 4\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(4, 6, 4)\nSTR\t4 6 4\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, 9, 13)\nSTR\t3 9 13\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, 9, 13)\nSTR\t3 9 13\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[16, 16]\nSTR\t16 16\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[16, 16]\nSTR\t16 16\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(6, 21)\nSTR\t6 21\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(6, 21)\nSTR\t6 21\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1, 2, 3)\nSTR\t1 2 3\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1, 2, 3)\nSTR\t1 2 3\nBOOL\tTrue\n", err => "" },
  },
  "variables-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(4, 5, [8, 13])\nSTR\t4 5 8 13\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(4, 5, [8, 13])\nSTR\t4 5 8 13\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tNum\nRAKU\tNaN\nSTR\tNaN\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tNum\nRAKU\tNaN\nSTR\tNaN\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tNum\nRAKU\t-Inf\nSTR\t-Inf\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tNum\nRAKU\t-Inf\nSTR\t-Inf\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tRat\nRAKU\t-0.5\nSTR\t-0.5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tRat\nRAKU\t-0.5\nSTR\t-0.5\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tComplex\nRAKU\t<NaN+2i>\nSTR\tNaN+2i\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tComplex\nRAKU\t<NaN+2i>\nSTR\tNaN+2i\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tRat\nRAKU\t-1.5\nSTR\t-1.5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tRat\nRAKU\t-1.5\nSTR\t-1.5\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tNum\nRAKU\t-1e0\nSTR\t-1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tNum\nRAKU\t-1e0\nSTR\t-1\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t1\nSTR\t1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t1\nSTR\t1\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tRat\nRAKU\t<7/3>\nSTR\t2.333333\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tRat\nRAKU\t<7/3>\nSTR\t2.333333\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tComplex\nRAKU\t<0.42857142857142855+7.905747460161236e+18i>\nSTR\t0.42857142857142855+7.905747460161236e+18i\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tComplex\nRAKU\t<0.4285714285714285+7.905747460161235e+18i>\nSTR\t0.4285714285714285+7.905747460161235e+18i\nBOOL\tTrue\n", err => "" },
  },
  "numeric-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tNum\nRAKU\t0e0\nSTR\t0\nBOOL\tFalse\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tNum\nRAKU\t0e0\nSTR\t0\nBOOL\tFalse\n", err => "" },
  },
  "operators-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"odd\"\nSTR\todd\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"odd\"\nSTR\todd\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(any(Bool::False, Bool::False, Bool::False, Bool::False, Bool::True, Bool::False), all(Bool::True, Bool::True))\nSTR\t<undefined>\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(any(Bool::False, Bool::False, Bool::False, Bool::False, Bool::True, Bool::False), all(Bool::True, Bool::True))\nSTR\tany all\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(21, 5, 104, 1.625, 1, 5)\nSTR\t21 5 104 1.625 1 5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(21, 5, 104, 1.625, 1, 5)\nSTR\t21 5 104 1.625 1 5\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[2, 15, 7]\nSTR\t2 15 7\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[2, 15, 7]\nSTR\t2 15 7\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"raku\", \"rarara\", Bool::False, Order::More)\nSTR\traku rarara False More\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"raku\", \"rarara\", Bool::False, Order::More)\nSTR\traku rarara False More\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(5, 6, 7, 8)\nSTR\t5 6 7 8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(5, 6, 7, 8)\nSTR\t5 6 7 8\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::True, Bool::True)\nSTR\tTrue True True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::True, Bool::True)\nSTR\tTrue True True\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t42\nSTR\t42\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t439\nSTR\t439\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::False, Bool::True, Bool::True, Bool::True, Order::Less)\nSTR\tFalse True True True Less\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::False, Bool::True, Bool::True, Bool::True, Order::Less)\nSTR\tFalse True True True Less\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"a:1\", \"a:2\", \"b:1\", \"b:2\"]\nSTR\ta:1 a:2 b:1 b:2\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"a:1\", \"a:2\", \"b:1\", \"b:2\"]\nSTR\ta:1 a:2 b:1 b:2\nBOOL\tTrue\n", err => "" },
  },
  "operators-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"yes\", \"fallback\", \"defined\")\nSTR\tyes fallback defined\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"yes\", \"fallback\", \"defined\")\nSTR\tyes fallback defined\nBOOL\tTrue\n", err => "" },
  },
  "control-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, 3, 5]\nSTR\t1 3 5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, 3, 5]\nSTR\t1 3 5\nBOOL\tTrue\n", err => "" },
  },
  "control-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[0, 1, 2, 3, 4, 5, 6]\nSTR\t0 1 2 3 4 5 6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[0, 1, 2, 3, 4, 5, 6]\nSTR\t0 1 2 3 4 5 6\nBOOL\tTrue\n", err => "" },
  },
  "control-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"even\"\nSTR\teven\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"even\"\nSTR\teven\nBOOL\tTrue\n", err => "" },
  },
  "control-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tSeq\nRAKU\t\$((0, 2).Seq)\nSTR\t0 2\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tSeq\nRAKU\t\$((0, 2).Seq)\nSTR\t0 2\nBOOL\tTrue\n", err => "" },
  },
  "control-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"small\"\nSTR\tsmall\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"small\"\nSTR\tsmall\nBOOL\tTrue\n", err => "" },
  },
  "control-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t30\nSTR\t30\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t30\nSTR\t30\nBOOL\tTrue\n", err => "" },
  },
  "control-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[0, 1, 2, 3, 4]\nSTR\t0 1 2 3 4\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[0, 1, 2, 3, 4]\nSTR\t0 1 2 3 4\nBOOL\tTrue\n", err => "" },
  },
  "control-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"done\", [\"body\", \"leave\"])\nSTR\tdone body leave\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"done\", [\"body\", \"leave\"])\nSTR\tdone body leave\nBOOL\tTrue\n", err => "" },
  },
  "control-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]\nSTR\t1 2 3 4 5 6 7 8 9 10\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]\nSTR\t1 2 3 4 5 6 7 8 9 10\nBOOL\tTrue\n", err => "" },
  },
  "control-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"zero\"]\nSTR\tzero\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"zero\"]\nSTR\tzero\nBOOL\tTrue\n", err => "" },
  },
  "control-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::False, \"X::AdHoc\")\nSTR\tFalse X::AdHoc\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::False, \"X::AdHoc\")\nSTR\tFalse X::AdHoc\nBOOL\tTrue\n", err => "" },
  },
  "control-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[0, 1, 4, 9, 16]\nSTR\t0 1 4 9 16\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[0, 1, 4, 9, 16]\nSTR\t0 1 4 9 16\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(8, 11)\nSTR\t8 11\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(8, 11)\nSTR\t8 11\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"int:6\", \"str:6\")\nSTR\tint:6 str:6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"int:6\", \"str:6\")\nSTR\tint:6 str:6\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t11\nSTR\t11\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t11\nSTR\t11\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(8, \"Int\")\nSTR\t8 Int\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(8, \"Int\")\nSTR\t8 Int\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(9, 6)\nSTR\t9 6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(9, 6)\nSTR\t9 6\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t2\nSTR\t2\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t2\nSTR\t2\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[:alpha(9), :beta(8)]\nSTR\talpha\t9 beta\t8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[:alpha(9), :beta(8)]\nSTR\talpha\t9 beta\t8\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"negative\", \"zero\", \"positive\")\nSTR\tnegative zero positive\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"negative\", \"zero\", \"positive\")\nSTR\tnegative zero positive\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(36, 42)\nSTR\t36 42\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(36, 42)\nSTR\t36 42\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"raku:5\"\nSTR\traku:5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"raku:5\"\nSTR\traku:5\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t12\nSTR\t12\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t12\nSTR\t12\nBOOL\tTrue\n", err => "" },
  },
  "subs-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(2, (42, -1))\nSTR\t2 42 -1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(2, (42, -1))\nSTR\t2 42 -1\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t42\nSTR\t42\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t42\nSTR\t42\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Bool\", Bool::True)\nSTR\tBool True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Bool\", Bool::True)\nSTR\tBool True\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"a=0;b=Bool::True\"\nSTR\ta=0;b=Bool::True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"a=0;b=Bool::True\"\nSTR\ta=0;b=Bool::True\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t1\nSTR\t1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t1\nSTR\t1\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t84\nSTR\t84\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t84\nSTR\t84\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t42\nSTR\t42\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t42\nSTR\t42\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"Str:text\"\nSTR\tStr:text\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"Str:text\"\nSTR\tStr:text\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, [Bool::True, \"text\", Bool::True])\nSTR\t3 True text True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, [Bool::True, \"text\", Bool::True])\nSTR\t3 True text True\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, Bool::True)\nSTR\t0 True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, Bool::True)\nSTR\t0 True\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", 2)\nSTR\tInt 2\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", 2)\nSTR\tInt 2\nBOOL\tTrue\n", err => "" },
  },
  "signatures-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t1\nSTR\t1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t1\nSTR\t1\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t0\nSTR\t0\nBOOL\tFalse\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t0\nSTR\t0\nBOOL\tFalse\n", err => "" },
  },
  "containers-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::True)\nSTR\tTrue True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::True)\nSTR\tTrue True\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"text\", \"text\"]\nSTR\ttext text\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"text\", \"text\"]\nSTR\ttext text\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0.5, 0.5)\nSTR\t0.5 0.5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0.5, 0.5)\nSTR\t0.5 0.5\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t42\nSTR\t42\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t42\nSTR\t42\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, -1)\nSTR\t0 -1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, -1)\nSTR\t0 -1\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tBool\nRAKU\tBool::True\nSTR\tTrue\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tBool\nRAKU\tBool::True\nSTR\tTrue\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1, \"Array\", \$[\"text\", 0])\nSTR\t1 Array text 0\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(1, \"Array\", \$[\"text\", 0])\nSTR\t1 Array text 0\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(2, [[0.5, Bool::True], 0.5])\nSTR\t2 0.5 True 0.5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(2, [[0.5, Bool::True], 0.5])\nSTR\t2 0.5 True 0.5\nBOOL\tTrue\n", err => "" },
  },
  "containers-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, [42, \"text\", 42])\nSTR\t3 42 text 42\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, [42, \"text\", 42])\nSTR\t3 42 text 42\nBOOL\tTrue\n", err => "" },
  },
  "types-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Array[Int]\", \"Int\", [7, 8], Bool::True)\nSTR\tArray[Int] Int 7 8 True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Array[Int]\", \"Int\", Array[Int].new(7, 8), Bool::True)\nSTR\tArray[Int] Int 7 8 True\nBOOL\tTrue\n", err => "" },
  },
  "types-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Item\", Bool::True, [\"Named\"])\nSTR\tItem True Named\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Item\", Bool::True, [\"Named\"])\nSTR\tItem True Named\nBOOL\tTrue\n", err => "" },
  },
  "types-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", \"Int\", Bool::True)\nSTR\tInt Int True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", \"Int\", Bool::True)\nSTR\tInt Int True\nBOOL\tTrue\n", err => "" },
  },
  "types-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(5, \"mixed\", Bool::True)\nSTR\t5 mixed True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(5, \"mixed\", Bool::True)\nSTR\t5 mixed True\nBOOL\tTrue\n", err => "" },
  },
  "types-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, 3, Bool::True, \"3\")\nSTR\t3 3 True 3\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, 3, Bool::True, \"3\")\nSTR\t3 3 True 3\nBOOL\tTrue\n", err => "" },
  },
  "types-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Pair\", \"answer\", 2, Bool::True)\nSTR\tPair answer 2 True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Pair\", \"answer\", 2, Bool::True)\nSTR\tPair answer 2 True\nBOOL\tTrue\n", err => "" },
  },
  "types-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, 1, [\"East\", \"North\", \"South\", \"West\"])\nSTR\t0 1 East North South West\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, 1, [\"East\", \"North\", \"South\", \"West\"])\nSTR\t0 1 East North South West\nBOOL\tTrue\n", err => "" },
  },
  "types-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", 16)\nSTR\tInt 16\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", 16)\nSTR\tInt 16\nBOOL\tTrue\n", err => "" },
  },
  "types-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(9, Bool::True, [\"Child\", \"Parent\", \"Any\", \"Mu\"])\nSTR\t9 True Child Parent Any Mu\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(9, Bool::True, [\"Child\", \"Parent\", \"Any\", \"Mu\"])\nSTR\t9 True Child Parent Any Mu\nBOOL\tTrue\n", err => "" },
  },
  "types-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::False, Bool::False, Bool::True, Bool::True)\nSTR\tFalse False True True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::False, Bool::False, Bool::True, Bool::True)\nSTR\tFalse False True True\nBOOL\tTrue\n", err => "" },
  },
  "types-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", Bool::False, Bool::True, \"Perl6::Metamodel::ClassHOW\")\nSTR\tInt False True Perl6::Metamodel::ClassHOW\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Int\", Bool::False, Bool::True, \"Perl6::Metamodel::ClassHOW\")\nSTR\tInt False True Perl6::Metamodel::ClassHOW\nBOOL\tTrue\n", err => "" },
  },
  "types-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(4, \"Int\", Bool::True, Bool::True)\nSTR\t4 Int True True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(4, \"Int\", Bool::True, Bool::True)\nSTR\t4 Int True True\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t20\nSTR\t20\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t20\nSTR\t20\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(6, 4)\nSTR\t6 4\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(6, 4)\nSTR\t6 4\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"parent\", [\"Child\", \"Parent\", \"Any\", \"Mu\"])\nSTR\tparent Child Parent Any Mu\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"parent\", [\"Child\", \"Parent\", \"Any\", \"Mu\"])\nSTR\tparent Child Parent Any Mu\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"unknown:2\"\nSTR\tunknown:2\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"unknown:2\"\nSTR\tunknown:2\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"int:7\", \"str:7\")\nSTR\tint:7 str:7\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"int:7\", \"str:7\")\nSTR\tint:7 str:7\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t15\nSTR\t15\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t15\nSTR\t15\nBOOL\tTrue\n", err => "" },
  },
  "methods-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"alpha\", \"beta\", \"gamma\"]\nSTR\talpha beta gamma\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"alpha\", \"beta\", \"gamma\"]\nSTR\talpha beta gamma\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::False)\nSTR\tTrue False\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, Bool::False)\nSTR\tTrue False\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, 2, 5, \"abc\")\nSTR\tTrue 2 5 abc\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, 2, 5, \"abc\")\nSTR\tTrue 2 5 abc\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[(\"one\", 0, 3), (\"three\", 7, 12)]\nSTR\tone 0 3 three 7 12\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[(\"one\", 0, 3), (\"three\", 7, 12)]\nSTR\tone 0 3 three 7 12\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"abc\", \"42\")\nSTR\tTrue abc 42\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"abc\", \"42\")\nSTR\tTrue abc 42\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"a\", \"bb\", \"ccc\"]\nSTR\ta bb ccc\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"a\", \"bb\", \"ccc\"]\nSTR\ta bb ccc\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"aaa\", 3)\nSTR\tTrue aaa 3\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"aaa\", 3)\nSTR\tTrue aaa 3\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"abc\", 0, 6)\nSTR\tTrue abc 0 6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"abc\", 0, 6)\nSTR\tTrue abc 0 6\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"AbC\", 0, 3)\nSTR\tTrue AbC 0 3\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"AbC\", 0, 3)\nSTR\tTrue AbC 0 3\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"aaa\", 0, 3)\nSTR\tTrue aaa 0 3\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"aaa\", 0, 3)\nSTR\tTrue aaa 0 3\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"a#b#c#\"\nSTR\ta#b#c#\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"a#b#c#\"\nSTR\ta#b#c#\nBOOL\tTrue\n", err => "" },
  },
  "regex-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"gamma\", 0, 5)\nSTR\tTrue gamma 0 5\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(Bool::True, \"gamma\", 0, 5)\nSTR\tTrue gamma 0 5\nBOOL\tTrue\n", err => "" },
  },
  "grammars-00000040" => {
    rakudo => { exit => 0, out => "#0 input \"53\"\n\@0 kind Match\n\@0 str \"53\"\n\@0 from 0\n\@0 to 2\n\@0 orig \"53\"\n\@0 target \"53\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0 caps \n#1 input \"1\"\n\@1 kind Match\n\@1 str \"1\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"1\"\n\@1 target \"1\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1 caps \n#2 input \"2\"\n\@2 kind Match\n\@2 str \"2\"\n\@2 from 0\n\@2 to 1\n\@2 orig \"2\"\n\@2 target \"2\"\n\@2 pre \"\"\n\@2 post \"\"\n\@2 made Nil\n\@2 caps \n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"53\"\n\@0 kind Match\n\@0 str \"53\"\n\@0 from 0\n\@0 to 2\n\@0 orig \"53\"\n\@0 target \"53\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0 caps \n#1 input \"1\"\n\@1 kind Match\n\@1 str \"1\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"1\"\n\@1 target \"1\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1 caps \n#2 input \"2\"\n\@2 kind Match\n\@2 str \"2\"\n\@2 from 0\n\@2 to 1\n\@2 orig \"2\"\n\@2 target \"2\"\n\@2 pre \"\"\n\@2 post \"\"\n\@2 made Nil\n\@2 caps \n", err => "" },
  },
  "grammars-00000041" => {
    rakudo => { exit => 0, out => "#0 input \"cbc\"\n\@0 kind Match\n\@0 str \"cbc\"\n\@0 from 0\n\@0 to 3\n\@0 orig \"cbc\"\n\@0 target \"cbc\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<k0> kind Match\n\@0<k0> str \"cbc\"\n\@0<k0> from 0\n\@0<k0> to 3\n\@0<k0> orig \"cbc\"\n\@0<k0> target \"cbc\"\n\@0<k0> pre \"\"\n\@0<k0> post \"\"\n\@0<k0> made Nil\n\@0<k0> caps \n\@0 caps k0=\"cbc\"\n#1 input \"c\"\n\@1 kind Match\n\@1 str \"c\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"c\"\n\@1 target \"c\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1<r0> kind Match\n\@1<r0> str \"c\"\n\@1<r0> from 0\n\@1<r0> to 1\n\@1<r0> orig \"c\"\n\@1<r0> target \"c\"\n\@1<r0> pre \"\"\n\@1<r0> post \"\"\n\@1<r0> made Nil\n\@1<r0> caps \n\@1 caps r0=\"c\"\n#2 input \"6\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"cbc\"\n\@0 kind Match\n\@0 str \"cbc\"\n\@0 from 0\n\@0 to 3\n\@0 orig \"cbc\"\n\@0 target \"cbc\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<k0> kind Match\n\@0<k0> str \"cbc\"\n\@0<k0> from 0\n\@0<k0> to 3\n\@0<k0> orig \"cbc\"\n\@0<k0> target \"cbc\"\n\@0<k0> pre \"\"\n\@0<k0> post \"\"\n\@0<k0> made Nil\n\@0<k0> caps \n\@0 caps k0=\"cbc\"\n#1 input \"c\"\n\@1 kind Match\n\@1 str \"c\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"c\"\n\@1 target \"c\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1<r0> kind Match\n\@1<r0> str \"c\"\n\@1<r0> from 0\n\@1<r0> to 1\n\@1<r0> orig \"c\"\n\@1<r0> target \"c\"\n\@1<r0> pre \"\"\n\@1<r0> post \"\"\n\@1<r0> made Nil\n\@1<r0> caps \n\@1 caps r0=\"c\"\n#2 input \"6\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000042" => {
    rakudo => { exit => 0, out => "#0 input \"b\"\n\@0 kind Match\n\@0 str \"b\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"b\"\n\@0 target \"b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0 caps \n#1 input \"\"\n\@1 kind Nil\n#2 input \"(b\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"b\"\n\@0 kind Match\n\@0 str \"b\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"b\"\n\@0 target \"b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0 caps \n#1 input \"\"\n\@1 kind Nil\n#2 input \"(b\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000043" => {
    rakudo => { exit => 0, out => "#0 input \"2a1ax>a a21a1_ab2a2a\"\n\@0 kind Nil\n#1 input \"12ax>>>a a2aa1a\"\n\@1 kind Nil\n#2 input \"_b0ax>>a aaa10a\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"2a1ax>a a21a1_ab2a2a\"\n\@0 kind Nil\n#1 input \"12ax>>>a a2aa1a\"\n\@1 kind Nil\n#2 input \"_b0ax>>a aaa10a\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000044" => {
    rakudo => { exit => 0, out => "#0 input \"  b a 1 0 2 - 1 <\"\n\@0 kind Nil\n#1 input \"  b _ 2 a _ - b <\"\n\@1 kind Nil\n#2 input \"  1 bc b 1 b c = - c \"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"  b a 1 0 2 - 1 <\"\n\@0 kind Nil\n#1 input \"  b _ 2 a _ - b <\"\n\@1 kind Nil\n#2 input \"  1 bc b 1 b c = - c \"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000045" => {
    rakudo => { exit => 0, out => "#0 input \"a bb\"\n\@0 kind Match\n\@0 str \"a bb\"\n\@0 from 0\n\@0 to 4\n\@0 orig \"a bb\"\n\@0 target \"a bb\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0[0] kind Match\n\@0[0] str \"a \"\n\@0[0] from 0\n\@0[0] to 2\n\@0[0] orig \"a bb\"\n\@0[0] target \"a bb\"\n\@0[0] pre \"\"\n\@0[0] post \"bb\"\n\@0[0] made Nil\n\@0[0] caps \n\@0 caps 0=\"a \"\n#1 input \" c\"\n\@1 kind Nil\n#2 input \"a ccc\"\n\@2 kind Match\n\@2 str \"a ccc\"\n\@2 from 0\n\@2 to 5\n\@2 orig \"a ccc\"\n\@2 target \"a ccc\"\n\@2 pre \"\"\n\@2 post \"\"\n\@2 made Nil\n\@2[0] kind Match\n\@2[0] str \"a \"\n\@2[0] from 0\n\@2[0] to 2\n\@2[0] orig \"a ccc\"\n\@2[0] target \"a ccc\"\n\@2[0] pre \"\"\n\@2[0] post \"ccc\"\n\@2[0] made Nil\n\@2[0] caps \n\@2 caps 0=\"a \"\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"a bb\"\n\@0 kind Match\n\@0 str \"a bb\"\n\@0 from 0\n\@0 to 4\n\@0 orig \"a bb\"\n\@0 target \"a bb\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0[0] kind Match\n\@0[0] str \"a \"\n\@0[0] from 0\n\@0[0] to 2\n\@0[0] orig \"a bb\"\n\@0[0] target \"a bb\"\n\@0[0] pre \"\"\n\@0[0] post \"bb\"\n\@0[0] made Nil\n\@0[0] caps \n\@0 caps 0=\"a \"\n#1 input \" c\"\n\@1 kind Nil\n#2 input \"a ccc\"\n\@2 kind Match\n\@2 str \"a ccc\"\n\@2 from 0\n\@2 to 5\n\@2 orig \"a ccc\"\n\@2 target \"a ccc\"\n\@2 pre \"\"\n\@2 post \"\"\n\@2 made Nil\n\@2[0] kind Match\n\@2[0] str \"a \"\n\@2[0] from 0\n\@2[0] to 2\n\@2[0] orig \"a ccc\"\n\@2[0] target \"a ccc\"\n\@2[0] pre \"\"\n\@2[0] post \"ccc\"\n\@2[0] made Nil\n\@2[0] caps \n\@2 caps 0=\"a \"\n", err => "" },
  },
  "grammars-00000046" => {
    rakudo => { exit => 0, out => "#0 input \"b__b\"\n\@0 kind Match\n\@0 str \"b__b\"\n\@0 from 0\n\@0 to 4\n\@0 orig \"b__b\"\n\@0 target \"b__b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<k0> kind Match\n\@0<k0> str \"b__b\"\n\@0<k0> from 0\n\@0<k0> to 4\n\@0<k0> orig \"b__b\"\n\@0<k0> target \"b__b\"\n\@0<k0> pre \"\"\n\@0<k0> post \"\"\n\@0<k0> made Nil\n\@0<k0> caps \n\@0<r1> kind Match\n\@0<r1> str \"b__b\"\n\@0<r1> from 0\n\@0<r1> to 4\n\@0<r1> orig \"b__b\"\n\@0<r1> target \"b__b\"\n\@0<r1> pre \"\"\n\@0<r1> post \"\"\n\@0<r1> made Nil\n\@0<r1> caps \n\@0 caps k0=\"b__b\" r1=\"b__b\"\n#1 input \"ca\"\n\@1 kind Match\n\@1 str \"ca\"\n\@1 from 0\n\@1 to 2\n\@1 orig \"ca\"\n\@1 target \"ca\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1<k0> kind Match\n\@1<k0> str \"ca\"\n\@1<k0> from 0\n\@1<k0> to 2\n\@1<k0> orig \"ca\"\n\@1<k0> target \"ca\"\n\@1<k0> pre \"\"\n\@1<k0> post \"\"\n\@1<k0> made Nil\n\@1<k0> caps \n\@1<r1> kind Match\n\@1<r1> str \"ca\"\n\@1<r1> from 0\n\@1<r1> to 2\n\@1<r1> orig \"ca\"\n\@1<r1> target \"ca\"\n\@1<r1> pre \"\"\n\@1<r1> post \"\"\n\@1<r1> made Nil\n\@1<r1> caps \n\@1 caps k0=\"ca\" r1=\"ca\"\n#2 input \"a\"\n\@2 kind Match\n\@2 str \"a\"\n\@2 from 0\n\@2 to 1\n\@2 orig \"a\"\n\@2 target \"a\"\n\@2 pre \"\"\n\@2 post \"\"\n\@2 made Nil\n\@2<k0> kind Match\n\@2<k0> str \"a\"\n\@2<k0> from 0\n\@2<k0> to 1\n\@2<k0> orig \"a\"\n\@2<k0> target \"a\"\n\@2<k0> pre \"\"\n\@2<k0> post \"\"\n\@2<k0> made Nil\n\@2<k0> caps \n\@2<r1> kind Match\n\@2<r1> str \"a\"\n\@2<r1> from 0\n\@2<r1> to 1\n\@2<r1> orig \"a\"\n\@2<r1> target \"a\"\n\@2<r1> pre \"\"\n\@2<r1> post \"\"\n\@2<r1> made Nil\n\@2<r1> caps \n\@2 caps k0=\"a\" r1=\"a\"\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"b__b\"\n\@0 kind Match\n\@0 str \"b__b\"\n\@0 from 0\n\@0 to 4\n\@0 orig \"b__b\"\n\@0 target \"b__b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<k0> kind Match\n\@0<k0> str \"b__b\"\n\@0<k0> from 0\n\@0<k0> to 4\n\@0<k0> orig \"b__b\"\n\@0<k0> target \"b__b\"\n\@0<k0> pre \"\"\n\@0<k0> post \"\"\n\@0<k0> made Nil\n\@0<k0> caps \n\@0<r1> kind Match\n\@0<r1> str \"b__b\"\n\@0<r1> from 0\n\@0<r1> to 4\n\@0<r1> orig \"b__b\"\n\@0<r1> target \"b__b\"\n\@0<r1> pre \"\"\n\@0<r1> post \"\"\n\@0<r1> made Nil\n\@0<r1> caps \n\@0 caps k0=\"b__b\" r1=\"b__b\"\n#1 input \"ca\"\n\@1 kind Match\n\@1 str \"ca\"\n\@1 from 0\n\@1 to 2\n\@1 orig \"ca\"\n\@1 target \"ca\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1<k0> kind Match\n\@1<k0> str \"ca\"\n\@1<k0> from 0\n\@1<k0> to 2\n\@1<k0> orig \"ca\"\n\@1<k0> target \"ca\"\n\@1<k0> pre \"\"\n\@1<k0> post \"\"\n\@1<k0> made Nil\n\@1<k0> caps \n\@1<r1> kind Match\n\@1<r1> str \"ca\"\n\@1<r1> from 0\n\@1<r1> to 2\n\@1<r1> orig \"ca\"\n\@1<r1> target \"ca\"\n\@1<r1> pre \"\"\n\@1<r1> post \"\"\n\@1<r1> made Nil\n\@1<r1> caps \n\@1 caps k0=\"ca\" r1=\"ca\"\n#2 input \"a\"\n\@2 kind Match\n\@2 str \"a\"\n\@2 from 0\n\@2 to 1\n\@2 orig \"a\"\n\@2 target \"a\"\n\@2 pre \"\"\n\@2 post \"\"\n\@2 made Nil\n\@2<k0> kind Match\n\@2<k0> str \"a\"\n\@2<k0> from 0\n\@2<k0> to 1\n\@2<k0> orig \"a\"\n\@2<k0> target \"a\"\n\@2<k0> pre \"\"\n\@2<k0> post \"\"\n\@2<k0> made Nil\n\@2<k0> caps \n\@2<r1> kind Match\n\@2<r1> str \"a\"\n\@2<r1> from 0\n\@2<r1> to 1\n\@2<r1> orig \"a\"\n\@2<r1> target \"a\"\n\@2<r1> pre \"\"\n\@2<r1> post \"\"\n\@2<r1> made Nil\n\@2<r1> caps \n\@2 caps k0=\"a\" r1=\"a\"\n", err => "" },
  },
  "grammars-00000047" => {
    rakudo => { exit => 0, out => "#0 input \"a c c b 1<\"\n\@0 kind Nil\n#1 input \"b b845\"\n\@1 kind Nil\n#2 input \"c c\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"a c c b 1<\"\n\@0 kind Nil\n#1 input \"b b845\"\n\@1 kind Nil\n#2 input \"c c\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000048" => {
    rakudo => { exit => 0, out => "#0 input \"\"\n\@0 kind Nil\n#1 input \"2\"\n\@1 kind Match\n\@1 str \"2\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"2\"\n\@1 target \"2\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made \"TOP:2\"\n\@1<r0> kind List(0)\n\@1 caps \n#2 input \"4cb>aa1bcb4\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"\"\n\@0 kind Nil\n#1 input \"2\"\n\@1 kind Match\n\@1 str \"2\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"2\"\n\@1 target \"2\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made \"TOP:2\"\n\@1<r0> kind List(0)\n\@1 caps \n#2 input \"4cb>aa1bcb4\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000049" => {
    rakudo => { exit => 0, out => "#0 input \"c\"\n\@0 kind Match\n\@0 str \"c\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"c\"\n\@0 target \"c\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<k1> kind Match\n\@0<k1> str \"c\"\n\@0<k1> from 0\n\@0<k1> to 1\n\@0<k1> orig \"c\"\n\@0<k1> target \"c\"\n\@0<k1> pre \"\"\n\@0<k1> post \"\"\n\@0<k1> made Nil\n\@0<k1> caps \n\@0<r1> kind Match\n\@0<r1> str \"c\"\n\@0<r1> from 0\n\@0<r1> to 1\n\@0<r1> orig \"c\"\n\@0<r1> target \"c\"\n\@0<r1> pre \"\"\n\@0<r1> post \"\"\n\@0<r1> made Nil\n\@0<r1> caps \n\@0 caps k1=\"c\" r1=\"c\"\n#1 input \"=\"\n\@1 kind Match\n\@1 str \"=\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"=\"\n\@1 target \"=\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1 caps \n#2 input \",c\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"c\"\n\@0 kind Match\n\@0 str \"c\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"c\"\n\@0 target \"c\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<k1> kind Match\n\@0<k1> str \"c\"\n\@0<k1> from 0\n\@0<k1> to 1\n\@0<k1> orig \"c\"\n\@0<k1> target \"c\"\n\@0<k1> pre \"\"\n\@0<k1> post \"\"\n\@0<k1> made Nil\n\@0<k1> caps \n\@0<r1> kind Match\n\@0<r1> str \"c\"\n\@0<r1> from 0\n\@0<r1> to 1\n\@0<r1> orig \"c\"\n\@0<r1> target \"c\"\n\@0<r1> pre \"\"\n\@0<r1> post \"\"\n\@0<r1> made Nil\n\@0<r1> caps \n\@0 caps k1=\"c\" r1=\"c\"\n#1 input \"=\"\n\@1 kind Match\n\@1 str \"=\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"=\"\n\@1 target \"=\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1 caps \n#2 input \",c\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000050" => {
    rakudo => { exit => 0, out => "#0 input \"c\"\n\@0 kind Match\n\@0 str \"c\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"c\"\n\@0 target \"c\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<r2> kind Match\n\@0<r2> str \"c\"\n\@0<r2> from 0\n\@0<r2> to 1\n\@0<r2> orig \"c\"\n\@0<r2> target \"c\"\n\@0<r2> pre \"\"\n\@0<r2> post \"\"\n\@0<r2> made Nil\n\@0<r2><k0> kind Match\n\@0<r2><k0> str \"c\"\n\@0<r2><k0> from 0\n\@0<r2><k0> to 1\n\@0<r2><k0> orig \"c\"\n\@0<r2><k0> target \"c\"\n\@0<r2><k0> pre \"\"\n\@0<r2><k0> post \"\"\n\@0<r2><k0> made Nil\n\@0<r2><k0> caps \n\@0<r2> caps k0=\"c\"\n\@0 caps r2=\"c\"\n#1 input \"b\"\n\@1 kind Match\n\@1 str \"b\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"b\"\n\@1 target \"b\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1<r2> kind Match\n\@1<r2> str \"b\"\n\@1<r2> from 0\n\@1<r2> to 1\n\@1<r2> orig \"b\"\n\@1<r2> target \"b\"\n\@1<r2> pre \"\"\n\@1<r2> post \"\"\n\@1<r2> made Nil\n\@1<r2><k0> kind Match\n\@1<r2><k0> str \"b\"\n\@1<r2><k0> from 0\n\@1<r2><k0> to 1\n\@1<r2><k0> orig \"b\"\n\@1<r2><k0> target \"b\"\n\@1<r2><k0> pre \"\"\n\@1<r2><k0> post \"\"\n\@1<r2><k0> made Nil\n\@1<r2><k0> caps \n\@1<r2> caps k0=\"b\"\n\@1 caps r2=\"b\"\n#2 input \"(b\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"c\"\n\@0 kind Match\n\@0 str \"c\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"c\"\n\@0 target \"c\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<r2> kind Match\n\@0<r2> str \"c\"\n\@0<r2> from 0\n\@0<r2> to 1\n\@0<r2> orig \"c\"\n\@0<r2> target \"c\"\n\@0<r2> pre \"\"\n\@0<r2> post \"\"\n\@0<r2> made Nil\n\@0<r2><k0> kind Match\n\@0<r2><k0> str \"c\"\n\@0<r2><k0> from 0\n\@0<r2><k0> to 1\n\@0<r2><k0> orig \"c\"\n\@0<r2><k0> target \"c\"\n\@0<r2><k0> pre \"\"\n\@0<r2><k0> post \"\"\n\@0<r2><k0> made Nil\n\@0<r2><k0> caps \n\@0<r2> caps k0=\"c\"\n\@0 caps r2=\"c\"\n#1 input \"b\"\n\@1 kind Match\n\@1 str \"b\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"b\"\n\@1 target \"b\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1<r2> kind Match\n\@1<r2> str \"b\"\n\@1<r2> from 0\n\@1<r2> to 1\n\@1<r2> orig \"b\"\n\@1<r2> target \"b\"\n\@1<r2> pre \"\"\n\@1<r2> post \"\"\n\@1<r2> made Nil\n\@1<r2><k0> kind Match\n\@1<r2><k0> str \"b\"\n\@1<r2><k0> from 0\n\@1<r2><k0> to 1\n\@1<r2><k0> orig \"b\"\n\@1<r2><k0> target \"b\"\n\@1<r2><k0> pre \"\"\n\@1<r2><k0> post \"\"\n\@1<r2><k0> made Nil\n\@1<r2><k0> caps \n\@1<r2> caps k0=\"b\"\n\@1 caps r2=\"b\"\n#2 input \"(b\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00000051" => {
    rakudo => { exit => 0, out => "#0 input \"\"\n\@0 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"\"\n\@0 kind Nil\n", err => "" },
  },
  "grammars-00001002" => {
    rakudo => { exit => 0, out => "#0 input \"b\"\n\@0 kind Match\n\@0 str \"b\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"b\"\n\@0 target \"b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<r0> kind List(0)\n\@0 caps \n#1 input \")223bc>\"\n\@1 kind Match\n\@1 str \")223b\"\n\@1 from 0\n\@1 to 5\n\@1 orig \")223bc>\"\n\@1 target \")223bc>\"\n\@1 pre \"\"\n\@1 post \"c>\"\n\@1 made Nil\n\@1<r0> kind List(2)\n\@1<r0>.0 kind Match\n\@1<r0>.0 str \"3\"\n\@1<r0>.0 from 3\n\@1<r0>.0 to 4\n\@1<r0>.0 orig \")223bc>\"\n\@1<r0>.0 target \")223bc>\"\n\@1<r0>.0 pre \")22\"\n\@1<r0>.0 post \"bc>\"\n\@1<r0>.0 made Nil\n\@1<r0>.0 caps \n\@1<r0>.1 kind Match\n\@1<r0>.1 str \"b\"\n\@1<r0>.1 from 4\n\@1<r0>.1 to 5\n\@1<r0>.1 orig \")223bc>\"\n\@1<r0>.1 target \")223bc>\"\n\@1<r0>.1 pre \")223\"\n\@1<r0>.1 post \"c>\"\n\@1<r0>.1 made Nil\n\@1<r0>.1 caps \n\@1 caps r0=\"3\" r0=\"b\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"b\"\n\@0 kind Match\n\@0 str \"b\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"b\"\n\@0 target \"b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<r0> kind List(0)\n\@0<r1> kind List(0)\n\@0 caps \n#1 input \")223bc>\"\n\@1 kind Match\n\@1 str \")223b\"\n\@1 from 0\n\@1 to 5\n\@1 orig \")223bc>\"\n\@1 target \")223bc>\"\n\@1 pre \"\"\n\@1 post \"c>\"\n\@1 made Nil\n\@1<r0> kind List(2)\n\@1<r0>.0 kind Match\n\@1<r0>.0 str \"3\"\n\@1<r0>.0 from 3\n\@1<r0>.0 to 4\n\@1<r0>.0 orig \")223bc>\"\n\@1<r0>.0 target \")223bc>\"\n\@1<r0>.0 pre \")22\"\n\@1<r0>.0 post \"bc>\"\n\@1<r0>.0 made Nil\n\@1<r0>.0 caps \n\@1<r0>.1 kind Match\n\@1<r0>.1 str \"b\"\n\@1<r0>.1 from 4\n\@1<r0>.1 to 5\n\@1<r0>.1 orig \")223bc>\"\n\@1<r0>.1 target \")223bc>\"\n\@1<r0>.1 pre \")223\"\n\@1<r0>.1 post \"c>\"\n\@1<r0>.1 made Nil\n\@1<r0>.1 caps \n\@1<r1> kind List(0)\n\@1 caps r0=\"3\" r0=\"b\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00001011" => {
    rakudo => { exit => 0, out => "#0 input \"c_b\"\n\@0 kind Match\n\@0 str \"\"\n\@0 from 0\n\@0 to -3\n\@0 orig \"c_b\"\n\@0 target \"c_b\"\n\@0 pre \"\"\n\@0 post \"c_b\"\n\@0 made Nil\n\@0 caps \n#1 input \"b_2abb\"\n\@1 kind Match\n\@1 str \"\"\n\@1 from 0\n\@1 to -3\n\@1 orig \"b_2abb\"\n\@1 target \"b_2abb\"\n\@1 pre \"\"\n\@1 post \"abb\"\n\@1 made Nil\n\@1 caps \n#2 input \"1bb=ab\"\n\@2 kind Match\n\@2 str \"\"\n\@2 from 0\n\@2 to -3\n\@2 orig \"1bb=ab\"\n\@2 target \"1bb=ab\"\n\@2 pre \"\"\n\@2 post \"=ab\"\n\@2 made Nil\n\@2 caps \n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"c_b\"\n\@0 kind Nil\n#1 input \"b_2abb\"\n\@1 kind Nil\n#2 input \"1bb=ab\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00001029" => {
    rakudo => { exit => 0, out => "#0 input \"c1a\"\n\@0 kind Nil\n#1 input \"ab\"\n\@1 kind Match\n\@1 str \"ab\"\n\@1 from 0\n\@1 to 2\n\@1 orig \"ab\"\n\@1 target \"ab\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1[0] kind Match\n\@1[0] str \"a\"\n\@1[0] from 0\n\@1[0] to 1\n\@1[0] orig \"ab\"\n\@1[0] target \"ab\"\n\@1[0] pre \"\"\n\@1[0] post \"b\"\n\@1[0] made Nil\n\@1[0] caps \n\@1 caps 0=\"a\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"c1a\"\n\@0 kind Match\n\@0 str \"c\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"c1a\"\n\@0 target \"c1a\"\n\@0 pre \"\"\n\@0 post \"1a\"\n\@0 made Nil\n\@0[0] kind Match\n\@0[0] str \"\"\n\@0[0] from 0\n\@0[0] to 0\n\@0[0] orig \"c1a\"\n\@0[0] target \"c1a\"\n\@0[0] pre \"\"\n\@0[0] post \"c1a\"\n\@0[0] made Nil\n\@0[0] caps \n\@0 caps 0=\"\"\n#1 input \"ab\"\n\@1 kind Match\n\@1 str \"a\"\n\@1 from 0\n\@1 to 1\n\@1 orig \"ab\"\n\@1 target \"ab\"\n\@1 pre \"\"\n\@1 post \"b\"\n\@1 made Nil\n\@1[0] kind Match\n\@1[0] str \"\"\n\@1[0] from 0\n\@1[0] to 0\n\@1[0] orig \"ab\"\n\@1[0] target \"ab\"\n\@1[0] pre \"\"\n\@1[0] post \"ab\"\n\@1[0] made Nil\n\@1[0] caps \n\@1 caps 0=\"\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00001065" => {
    rakudo => { exit => 0, out => "#0 input \"a2\"\n\@0 kind Match\n\@0 str \"a2\"\n\@0 from 0\n\@0 to 2\n\@0 orig \"a2\"\n\@0 target \"a2\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made \"TOP:a2\"\n\@0 caps \n#1 input \"a4\"\n\@1 kind Match\n\@1 str \"a4\"\n\@1 from 0\n\@1 to 2\n\@1 orig \"a4\"\n\@1 target \"a4\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made \"TOP:a4\"\n\@1 caps \n#2 input \"5a\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"a2\"\n\@0 kind Match\n\@0 str \"a2\"\n\@0 from 0\n\@0 to 2\n\@0 orig \"a2\"\n\@0 target \"a2\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made \"TOP:a2\"\n\@0[0] kind Nil\n\@0 caps 0=\"\"\n#1 input \"a4\"\n\@1 kind Match\n\@1 str \"a4\"\n\@1 from 0\n\@1 to 2\n\@1 orig \"a4\"\n\@1 target \"a4\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made \"TOP:a4\"\n\@1[0] kind Nil\n\@1 caps 0=\"\"\n#2 input \"5a\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00001066" => {
    rakudo => { exit => 0, out => "#0 input \"a a a b a \"\n\@0 kind Match\n\@0 str \"a a a b a \"\n\@0 from 0\n\@0 to 10\n\@0 orig \"a a a b a \"\n\@0 target \"a a a b a \"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0<k0> kind Match\n\@0<k0> str \"b \"\n\@0<k0> from 6\n\@0<k0> to 8\n\@0<k0> orig \"a a a b a \"\n\@0<k0> target \"a a a b a \"\n\@0<k0> pre \"a a a \"\n\@0<k0> post \"a \"\n\@0<k0> made Nil\n\@0<k0> caps \n\@0<k1> kind List(3)\n\@0<k1>.0 kind Match\n\@0<k1>.0 str \"a \"\n\@0<k1>.0 from 0\n\@0<k1>.0 to 2\n\@0<k1>.0 orig \"a a a b a \"\n\@0<k1>.0 target \"a a a b a \"\n\@0<k1>.0 pre \"\"\n\@0<k1>.0 post \"a a b a \"\n\@0<k1>.0 made Nil\n\@0<k1>.0 caps \n\@0<k1>.1 kind Match\n\@0<k1>.1 str \"a \"\n\@0<k1>.1 from 2\n\@0<k1>.1 to 4\n\@0<k1>.1 orig \"a a a b a \"\n\@0<k1>.1 target \"a a a b a \"\n\@0<k1>.1 pre \"a \"\n\@0<k1>.1 post \"a b a \"\n\@0<k1>.1 made Nil\n\@0<k1>.1 caps \n\@0<k1>.2 kind Match\n\@0<k1>.2 str \"a \"\n\@0<k1>.2 from 8\n\@0<k1>.2 to 10\n\@0<k1>.2 orig \"a a a b a \"\n\@0<k1>.2 target \"a a a b a \"\n\@0<k1>.2 pre \"a a a b \"\n\@0<k1>.2 post \"\"\n\@0<k1>.2 made Nil\n\@0<k1>.2 caps \n\@0<r1> kind Match\n\@0<r1> str \"b \"\n\@0<r1> from 6\n\@0<r1> to 8\n\@0<r1> orig \"a a a b a \"\n\@0<r1> target \"a a a b a \"\n\@0<r1> pre \"a a a \"\n\@0<r1> post \"a \"\n\@0<r1> made Nil\n\@0<r1> caps \n\@0<r2> kind List(4)\n\@0<r2>.0 kind Match\n\@0<r2>.0 str \"a \"\n\@0<r2>.0 from 0\n\@0<r2>.0 to 2\n\@0<r2>.0 orig \"a a a b a \"\n\@0<r2>.0 target \"a a a b a \"\n\@0<r2>.0 pre \"\"\n\@0<r2>.0 post \"a a b a \"\n\@0<r2>.0 made Nil\n\@0<r2>.0 caps \n\@0<r2>.1 kind Match\n\@0<r2>.1 str \"a \"\n\@0<r2>.1 from 2\n\@0<r2>.1 to 4\n\@0<r2>.1 orig \"a a a b a \"\n\@0<r2>.1 target \"a a a b a \"\n\@0<r2>.1 pre \"a \"\n\@0<r2>.1 post \"a b a \"\n\@0<r2>.1 made Nil\n\@0<r2>.1 caps \n\@0<r2>.2 kind Match\n\@0<r2>.2 str \"a \"\n\@0<r2>.2 from 4\n\@0<r2>.2 to 6\n\@0<r2>.2 orig \"a a a b a \"\n\@0<r2>.2 target \"a a a b a \"\n\@0<r2>.2 pre \"a a \"\n\@0<r2>.2 post \"b a \"\n\@0<r2>.2 made Nil\n\@0<r2>.2 caps \n\@0<r2>.3 kind Match\n\@0<r2>.3 str \"a \"\n\@0<r2>.3 from 8\n\@0<r2>.3 to 10\n\@0<r2>.3 orig \"a a a b a \"\n\@0<r2>.3 target \"a a a b a \"\n\@0<r2>.3 pre \"a a a b \"\n\@0<r2>.3 post \"\"\n\@0<r2>.3 made Nil\n\@0<r2>.3 caps \n\@0 caps k1=\"a \" r2=\"a \" k1=\"a \" r2=\"a \" r2=\"a \" k0=\"b \" r1=\"b \" k1=\"a \" r2=\"a \"\n#1 input \"a a c a \"\n\@1 kind Match\n\@1 str \"a a c a \"\n\@1 from 0\n\@1 to 8\n\@1 orig \"a a c a \"\n\@1 target \"a a c a \"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1<k0> kind Match\n\@1<k0> str \"c \"\n\@1<k0> from 4\n\@1<k0> to 6\n\@1<k0> orig \"a a c a \"\n\@1<k0> target \"a a c a \"\n\@1<k0> pre \"a a \"\n\@1<k0> post \"a \"\n\@1<k0> made Nil\n\@1<k0> caps \n\@1<k1> kind List(2)\n\@1<k1>.0 kind Match\n\@1<k1>.0 str \"a \"\n\@1<k1>.0 from 0\n\@1<k1>.0 to 2\n\@1<k1>.0 orig \"a a c a \"\n\@1<k1>.0 target \"a a c a \"\n\@1<k1>.0 pre \"\"\n\@1<k1>.0 post \"a c a \"\n\@1<k1>.0 made Nil\n\@1<k1>.0 caps \n\@1<k1>.1 kind Match\n\@1<k1>.1 str \"a \"\n\@1<k1>.1 from 6\n\@1<k1>.1 to 8\n\@1<k1>.1 orig \"a a c a \"\n\@1<k1>.1 target \"a a c a \"\n\@1<k1>.1 pre \"a a c \"\n\@1<k1>.1 post \"\"\n\@1<k1>.1 made Nil\n\@1<k1>.1 caps \n\@1<r1> kind Match\n\@1<r1> str \"c \"\n\@1<r1> from 4\n\@1<r1> to 6\n\@1<r1> orig \"a a c a \"\n\@1<r1> target \"a a c a \"\n\@1<r1> pre \"a a \"\n\@1<r1> post \"a \"\n\@1<r1> made Nil\n\@1<r1> caps \n\@1<r2> kind List(3)\n\@1<r2>.0 kind Match\n\@1<r2>.0 str \"a \"\n\@1<r2>.0 from 0\n\@1<r2>.0 to 2\n\@1<r2>.0 orig \"a a c a \"\n\@1<r2>.0 target \"a a c a \"\n\@1<r2>.0 pre \"\"\n\@1<r2>.0 post \"a c a \"\n\@1<r2>.0 made Nil\n\@1<r2>.0 caps \n\@1<r2>.1 kind Match\n\@1<r2>.1 str \"a \"\n\@1<r2>.1 from 2\n\@1<r2>.1 to 4\n\@1<r2>.1 orig \"a a c a \"\n\@1<r2>.1 target \"a a c a \"\n\@1<r2>.1 pre \"a \"\n\@1<r2>.1 post \"c a \"\n\@1<r2>.1 made Nil\n\@1<r2>.1 caps \n\@1<r2>.2 kind Match\n\@1<r2>.2 str \"a \"\n\@1<r2>.2 from 6\n\@1<r2>.2 to 8\n\@1<r2>.2 orig \"a a c a \"\n\@1<r2>.2 target \"a a c a \"\n\@1<r2>.2 pre \"a a c \"\n\@1<r2>.2 post \"\"\n\@1<r2>.2 made Nil\n\@1<r2>.2 caps \n\@1 caps k1=\"a \" r2=\"a \" r2=\"a \" k0=\"c \" r1=\"c \" k1=\"a \" r2=\"a \"\n#2 input \"  c a \"\n\@2 kind Match\n\@2 str \"\"\n\@2 from 0\n\@2 to -3\n\@2 orig \"  c a \"\n\@2 target \"  c a \"\n\@2 pre \"\"\n\@2 post \" a \"\n\@2 made Nil\n\@2 caps \n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"a a a b a \"\n\@0 kind Match\n\@0 str \"a \"\n\@0 from 0\n\@0 to 2\n\@0 orig \"a a a b a \"\n\@0 target \"a a a b a \"\n\@0 pre \"\"\n\@0 post \"a a b a \"\n\@0 made Nil\n\@0<k1> kind List(0)\n\@0<r1> kind Match\n\@0<r1> str \"a \"\n\@0<r1> from 0\n\@0<r1> to 2\n\@0<r1> orig \"a a a b a \"\n\@0<r1> target \"a a a b a \"\n\@0<r1> pre \"\"\n\@0<r1> post \"a a b a \"\n\@0<r1> made Nil\n\@0<r1> caps \n\@0 caps r1=\"a \"\n#1 input \"a a c a \"\n\@1 kind Match\n\@1 str \"a \"\n\@1 from 0\n\@1 to 2\n\@1 orig \"a a c a \"\n\@1 target \"a a c a \"\n\@1 pre \"\"\n\@1 post \"a c a \"\n\@1 made Nil\n\@1<k1> kind List(0)\n\@1<r1> kind Match\n\@1<r1> str \"a \"\n\@1<r1> from 0\n\@1<r1> to 2\n\@1<r1> orig \"a a c a \"\n\@1<r1> target \"a a c a \"\n\@1<r1> pre \"\"\n\@1<r1> post \"a c a \"\n\@1<r1> made Nil\n\@1<r1> caps \n\@1 caps r1=\"a \"\n#2 input \"  c a \"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00001082" => {
    rakudo => { exit => 0, out => "#0 input \"0\"\n\@0 kind Match\n\@0 str \"0\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"0\"\n\@0 target \"0\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0[0] kind Match\n\@0[0] str \"0\"\n\@0[0] from 0\n\@0[0] to 1\n\@0[0] orig \"0\"\n\@0[0] target \"0\"\n\@0[0] pre \"\"\n\@0[0] post \"\"\n\@0[0] made Nil\n\@0[0][0] kind Match\n\@0[0][0] str \"0\"\n\@0[0][0] from 0\n\@0[0][0] to 1\n\@0[0][0] orig \"0\"\n\@0[0][0] target \"0\"\n\@0[0][0] pre \"\"\n\@0[0][0] post \"\"\n\@0[0][0] made Nil\n\@0[0][0]<k0> kind Match\n\@0[0][0]<k0> str \"0\"\n\@0[0][0]<k0> from 0\n\@0[0][0]<k0> to 1\n\@0[0][0]<k0> orig \"0\"\n\@0[0][0]<k0> target \"0\"\n\@0[0][0]<k0> pre \"\"\n\@0[0][0]<k0> post \"\"\n\@0[0][0]<k0> made Nil\n\@0[0][0]<k0> caps \n\@0[0][0]<k1> kind Match\n\@0[0][0]<k1> str \"0\"\n\@0[0][0]<k1> from 0\n\@0[0][0]<k1> to 1\n\@0[0][0]<k1> orig \"0\"\n\@0[0][0]<k1> target \"0\"\n\@0[0][0]<k1> pre \"\"\n\@0[0][0]<k1> post \"\"\n\@0[0][0]<k1> made Nil\n\@0[0][0]<k1><r0> kind Match\n\@0[0][0]<k1><r0> str \"0\"\n\@0[0][0]<k1><r0> from 0\n\@0[0][0]<k1><r0> to 1\n\@0[0][0]<k1><r0> orig \"0\"\n\@0[0][0]<k1><r0> target \"0\"\n\@0[0][0]<k1><r0> pre \"\"\n\@0[0][0]<k1><r0> post \"\"\n\@0[0][0]<k1><r0> made Nil\n\@0[0][0]<k1><r0> caps \n\@0[0][0]<k1> caps r0=\"0\"\n\@0[0][0] caps k0=\"0\" k1=\"0\"\n\@0[0] caps 0=\"0\"\n\@0 caps 0=\"0\"\n#1 input \"1_\"\n\@1 kind Match\n\@1 str \"_\"\n\@1 from 1\n\@1 to 2\n\@1 orig \"1_\"\n\@1 target \"1_\"\n\@1 pre \"1\"\n\@1 post \"\"\n\@1 made Nil\n\@1[0] kind Match\n\@1[0] str \"_\"\n\@1[0] from 1\n\@1[0] to 2\n\@1[0] orig \"1_\"\n\@1[0] target \"1_\"\n\@1[0] pre \"1\"\n\@1[0] post \"\"\n\@1[0] made Nil\n\@1[0][0] kind Match\n\@1[0][0] str \"_\"\n\@1[0][0] from 1\n\@1[0][0] to 2\n\@1[0][0] orig \"1_\"\n\@1[0][0] target \"1_\"\n\@1[0][0] pre \"1\"\n\@1[0][0] post \"\"\n\@1[0][0] made Nil\n\@1[0][0]<k0> kind Match\n\@1[0][0]<k0> str \"_\"\n\@1[0][0]<k0> from 1\n\@1[0][0]<k0> to 2\n\@1[0][0]<k0> orig \"1_\"\n\@1[0][0]<k0> target \"1_\"\n\@1[0][0]<k0> pre \"1\"\n\@1[0][0]<k0> post \"\"\n\@1[0][0]<k0> made Nil\n\@1[0][0]<k0> caps \n\@1[0][0]<k1> kind Match\n\@1[0][0]<k1> str \"_\"\n\@1[0][0]<k1> from 1\n\@1[0][0]<k1> to 2\n\@1[0][0]<k1> orig \"1_\"\n\@1[0][0]<k1> target \"1_\"\n\@1[0][0]<k1> pre \"1\"\n\@1[0][0]<k1> post \"\"\n\@1[0][0]<k1> made Nil\n\@1[0][0]<k1><r0> kind Match\n\@1[0][0]<k1><r0> str \"_\"\n\@1[0][0]<k1><r0> from 1\n\@1[0][0]<k1><r0> to 2\n\@1[0][0]<k1><r0> orig \"1_\"\n\@1[0][0]<k1><r0> target \"1_\"\n\@1[0][0]<k1><r0> pre \"1\"\n\@1[0][0]<k1><r0> post \"\"\n\@1[0][0]<k1><r0> made Nil\n\@1[0][0]<k1><r0> caps \n\@1[0][0]<k1> caps r0=\"_\"\n\@1[0][0] caps k0=\"_\" k1=\"_\"\n\@1[0] caps 0=\"_\"\n\@1 caps 0=\"_\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"0\"\n\@0 kind Match\n\@0 str \"0\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"0\"\n\@0 target \"0\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0[0] kind Match\n\@0[0] str \"0\"\n\@0[0] from 0\n\@0[0] to 1\n\@0[0] orig \"0\"\n\@0[0] target \"0\"\n\@0[0] pre \"\"\n\@0[0] post \"\"\n\@0[0] made Nil\n\@0[0][0] kind Match\n\@0[0][0] str \"0\"\n\@0[0][0] from 0\n\@0[0][0] to 1\n\@0[0][0] orig \"0\"\n\@0[0][0] target \"0\"\n\@0[0][0] pre \"\"\n\@0[0][0] post \"\"\n\@0[0][0] made Nil\n\@0[0][0]<k0> kind Match\n\@0[0][0]<k0> str \"0\"\n\@0[0][0]<k0> from 0\n\@0[0][0]<k0> to 1\n\@0[0][0]<k0> orig \"0\"\n\@0[0][0]<k0> target \"0\"\n\@0[0][0]<k0> pre \"\"\n\@0[0][0]<k0> post \"\"\n\@0[0][0]<k0> made Nil\n\@0[0][0]<k0><r0> kind Match\n\@0[0][0]<k0><r0> str \"0\"\n\@0[0][0]<k0><r0> from 0\n\@0[0][0]<k0><r0> to 1\n\@0[0][0]<k0><r0> orig \"0\"\n\@0[0][0]<k0><r0> target \"0\"\n\@0[0][0]<k0><r0> pre \"\"\n\@0[0][0]<k0><r0> post \"\"\n\@0[0][0]<k0><r0> made Nil\n\@0[0][0]<k0><r0> caps \n\@0[0][0]<k0> caps r0=\"0\"\n\@0[0][0]<k1> kind Match\n\@0[0][0]<k1> str \"0\"\n\@0[0][0]<k1> from 0\n\@0[0][0]<k1> to 1\n\@0[0][0]<k1> orig \"0\"\n\@0[0][0]<k1> target \"0\"\n\@0[0][0]<k1> pre \"\"\n\@0[0][0]<k1> post \"\"\n\@0[0][0]<k1> made Nil\n\@0[0][0]<k1><r0> kind Match\n\@0[0][0]<k1><r0> str \"0\"\n\@0[0][0]<k1><r0> from 0\n\@0[0][0]<k1><r0> to 1\n\@0[0][0]<k1><r0> orig \"0\"\n\@0[0][0]<k1><r0> target \"0\"\n\@0[0][0]<k1><r0> pre \"\"\n\@0[0][0]<k1><r0> post \"\"\n\@0[0][0]<k1><r0> made Nil\n\@0[0][0]<k1><r0> caps \n\@0[0][0]<k1> caps r0=\"0\"\n\@0[0][0] caps k0=\"0\" k1=\"0\"\n\@0[0] caps 0=\"0\"\n\@0 caps 0=\"0\"\n#1 input \"1_\"\n\@1 kind Match\n\@1 str \"_\"\n\@1 from 1\n\@1 to 2\n\@1 orig \"1_\"\n\@1 target \"1_\"\n\@1 pre \"1\"\n\@1 post \"\"\n\@1 made Nil\n\@1[0] kind Match\n\@1[0] str \"_\"\n\@1[0] from 1\n\@1[0] to 2\n\@1[0] orig \"1_\"\n\@1[0] target \"1_\"\n\@1[0] pre \"1\"\n\@1[0] post \"\"\n\@1[0] made Nil\n\@1[0][0] kind Match\n\@1[0][0] str \"_\"\n\@1[0][0] from 1\n\@1[0][0] to 2\n\@1[0][0] orig \"1_\"\n\@1[0][0] target \"1_\"\n\@1[0][0] pre \"1\"\n\@1[0][0] post \"\"\n\@1[0][0] made Nil\n\@1[0][0]<k0> kind Match\n\@1[0][0]<k0> str \"_\"\n\@1[0][0]<k0> from 1\n\@1[0][0]<k0> to 2\n\@1[0][0]<k0> orig \"1_\"\n\@1[0][0]<k0> target \"1_\"\n\@1[0][0]<k0> pre \"1\"\n\@1[0][0]<k0> post \"\"\n\@1[0][0]<k0> made Nil\n\@1[0][0]<k0><r0> kind Match\n\@1[0][0]<k0><r0> str \"_\"\n\@1[0][0]<k0><r0> from 1\n\@1[0][0]<k0><r0> to 2\n\@1[0][0]<k0><r0> orig \"1_\"\n\@1[0][0]<k0><r0> target \"1_\"\n\@1[0][0]<k0><r0> pre \"1\"\n\@1[0][0]<k0><r0> post \"\"\n\@1[0][0]<k0><r0> made Nil\n\@1[0][0]<k0><r0> caps \n\@1[0][0]<k0> caps r0=\"_\"\n\@1[0][0]<k1> kind Match\n\@1[0][0]<k1> str \"_\"\n\@1[0][0]<k1> from 1\n\@1[0][0]<k1> to 2\n\@1[0][0]<k1> orig \"1_\"\n\@1[0][0]<k1> target \"1_\"\n\@1[0][0]<k1> pre \"1\"\n\@1[0][0]<k1> post \"\"\n\@1[0][0]<k1> made Nil\n\@1[0][0]<k1><r0> kind Match\n\@1[0][0]<k1><r0> str \"_\"\n\@1[0][0]<k1><r0> from 1\n\@1[0][0]<k1><r0> to 2\n\@1[0][0]<k1><r0> orig \"1_\"\n\@1[0][0]<k1><r0> target \"1_\"\n\@1[0][0]<k1><r0> pre \"1\"\n\@1[0][0]<k1><r0> post \"\"\n\@1[0][0]<k1><r0> made Nil\n\@1[0][0]<k1><r0> caps \n\@1[0][0]<k1> caps r0=\"_\"\n\@1[0][0] caps k0=\"_\" k1=\"_\"\n\@1[0] caps 0=\"_\"\n\@1 caps 0=\"_\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
  },
  "grammars-00001135" => {
    rakudo => { exit => 0, out => "#0 input \"b\"\n\@0 kind Match\n\@0 str \"b\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"b\"\n\@0 target \"b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0[0] kind Match\n\@0[0] str \"\"\n\@0[0] from 0\n\@0[0] to 0\n\@0[0] orig \"b\"\n\@0[0] target \"b\"\n\@0[0] pre \"\"\n\@0[0] post \"b\"\n\@0[0] made Nil\n\@0[0] caps \n\@0 caps 0=\"\"\n#1 input \"67b\"\n\@1 kind Match\n\@1 str \"b\"\n\@1 from 2\n\@1 to 3\n\@1 orig \"67b\"\n\@1 target \"67b\"\n\@1 pre \"67\"\n\@1 post \"\"\n\@1 made Nil\n\@1[0] kind Match\n\@1[0] str \"\"\n\@1[0] from 2\n\@1[0] to 2\n\@1[0] orig \"67b\"\n\@1[0] target \"67b\"\n\@1[0] pre \"67\"\n\@1[0] post \"b\"\n\@1[0] made Nil\n\@1[0] caps \n\@1 caps 0=\"\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
    rakupp => { exit => 0, out => "#0 input \"b\"\n\@0 kind Match\n\@0 str \"b\"\n\@0 from 0\n\@0 to 1\n\@0 orig \"b\"\n\@0 target \"b\"\n\@0 pre \"\"\n\@0 post \"\"\n\@0 made Nil\n\@0[0] kind Match\n\@0[0] str \"\"\n\@0[0] from 0\n\@0[0] to 0\n\@0[0] orig \"b\"\n\@0[0] target \"b\"\n\@0[0] pre \"\"\n\@0[0] post \"b\"\n\@0[0] made Nil\n\@0[0] caps \n\@0 caps 0=\"\"\n#1 input \"67b\"\n\@1 kind Match\n\@1 str \"67b\"\n\@1 from 0\n\@1 to 3\n\@1 orig \"67b\"\n\@1 target \"67b\"\n\@1 pre \"\"\n\@1 post \"\"\n\@1 made Nil\n\@1[0] kind Match\n\@1[0] str \"67\"\n\@1[0] from 0\n\@1[0] to 2\n\@1[0] orig \"67b\"\n\@1[0] target \"67b\"\n\@1[0] pre \"\"\n\@1[0] post \"b\"\n\@1[0] made Nil\n\@1[0] caps \n\@1 caps 0=\"67\"\n#2 input \"\"\n\@2 kind Nil\n", err => "" },
  },
  "unicode-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, Bool::True, Bool::False)\nSTR\t0 True False\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(0, Bool::True, Bool::False)\nSTR\t0 True False\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"👩‍💻\", (128105, 8205, 128187).Seq)\nSTR\t👩‍💻 128105 8205 128187\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"👩‍💻\", (128105, 8205, 128187).Seq)\nSTR\t👩‍💻 128105 8205 128187\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 7)\nSTR\t7 7\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 7)\nSTR\t7 7\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tSeq\nRAKU\t\$(((\"S\", (83,).Seq), (\"t\", (116,).Seq), (\"r\", (114,).Seq), (\"a\", (97,).Seq), (\"ß\", (223,).Seq), (\"e\", (101,).Seq)).Seq)\nSTR\tS 83 t 116 r 114 a 97 ß 223 e 101\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tSeq\nRAKU\t\$(((\"S\", (83,).Seq), (\"t\", (116,).Seq), (\"r\", (114,).Seq), (\"a\", (97,).Seq), (\"ß\", (223,).Seq), (\"e\", (101,).Seq)).Seq)\nSTR\tS 83 t 116 r 114 a 97 ß 223 e 101\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"é\", [233])\nSTR\té 233\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"é\", [233])\nSTR\té 233\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$((195, 169), \"é\")\nSTR\t195 169 é\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$((195, 169), \"é\")\nSTR\t195 169 é\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"東京\", (26481, 20140).Seq)\nSTR\t東京 26481 20140\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"東京\", (26481, 20140).Seq)\nSTR\t東京 26481 20140\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"ÅNGSTRöM\"\nSTR\tÅNGSTRöM\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"ÅNGSTRöM\"\nSTR\tÅNGSTRöM\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tSeq\nRAKU\t\$((\"न\", \"म\", \"स्ते\").Seq)\nSTR\tन म स्ते\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tSeq\nRAKU\t\$((\"न\", \"म\", \"स्ते\").Seq)\nSTR\tन म स्ते\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, (128105, 8205, 128187).Seq)\nSTR\t3 128105 8205 128187\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(3, (128105, 8205, 128187).Seq)\nSTR\t3 128105 8205 128187\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Σίσυφος\", (931, 943, 963, 965, 966, 959, 962).Seq)\nSTR\tΣίσυφος 931 943 963 965 966 959 962\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Σίσυφος\", (931, 943, 963, 965, 966, 959, 962).Seq)\nSTR\tΣίσυφος 931 943 963 965 966 959 962\nBOOL\tTrue\n", err => "" },
  },
  "unicode-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Straße\", [83, 116, 114, 97, 223, 101])\nSTR\tStraße 83 116 114 97 223 101\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Straße\", [83, 116, 114, 97, 223, 101])\nSTR\tStraße 83 116 114 97 223 101\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 7.0, 7e0, Bool::True)\nSTR\t7 7 7 True\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 7.0, 7e0, Bool::True)\nSTR\t7 7 7 True\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[4, 16, 36]\nSTR\t4 16 36\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[4, 16, 36]\nSTR\t4 16 36\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(5, -1, 5e0, 1e0)\nSTR\t5 -1 5 1\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(5, -1, 5e0, 1e0)\nSTR\t5 -1 5 1\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$([4, 2, 3], [4, 2])\nSTR\t4 2 3 4 2\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$([4, 2, 3], [4, 2])\nSTR\t4 2 3 4 2\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(2, 13, \"2..13\")\nSTR\t2 13 2..13\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(2, 13, \"2..13\")\nSTR\t2 13 2..13\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[[\"a\", 2], [\"b\", 3], [\"c\", 13]]\nSTR\ta 2 b 3 c 13\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[[\"a\", 2], [\"b\", 3], [\"c\", 13]]\nSTR\ta 2 b 3 c 13\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"gamma|beta|alpha\"\nSTR\tgamma|beta|alpha\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"gamma|beta|alpha\"\nSTR\tgamma|beta|alpha\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"0008:2.67\"\nSTR\t0008:2.67\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"0008:2.67\"\nSTR\t0008:2.67\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$([2, 7, 8, 13], [13, 8, 7, 2])\nSTR\t2 7 8 13 13 8 7 2\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$([2, 7, 8, 13], [13, 8, 7, 2])\nSTR\t2 7 8 13 13 8 7 2\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 8, 8, 7)\nSTR\t7 8 8 7\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 8, 8, 7)\nSTR\t7 8 8 7\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[[1, 2, 3], [4, 5, 6], [7, 8]]\nSTR\t1 2 3 4 5 6 7 8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[[1, 2, 3], [4, 5, 6], [7, 8]]\nSTR\t1 2 3 4 5 6 7 8\nBOOL\tTrue\n", err => "" },
  },
  "builtins-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(6, 6, [82, 97, 107, 117, 32, 129419], \"🦋 ukaR\")\nSTR\t6 6 82 97 107 117 32 129419 🦋 ukaR\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(6, 6, [82, 97, 107, 117, 32, 129419], \"🦋 ukaR\")\nSTR\t6 6 82 97 107 117 32 129419 🦋 ukaR\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, 2, 3, \"last\"]\nSTR\t1 2 3 last\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, 2, 3, \"last\"]\nSTR\t1 2 3 last\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"body\", \"leave\"]\nSTR\tbody leave\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"body\", \"leave\"]\nSTR\tbody leave\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"undo\"]\nSTR\tundo\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"undo\"]\nSTR\tundo\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000044" => {
    rakudo => { exit => 0, out => "PHASE\tinit-3\nTYPE\tStr\nRAKU\t\"runtime\"\nSTR\truntime\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "PHASE\tinit-3\nTYPE\tStr\nRAKU\t\"runtime\"\nSTR\truntime\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, \"next\", 2, \"next\", 3, \"next\"]\nSTR\t1 next 2 next 3 next\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[1, \"next\", 2, \"next\", 3, \"next\"]\nSTR\t1 next 2 next 3 next\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"enter\", \"body\"]\nSTR\tenter body\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"enter\", \"body\"]\nSTR\tenter body\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"X::AdHoc\"]\nSTR\tX::AdHoc\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"X::AdHoc\"]\nSTR\tX::AdHoc\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"body\", \"keep\"]\nSTR\tbody keep\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"body\", \"keep\"]\nSTR\tbody keep\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000049" => {
    rakudo => { exit => 0, out => "PHASE\tcheck-6\nTYPE\tStr\nRAKU\t\"runtime\"\nSTR\truntime\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "PHASE\tcheck-6\nTYPE\tStr\nRAKU\t\"runtime\"\nSTR\truntime\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"first\", 1, 2, 3]\nSTR\tfirst 1 2 3\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[\"first\", 1, 2, 3]\nSTR\tfirst 1 2 3\nBOOL\tTrue\n", err => "" },
  },
  "phasers-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tStr\nRAKU\t\"runtime\"\nSTR\truntime\nBOOL\tTrue\nPHASE\tend-4\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tStr\nRAKU\t\"runtime\"\nSTR\truntime\nBOOL\tTrue\nPHASE\tend-4\n", err => "" },
  },
  "concurrency-00000040" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 8, 13)\nSTR\t7 8 13\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 8, 13)\nSTR\t7 8 13\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000041" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000042" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t10\nSTR\t10\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000043" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t6\nSTR\t6\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000044" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Kept\", 3)\nSTR\tKept 3\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Kept\", 3)\nSTR\tKept 3\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000045" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t8\nSTR\t8\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000046" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t27\nSTR\t27\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t27\nSTR\t27\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000047" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[8, 9]\nSTR\t8 9\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[8, 9]\nSTR\t8 9\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000048" => {
    rakudo => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[7]\nSTR\t7\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tArray\nRAKU\t\$[7]\nSTR\t7\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000049" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 8)\nSTR\t7 8\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(7, 8)\nSTR\t7 8\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000050" => {
    rakudo => { exit => 0, out => "TYPE\tInt\nRAKU\t4\nSTR\t4\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tInt\nRAKU\t4\nSTR\t4\nBOOL\tTrue\n", err => "" },
  },
  "concurrency-00000051" => {
    rakudo => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Broken\", Bool::False)\nSTR\tBroken False\nBOOL\tTrue\n", err => "" },
    rakupp => { exit => 0, out => "TYPE\tList\nRAKU\t\$(\"Broken\", Bool::False)\nSTR\tBroken False\nBOOL\tTrue\n", err => "" },
  },
  "invalid-00000040" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000040.raku\nTwo terms in a row\nat invalid-00000040.raku:1\n------> my \$value = 1<HERE> 2;\n    expecting any of:\n        infix\n        infix stopper\n        postfix\n        statement end\n        statement modifier\n        statement modifier loop\n" },
    rakupp => { exit => 0, out => "", err => "Useless use of constant integer 2 in sink context (line 1)\n" },
  },
  "invalid-00000041" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000041.raku\nRadix 1 out of range (allowed: 2..36)\nat invalid-00000041.raku:1\n------> my \$value = :1<2><HERE>;\n" },
    rakupp => { exit => 1, out => "", err => "===SORRY!=== Parse error at line 1: Radix 1 out of range (allowed: 2..36)\n      1 | my \$value = :1<2>;\n" },
  },
  "invalid-00000042" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000042.raku\nUnable to parse expression in parenthesized expression; couldn't find final ')' (corresponding starter was at line 1)\nat invalid-00000042.raku:2\n------> <BOL><HERE><EOL>\n" },
    rakupp => { exit => 1, out => "", err => "===SORRY!=== Parse error at line 2: Confused (got '')\n" },
  },
  "invalid-00000043" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000043.raku\nCan't use unknown trait 'is' -> 'definitely-not-a-trait' in sub declaration.\nat invalid-00000043.raku:1\n    expecting any of:\n        rw raw default DEPRECATED inlinable onlystar export leading_docs\n        trailing_docs revision-gated implementation-detail hidden-from-backtrace\n        hidden-from-USAGE pure nodal equiv tighter looser assoc prec\n" },
    rakupp => { exit => 0, out => "", err => "" },
  },
  "invalid-00000044" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000044.raku\nMissing block\nat invalid-00000044.raku:2\n------> <BOL><HERE><EOL>\n" },
    rakupp => { exit => 1, out => "", err => "===SORRY!=== Parse error at line 2: expected } (got '')\n" },
  },
  "invalid-00000045" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000045.raku\nMissing block\nat invalid-00000045.raku:1\n------> class C \{ method<HERE> 42() \{ } }\n" },
    rakupp => { exit => 0, out => "", err => "" },
  },
  "invalid-00000046" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000046.raku\nMalformed my\nat invalid-00000046.raku:1\n------> my<HERE> ?value = 1;\n" },
    rakupp => { exit => 1, out => "", err => "===SORRY!=== Parse error at line 1: expected variable after declarator (got '?')\n      1 | my ?value = 1;\n" },
  },
  "invalid-00000047" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000047.raku\nUndeclared routine:\n    else used at line 1\n\n" },
    rakupp => { exit => 1, out => "", err => "Undefined routine 'else'\n  in block <unit> at invalid-00000047.raku line 1\n      1 | else \{ say 1 }\n" },
  },
  "invalid-00000048" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000048.raku\nMalformed initializer\nat invalid-00000048.raku:1\n------> my \$value = :<HERE>;\n    expecting any of:\n        colon pair\n" },
    rakupp => { exit => 0, out => "", err => "" },
  },
  "invalid-00000049" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000049.raku\nUnable to parse expression in double quotes; couldn't find final '\"' (corresponding starter was at line 1)\nat invalid-00000049.raku:2\n------> <BOL><HERE><EOL>\n    expecting any of:\n        double quotes\n        term\n" },
    rakupp => { exit => 1, out => "", err => "===SORRY!=== Parse error at line 2: Unable to parse expression in double quotes; couldn't find final '\"' (corresponding starter was at line 1)\n" },
  },
  "invalid-00000050" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!===\nNull regex not allowed. Please use .comb if you wanted to produce a\nsequence of characters from a string.\nat invalid-00000050.raku:1\n------> my \$value = rx/ [ <HERE>/;\nUnable to parse expression in metachar:sym<[ ]>; couldn't find final ']' (corresponding starter was at line 1)\nat invalid-00000050.raku:1\n------> my \$value = rx/ [ <HERE>/;\n    expecting any of:\n        infix stopper\n\n" },
    rakupp => { exit => 1, out => "", err => "===SORRY!=== Parse error at line 2: Couldn't find terminator / (corresponding / was at line 1)\n" },
  },
  "invalid-00000051" => {
    rakudo => { exit => 1, out => "", err => "===SORRY!=== Error while compiling invalid-00000051.raku\nRedeclaration of symbol '\$x'.\nat invalid-00000051.raku:1\n------> sub f(\$x, \$x<HERE>) \{ };\n    expecting any of:\n        shape declaration\n" },
    rakupp => { exit => 0, out => "", err => "" },
  },
  },
}
