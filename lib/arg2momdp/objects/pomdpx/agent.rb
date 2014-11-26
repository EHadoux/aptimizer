module Arg2MOMDP
  module POMDPX
    class Agent
      attr_reader :arguments, :actions, :initial_state, :action_names

      # Constructs the agent to optimize.
      #
      # @param arguments [Array<String>] The list of arguments
      # @param rules [Array<Rule>] The list of rules
      # @param initial_state [Array<Predicate>] The initial state of the problem
      # @param action_names [Array<String>] A list of names to replace rule number
      def initialize(arguments, rules, initial_state, action_names=[])
        @arguments     = arguments
        @actions       = []
        @initial_state = Hash.new(false)
        @action_names  = action_names
        extract_actions!(rules)
        filter_initial_state!(initial_state)
      end

      private

      # Extracts actions from rules as there cannot be more than one alternative for the agent to optimize.
      #
      # @param rules [Array<Rule>] The rules to extract the actions from
      def extract_actions!(rules)
        rules.each do |r|
          r.alternatives.each do |a|
            a.probability = 1.0
            @actions << Rule.new(r.premisses, [a])
          end
        end
      end

      # Filters initial state predicates as only private ones are relevant for the agent to optimize.
      #
      # @param initial_state [Array<Predicate>] The initial state of the problem
      def filter_initial_state!(initial_state)
        initial_state.lazy.select {|p| p.type == :priv}.each do |p|
          raise "Predicate on unknown argument: #{p}" unless @arguments.include?(p.argument1)
          @initial_state[p.argument1] = true
        end
      end
    end
  end
end