module Arg2MOMDP
  module POMDPX
    class POMDPX
      attr_reader :discount, :agent, :opponent, :public_state

      def initialize(discount, agent, opponent, public_state)
        @discount     = discount
        @agent        = agent
        @opponent     = opponent
        @public_state = public_state
      end
    end
  end
end