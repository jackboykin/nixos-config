let
  kinds = map (kind: {inherit kind;});
  atoms = [
    "variable_expression"
    "integer_expression"
    "float_expression"
    "string_expression"
    "indented_string_expression"
    "list_expression"
    "attrset_expression"
    "rec_attrset_expression"
    "parenthesized_expression"
  ];

  named = var: {
    kind = "identifier";
    pattern = var;
  };
  variable = var: {
    kind = "variable_expression";
    has = named var;
  };
  solo = var: {
    field = "attrpath";
    has = named var;
    not.has.nthChild = 2;
  };
  keyed = var: {
    kind = "binding";
    has = {
      field = "attrpath";
      has = named var // {nthChild = 1;};
    };
  };
  read = var: {
    any = [
      (variable var)
      {
        kind = "inherit";
        has = {
          kind = "inherited_attrs";
          has = named var;
        };
      }
    ];
  };
  reads = var: read var // {stopBy = "end";};
  up = path: top:
    if path == []
    then {inside = top;}
    else {inside = {kind = builtins.head path;} // up (builtins.tail path) top;};

  rules = {
    wrap = let
      past = indent: let
        indented.regex = "^[^\\n]*\\n {${toString indent}}\\S";
      in {
        regex = "^[^\\n]{${toString (101 - indent)}}";
        any = [
          {
            inside = {
              kind = "binding_set";
              inside = indented;
            };
          }
          {inside = indented // {kind = "list_expression";};}
        ];
      };
      long.any =
        [{regex = "^[^\\n]{101}";}]
        ++ map past (builtins.genList (level: 2 * level + 2) 20);
      longBinding.inside = long // {kind = "binding";};

      repeat = n: s: builtins.concatStringsSep "" (builtins.genList (_: s) n);
      sample = indent: width: let
        nest = at: body:
          if at == indent
          then body
          else "${repeat at " "}a = {\n${nest (at + 2) body}${repeat at " "}};\n";
      in "{\n${nest 2 "${repeat indent " "}k = [${repeat (width - indent - 9) "a"} b];\n"}}";
    in {
      message = "this line runs past 100 columns: open the bracket";
      rule.all = [
        {pattern = "$NODE";}
        {
          any = [
            {
              kind = "parenthesized_expression";
              not.has = {
                field = "expression";
                any = kinds (atoms ++ ["unary_expression"]);
              };
            }
            {kind = "attrset_expression";}
            {kind = "list_expression";}
          ];
        }
        {regex = "^[^\\n]*$";}
        {not.regex = "^.\\s*.$";}
        {
          any = [
            longBinding
            {
              inside = {
                kind = "apply_expression";
                field = "argument";
                any = [
                  long
                  longBinding
                  {inside = long // {kind = "parenthesized_expression";};}
                ];
              };
            }
          ];
        }
      ];
      transform.OPEN.replace = {
        source = "$NODE";
        replace = "^(.)(.*)(.)$";
        by = "$1\n$2\n$3";
      };
      fix = "$OPEN";
      valid = [
        (sample 2 100)
        (sample 8 100)
        "{\n  short = f (g x);\n}"
        "{\n  k = ${repeat 100 "a"} (!b);\n}"
        "{\n  k = ${repeat 100 "a"} [];\n}"
        "''\n  \${f (g ${repeat 94 "a"})}\n''"
      ];
      invalid = [
        (sample 2 101)
        (sample 8 101)
        "{\n  wrapperArgs = lib.functionArgs (import \"\${final.path}/pkgs/applications/networking/browsers/firefox/wrapper.nix\");\n}"
        "[\n  (rust-bin.stable.latest.minimal.override {extensions = [\"clippy\" \"rustfmt\" \"rust-analyzer\" \"rust-src\"];})\n]"
        "''\n  \${f (g ${repeat 95 "a"})}\n''"
      ];
    };

    comment = {
      message = "a comment marks a workaround: `<link>; drop once <condition>`";
      rule = {
        kind = "comment";
        not.regex = "drop once";
      };
      valid = ["# example.org/pull/1; drop once merged\n1"];
      invalid = ["# adds one\nx + 1"];
    };

    block = let
      earlier = keyed "$KEY" // {stopBy = "end";};
    in {
      message = "three `$KEY.…` bindings make a `$KEY = {…}` block";
      rule = keyed "$KEY" // {follows = earlier // {follows = earlier;};};
      valid = ["{ a.b = 1; c = 2; a.d = 3; }"];
      invalid = ["{ a.b = 1; a.c = 2; d = 3; a.e = 4; }"];
    };

    scope = {
      message = "`with` scopes a list and nothing wider";
      rule = {
        kind = "with_expression";
        not.has = {
          field = "body";
          kind = "list_expression";
        };
      };
      valid = ["with pkgs; [hello]"];
      invalid = ["with lib; mkIf true { }"];
    };

    prev = let
      from = kind: {
        inherit kind;
        has = {
          field = "expression";
          kind = "variable_expression";
          regex = "^prev$";
        };
      };
    in {
      message = "`prev` gives `lib` and the attribute being redefined: take `$ATTR` from `final`";
      rule.all = [
        (named "$ATTR")
        {not.regex = "^lib$";}
        {
          any = [
            (up ["attrpath"] (from "select_expression") // {nthChild = 1;})
            (up ["inherited_attrs"] (from "inherit_from"))
          ];
        }
        {not.inside = keyed "$ATTR" // {stopBy = "end";};}
      ];
      valid = [
        "final: prev: { mesa = prev.mesa.overrideAttrs { }; }"
        "final: prev: let inherit (prev) lib; in { a = prev.lib.id final.b; }"
      ];
      invalid = [
        "final: prev: { mesa = prev.llvm; }"
        "final: prev: let inherit (prev) stdenv; in { }"
      ];
    };

    inherit-same = {
      message = "write `inherit $NAME;`";
      rule = {
        kind = "binding";
        all = [
          {has = solo "$NAME";}
          {has = variable "$NAME" // {field = "expression";};}
        ];
      };
      fix = "inherit $NAME;";
      valid = ["{ a = b; a.b = a; }"];
      invalid = ["{ a = a; }"];
    };

    inherit-from = {
      message = "write `inherit ($FROM) $NAME;`";
      rule = {
        kind = "binding";
        all = [
          {has = solo "$NAME";}
          {
            has = {
              field = "expression";
              kind = "select_expression";
              all = [
                {
                  has = {
                    field = "expression";
                    kind = "variable_expression";
                    pattern = "$FROM";
                  };
                }
                {has = solo "$NAME";}
                {
                  not.has = {
                    field = "default";
                    pattern = "$DEFAULT";
                  };
                }
              ];
            };
          }
        ];
      };
      fix = "inherit ($FROM) $NAME;";
      valid = ["{ a = b.c; a = b.a or 1; a = b.c.a; a = (f b).a; a.b = c.a.b; }"];
      invalid = ["{ a = b.a; }"];
    };

    ignore = {
      message = "an argument set that names nothing is `_`";
      rule = {
        kind = "formals";
        has.kind = "ellipses";
        not.has.kind = "formal";
        inside = {
          kind = "function_expression";
          not.has = {
            field = "universal";
            kind = "identifier";
          };
        };
      };
      fix = "_";
      valid = ["{ pkgs, ... }: pkgs" "args @ { ... }: args" "{ }: 1"];
      invalid = ["{ ... }: 1"];
    };

    parens = {
      message = "these parentheses group nothing";
      rule = {
        kind = "parenthesized_expression";
        has = {
          field = "expression";
          pattern = "$INNER";
        };
        not.has.kind = "comment";
        any = [
          {
            has = {
              field = "expression";
              any = kinds atoms;
            };
          }
          {
            inside.any = kinds [
              "binding"
              "let_expression"
              "if_expression"
              "with_expression"
              "assert_expression"
              "interpolation"
            ];
          }
          {
            inside = {
              kind = "function_expression";
              field = "body";
            };
          }
        ];
      };
      fix = "$INNER";
      valid = [
        "{ a = (f x).y; b = f (g x); c = [(f x)]; d = (x: x) 1; }"
        "{ a = (\n  # example.org/pull/1; drop once merged\n  f x\n); }"
      ];
      invalid = [
        "{ a = (f x); }"
        "f (x)"
        "x: (x + 1)"
        "if (a == b) then 1 else 2"
      ];
    };

    eta = {
      message = "`$ARG: $FN $ARG` is `$FN`";
      rule = {
        pattern = "$ARG: $FN $ARG";
        not.has = {
          field = "body";
          has = {
            field = "function";
            any = [
              (read "$ARG")
              {has = reads "$ARG";}
            ];
          };
        };
      };
      valid = ["x: f x x" "x: f (g x)" "x: x x" "x: x.f x"];
      invalid = ["x: f x" "map (x: lib.id x)"];
    };

    default = {
      message = "`$SET.$ATTR or …` needs no `if`";
      rule.pattern = "if $SET ? $ATTR then $SET.$ATTR else $ELSE";
      valid = ["if a ? b then a.c else 1"];
      invalid = ["if a ? b then a.b else 1"];
    };

    unused = let
      unread = kind: {
        inherit kind;
        not.has = reads "$NAME";
      };
      inLet = unread "let_expression";
      inLambda = unread "function_expression";
    in {
      message = "`$NAME` is bound and never read";
      rule.all = [
        (named "$NAME")
        {not.regex = "^_";}
        {
          any = [
            (up ["attrpath" "binding" "binding_set"] inLet // {nthChild = 1;})
            (up ["inherited_attrs" "inherit_from" "binding_set"] inLet)
            (up ["formal" "formals"] inLambda)
            {inside = inLambda // {field = "universal";};}
          ];
        }
      ];
      valid = [
        "let a = 1; in a"
        "let a = 1; in { inherit a; }"
        "let inherit (a) b; in \"\${b}\""
        "{ a, b ? a, ... }: b"
        "a: _: a"
        "args @ { a, ... }: a args"
      ];
      invalid = [
        "let a = 1; in 2"
        "let a.b = 1; in 2"
        "let inherit (a) b; in a"
        "{ a, b, ... }: a"
        "a: b: a"
        "args @ { a, ... }: a"
      ];
    };
  };

  documents = document: builtins.attrValues (builtins.mapAttrs document rules);
in {
  rules = documents (
    id: rule:
      {
        inherit id;
        language = "nix";
        severity = "error";
      }
      // removeAttrs rule ["valid" "invalid"]
  );
  tests = documents (id: rule: {
    inherit id;
    inherit (rule) valid invalid;
  });
}
