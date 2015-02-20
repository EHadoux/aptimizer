require "aptimizer/version"

module Aptimizer
  autoload :Lexer,       "aptimizer/lexer"
  autoload :Parser,      "aptimizer/parser"
  autoload :Alternative, "aptimizer/objects/alternative"
  autoload :Modifier,    "aptimizer/objects/modifier"
  autoload :Predicate,   "aptimizer/objects/predicate"
  autoload :Rule,        "aptimizer/objects/rule"
  autoload :APS,         "aptimizer/objects/APS"
  autoload :Agent,       "aptimizer/objects/agent"
  autoload :Opponent,    "aptimizer/objects/opponent"
  autoload :PublicSpace, "aptimizer/objects/public_space"
  autoload :Optimizer,   "aptimizer/objects/optimizer"

  module POMDPX
    autoload :XMLBuilder,          "aptimizer/pomdpx/xmlbuilder"
    autoload :Helpers,             "aptimizer/pomdpx/xmlhelpers"
    autoload :VariableBuilder,     "aptimizer/pomdpx/variablebuilder"
    autoload :InitialStateBuilder, "aptimizer/pomdpx/initialstatebuilder"
    autoload :TransitionBuilder,   "aptimizer/pomdpx/transitionbuilder"
    autoload :RewardBuilder,       "aptimizer/pomdpx/rewardbuilder"
  end

  module AtkGraph
    autoload :Vertex, "aptimizer/atk_graph/vertex"
    autoload :Graph,  "aptimizer/atk_graph/graph"
  end
end
