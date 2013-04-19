class Vector2D
  attr_reader :x, :y

  # Public: init vector with passed coordinates.
  #
  # x - x-projection.
  # y - y-projection.
  def initialize(x, y)
    @x, @y = x, y
  end

  # Public: sumo of two vectors.
  #
  # vec - vector to be added to self.
  #
  # Returns result of addition.
  def +(vec)
    Vector2D.new(@x + vec.x, @y + vec.y)
  end

  # Public: substract one vector from another.
  #
  # vec - vector to be substracted.
  #
  # Returns new vector - result of substraction.
  def -(vec)
    Vector2D.new(@x - vec.x, @y - vec.y)
  end

  # Public: multiply vector by scalar.
  #
  # num - number by which multiply.
  #
  # Returns new vector - result of multiplication.
  def *(num)
    Vector2D.new(@x * num, @y * num)
  end

  # Public: vector, opposite to self.
  #
  # Returns new vector, opposite to self.
  def -@
    Vector2D.new(-@x, -@y)
  end

  # Public: check two vectors for equality.
  #
  # Returns result of check. True, if both projections are equal.
  def ==(vec)
    @x == vec.x && @y == vec.y
  end
end

class Array
  def to_vec2d
#    raise "Array must consist of two elements" unless self.length == 2
    Vector2D.new(self[0], self[1])
  end
end
