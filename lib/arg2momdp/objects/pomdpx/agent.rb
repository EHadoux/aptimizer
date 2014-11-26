module Arg2MOMDP
  module POMDPX
    class Agent
      attr_reader :arguments, :actions, :initial_state, :action_names

      def initialize(arguments, rules, initial_state, action_names=[])
        @arguments     = arguments
        @actions       = []
        @initial_state = Hash.new(false)
        @action_names  = action_names
        cut_actions(rules)
        filter_initial_state(initial_state)
      end

      private

      def cut_actions(rules)
        rules.each do |r|
          r.alternatives.each do |a|
            a.probability = 1.0
            @actions << Rule.new(r.premisses, [a])
          end
        end
      end

      def filter_initial_state(initial_state)
        initial_state.lazy.select {|p| p.type == :priv}.each do |p|
          raise "Predicate on unknown argument: #{p}" unless @arguments.include?(p.argument1)
          @initial_state[p.argument1] = true
        end
      end
    end
  end
end