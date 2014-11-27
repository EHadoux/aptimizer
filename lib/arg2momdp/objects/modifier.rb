module Arg2MOMDP
  class Modifier
    attr_reader :type, :scope, :predicate

    # Constructs a modifier on a [Predicate].
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

    # Returns whether the modifier is compatible with an instance of predicate.
    # If the instance is "*", all modifiers are compatible.
    # If the instance is true, the modifier type can only be :rem as it cannot add an already present predicate.
    # It is the opposite for false.
    #
    # @param instance ["*", true, false] The instance to test the modifier on
    #
    # @return [Boolean] true if the modifier is compatible, false otherwise
    #
    # @raise [Error] if the instance is not "*", true or false
    def compatible?(instance)
      if instance.is_a?(String)
        return true if instance == "*"
      elsif !!instance == instance
        return (@type == :add && !instance) || (@type == :rem && instance)
      else
        raise "Can only test with *, true or false"
      end
    end
  end
end
