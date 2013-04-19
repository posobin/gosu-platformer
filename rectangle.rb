class Rectangle
  attr_accessor :left_edge, :bottom_edge, :right_edge, :top_edge

  # Public: init new rectangle with edges with passed coordinates.
  #
  # left_edge - x coordinate of left edge.
  # bottom_edge - y coordinate of bottom edge.
  # right_edge - x coordinate of right edge.
  # top_edge - y coordinate of top edge.
  def initialize(left_edge, bottom_edge, right_edge, top_edge)
    @left_edge, @right_edge = left_edge, right_edge
    @top_edge, @bottom_edge = top_edge, bottom_edge
  end

  # Public: width of a rectangle.
  #
  # Returns rectangle's width.
  def width
    @right_edge - @left_edge
  end

  # Public: height of rectangle.
  #
  # Returns rectangle's height.
  def height
    @bottom_edge - @top_edge
  end

  # Public: make an array consisting of rectangle's edges coordinates
  # in following order: [left, bottom, right, top].
  #
  # Returns array of four elements.
  def to_a
    [@left_edge, @bottom_edge, @right_edge, @top_edge]
  end

  # Public: check whether two rectangles consisist the same sides.
  #
  # rect - rectangle to be checked against.
  #
  # Returns true if rectangles are equal.
  def ==(rect)
    @left_edge == rect.left_edge &&
      @right_edge == rect.right_edge &&
      @top_edge == rect.top_edge &&
      @bottom_edge == rect.bottom_edge
  end
end
