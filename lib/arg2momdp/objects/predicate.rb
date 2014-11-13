module Arg2MOMDP
  class Predicate
    attr_reader :argument1, :argument2, :type

    def initialize(type, arg1, arg2)
      @argument1 = arg1
      @argument2 = arg2
      @type      = type

      raise "Unknown type of predicate: #{@type}" unless [:atk].include? type
    end

    def to_s
      case type
        when :atk  then "e(#{@argument1}, #{@argument2})"
      end
    end
  end
end
