class Pair
  attr_accessor :first, :second, :default
  undef_method :is_a?, :==, :eql?

  def initialize(first, second, default = :first)
    @first, @second, @default = first, second, default
  end

  def method_missing(meth, *args, &block)
    return @first.send(meth, *args, &block) if @default == :first
    return @second.send(meth, *args, &block) if @default == :second
  end

  # Public: make copy of a pair.
  #
  # Returns new pair, consisting of references to original objects.
  def clone
    Pair.new(@first, @second, @default)
  end
end
