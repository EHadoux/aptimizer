module Arg2MOMDP
  module AtkGraph
    class Graph
      attr_accessor :vertices

      def initialize
        @vertices = Array.new
      end

      def add_atk(parent, child)
        index = @vertices.find_index(child)
        index_parent = @vertices.find_index(parent)
        if index_parent.nil?
          @vertices << parent
        else
          parent = @vertices[index_parent]
        end
        if index.nil?
          child.parents << parent
          @vertices << child
          parent.children << child
        else
          parent.children << @vertices[index]
          @vertices[index].parents << parent
        end
      end
    end
  end
end