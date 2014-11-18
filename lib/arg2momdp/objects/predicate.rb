module Arg2MOMDP
  class Predicate
    attr_reader :argument1, :argument2, :type

    def initialize(type, arg1, arg2=nil)
      @argument1 = arg1
      @argument2 = arg2
      @type      = type

      raise "Unknown type of predicate: #{@type}" unless [:atk, :priv, :pub].include? type
    end

    def to_s
      case type
        when :atk  then "e(#{@argument1}, #{@argument2})"
        when :priv then "h(#{@argument1})"
        when :pub  then "a(#{@argument1})"
      end
    end

    def is?(type, arg1, arg2=nil)
      if type == :atk
        @type == :atk && arg1 == @argument1 && arg2 == argument2
      else
        @type == type && arg1 == @argument1
      end
    end

    def ==(o)
      is?(o.type, o.argument1, o.argument2)
    end

    def eql?(o)
      self == o
    end

    def hash
      if @type == :atk
        [@type, @argument1, @argument2].hash
      else
        [@type, @argument1].hash
      end
    end
  end
end
