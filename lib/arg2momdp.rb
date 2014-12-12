require "arg2momdp/version"

module Arg2MOMDP
  autoload :Lexer,       "arg2momdp/lexer"
  autoload :Parser,      "arg2momdp/parser"
  autoload :Alternative, "arg2momdp/objects/alternative"
  autoload :Modifier,    "arg2momdp/objects/modifier"
  autoload :Predicate,   "arg2momdp/objects/predicate"
  autoload :Rule,        "arg2momdp/objects/rule"
  autoload :POMDP,       "arg2momdp/objects/pomdp"
  autoload :Agent,       "arg2momdp/objects/agent"
  autoload :Opponent,    "arg2momdp/objects/opponent"
  autoload :PublicSpace, "arg2momdp/objects/public_space"
  autoload :Optimizer,   "arg2momdp/objects/optimizer"

  module POMDPX
    autoload :XMLBuilder,          "arg2momdp/pomdpx/xmlbuilder"
    autoload :Helpers,             "arg2momdp/pomdpx/xmlhelpers"
    autoload :VariableBuilder,     "arg2momdp/pomdpx/variablebuilder"
    autoload :InitialStateBuilder, "arg2momdp/pomdpx/initialstatebuilder"
    autoload :TransitionBuilder,   "arg2momdp/pomdpx/transitionbuilder"
    autoload :RewardBuilder,       "arg2momdp/pomdpx/rewardbuilder"
  end
end
