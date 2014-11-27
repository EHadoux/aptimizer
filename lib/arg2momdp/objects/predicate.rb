module Arg2MOMDP
  class Predicate
    attr_reader :argument1, :argument2, :type, :positive

    def initialize(type, arg1, arg2=nil, positive=true)
      @positive  = positive
      @argument1 = arg1
      @argument2 = arg2
      @type      = type

      raise "Unknown type of predicate: #{@type}" unless [:atk, :priv, :pub].include? type
    end

    def to_s
      side_str = (@positive ? "" : "!")
      case type
        when :atk  then "#{side_str}e(#{@argument1}, #{@argument2})"
        when :priv then "#{side_str}h(#{@argument1})"
        when :pub  then "#{side_str}a(#{@argument1})"
      end
    end

    def clone
      Predicate.new(@type, @argument1, @argument2, @positive)
    end

    def negate
      clone.negate!
    end

    def negate!
      @positive = !@positive
    end

    def unsided
      p = clone
      p.negate! unless @positive
      return p
    end

    def is?(type, arg1, arg2=nil, positive=true)
      @type == type && arg1 == @argument1 && positive == @positive && (type == :atk ? arg2 == @argument2 : true)
    end

    def ==(o)
      is?(o.type, o.argument1, o.argument2, o.positive)
    end

    def eql?(o)
      self == o
    end

    def hash
      arr = [@type, @argument1, @positive]
      arr << @argument2 if @type == :atk
      arr.hash
    end
  end
end
