module Aptimizer
  class Modifier
    attr_reader :type, :scope, :predicate

    # Constructs a modifier on a {Predicate}.
    #
    # @param type [:add, :rem] Specifies if this modifier adds or removes a predicate
    # @param scope [:priv, :pub] Specifies if this modifier changes the private state or the public space
    # @param predicate [Predicate] The predicate to be added or removed (only positive predicate can be modified)
    # @raise [Error] if type or scope is invalid, the predicate is negative,
    #   the scope and the type of the predicate are not compatible
    def initialize(type, scope, predicate)
      @type      = type
      @scope     = scope
      @predicate = predicate

      raise "Unknown modifier type: #{type}" unless [:add, :rem].include? type
      raise "Unknown modifier scope: #{scope}" unless [:priv, :pub].include? scope
      raise "Cannot modify a negative predicate" unless @predicate.positive

      case @predicate.type
      when :atk then raise "No private modifiers on attacks" if @scope == :priv
      when :pub then raise "No private modifiers on public predicates" if @scope == :priv
      when :priv then raise "No public modifiers on private predicates" if @scope == :pub
      end
    end

    # Returns a readable version of the modifier.
    #
    # return [String] A String representation of the modifier
    def to_s
      "#{"." if @scope == :priv}#{(@type == :add) ? "+" : "-"}#{@predicate}"
    end
  end
end
