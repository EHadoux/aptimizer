module Aptimizer
  class PublicSpace
    attr_reader :initial_state, :attacks, :backup_attacks
    attr_accessor :enthymeme, :arguments

    def initialize(arguments, attacks, initial_state)
      @arguments        = arguments
      @attacks          = attacks
      @backup_attacks   = Array.new(@attacks)
      @initial_state    = Hash.new(false)
      @enthymeme        = false
      filter_initial_state(initial_state)
    end

    private

    def filter_initial_state(initial_state)
      initial_state.each do |p|
        if p.type == :pub
          raise "Predicate on unknown argument: #{p}" unless @arguments.include? p.argument1
          @initial_state[p.argument1] = true
        elsif p.type == :atk
          unless @arguments.include?(p.argument1) && @arguments.include?(p.argument2) && @attacks.include?(p)
            raise "Predicate on unknown argument: #{p}"
          end
          @initial_state["#{p.argument1}_#{p.argument2}"] = true
        end
      end
    end
  end
end