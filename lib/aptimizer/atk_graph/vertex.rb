module Aptimizer
  module AtkGraph
    class Vertex
      attr_accessor :parents, :value, :children

      def initialize(value)
        @value    = value
        @parents  = []
        @children = []
      end

      def leaf?
        @parents.empty?
      end

      def dominated?
        !leaf? && @parents.all?(&:leaf?)
      end

      def ==(o)
        @value == o.value
      end

      def eql?(o)
        self == o
      end
    end
  end
end