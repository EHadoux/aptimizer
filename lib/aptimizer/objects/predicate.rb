module Aptimizer
  class Predicate
    attr_reader :argument1, :argument2, :type, :positive, :owner

    def initialize(type, arg1, arg2:nil, positive:true, owner:1)
      @positive  = positive
      @argument1 = arg1
      @argument2 = arg2
      @type      = type
      @owner     = owner

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
      Predicate.new(@type, @argument1, arg2:@argument2, positive:@positive, owner:@owner)
    end

    def negate
      clone.negate!
    end

    def negate!
      @positive = !@positive
      self
    end

    def positive?
      @positive
    end

    def unsided
      if @positive
        self
      else
        negate
      end
    end

    def is?(type, arg1, arg2=nil, positive=true, owner=1)
      @type == type && arg1 == @argument1 && positive == @positive && (type == :atk ? arg2 == @argument2 : true) && (@type != :priv || @owner == owner)
    end

    def ==(o)
      is?(o.type, o.argument1, o.argument2, o.positive, o.owner)
    end

    def eql?(o)
      self == o
    end

    def hash
      arr = [@type, @argument1, @positive]
      arr << @argument2 if @type == :atk
      arr << @owner if @type == :priv
      arr.hash
    end

    def change_owner(owner)
      @owner = owner
    end
  end
end
