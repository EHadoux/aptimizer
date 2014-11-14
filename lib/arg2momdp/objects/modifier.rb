module Arg2MOMDP
  class Modifier
    attr_reader :type, :scope, :predicate

    def initialize(type, scope, predicate)
      @type      = type
      @scope     = scope
      @predicate = predicate

      raise "Unknown modifier type: #{type}" unless [:add, :rem].include? type
      raise "Unknown modifier scope: #{scope}" unless [:priv, :pub].include? scope

      case @predicate.type
      when :atk then raise "No private modifiers on attacks" if @scope == :priv
      when :pub then raise "No private modifiers on public predicates" if @scope == :priv
      when :priv then raise "No public modifiers on private predicates" if @scope == :pub
      end
    end

    def to_s
      "#{"." if @scope == :priv}#{(@type == :add) ? "+" : "-"}#{@predicate}"
    end
  end
end
