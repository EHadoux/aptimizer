require "rltk/parser"

module Arg2MOMDP
  class Parser < RLTK::Parser
    production(:input) do
      clause("args")    { |a| a }
    end

    nonempty_list(:args, :ARG, :COMMA)

    finalize({:use => 'parser.tbl'})
  end
end
