module Arg2MOMDP
  class Optimizer
    class << self
      def optimize(pomdp, *optimizations)
        flags_list = [:agent_args, :opp_args]
        f = (optimizations - flags_list) and (raise "Unknown flags :#{f}" unless f.empty?)
        optimizations = flags_list if optimizations.empty?
        optimize_args(pomdp.agent) if optimizations.include?(:agent_args)
        optimize_args(pomdp.opponent) if optimizations.include?(:opp_args)
      end

      def optimize_args(agent)
        args = Set.new
        agent.rules.each do |rule|
          args.merge(rule.premisses.select{|p| p.type == :priv}.map(&:argument1))
          rule.alternatives.each do |alt|
            args.merge(alt.modifiers.select{|m| m.predicate.type == :priv}.map{|m| m.predicate.argument1})
          end
        end
        puts "Arguments removed: #{agent.arguments.size - args.size}"
        agent.arguments = args.to_a
      end
    end

    private_class_method :optimize_args
  end
end