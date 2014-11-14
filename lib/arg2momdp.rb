require "arg2momdp/version"

module Arg2MOMDP
  autoload :Lexer,       "arg2momdp/lexer"
  autoload :Parser,      "arg2momdp/parser"
  autoload :Alternative, "arg2momdp/objects/alternative"
  autoload :Modifier,    "arg2momdp/objects/modifier"
  autoload :Predicate,   "arg2momdp/objects/predicate"
  autoload :Rule,        "arg2momdp/objects/rule"
end
