module Arg2MOMDP
  class Alternative
    attr_reader :modifiers
    attr_accessor :probability

    def initialize(modifiers, p=1.0)
      @probability = p
      @modifiers   = modifiers
    end

    def to_s
      "#{@probability}: #{@modifiers.join(" & ")}"
    end
  end
end
