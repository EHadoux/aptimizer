module Arg2MOMDP
  module AtkGraph
    class Vertex
      attr_accessor :owner, :parents, :value, :children

      def initialize(value, owner)
        @value    = value
        @owner    = owner
        @parents  = []
        @children = []
      end

      def leaf?
        return @parents.empty?
      end

      def dominated?
        return !leaf? && @parents.all?(&:leaf?)
      end

      def ==(o)
        return @value == o.value && @owner == o.owner
      end

      def eql?(o)
        self == o
      end
    end
  end
end