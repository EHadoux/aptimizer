module Arg2MOMDP
  module POMDPX
    class POMDPX
      attr_reader :discount, :agent, :opponent, :public_space

      def initialize(discount, agent, opponent, public_space)
        @discount     = discount
        @agent        = agent
        @opponent     = opponent
        @public_space = public_space
      end
    end
  end
end