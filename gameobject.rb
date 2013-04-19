require 'gosu'
require_relative 'vector2d'
require_relative 'zorder'
require_relative 'rectangle'

# Extend Gosu::Color class for the ability to serialize it.
module Gosu
  class Color
    def marshal_dump
      [red, green, blue, alpha]
    end

    def marshal_load array
      red, green, blue, alpha = array
      initialize(alpha, red, green, blue)
    end
  end
end

class GameObject
  attr_reader :width, :height, :color, :relative_position, :active, :moving

  # Public: create new object of this type.
  #
  # width - width of a new object.
  # height - height of a new object.
  # color - new object's color.
  # relative_position - relative position of the object.
  def initialize(width, height, color, relative_position)
    @width, @height = width, height
    @moving = false
    @movable = false
    @active = true
    @color = color
    @relative_position = relative_position
  end

  # Public: change object's properties. Children should override that method.
  #
  # blocks_array - array of blocks this object needs to check against.
  # old_blocks_array - previous states of these blocks.
  #
  # Returns nothing.
  def update(blocks_array = [], old_blocks_array = [])
  end

  # Public: react to the contact with some object. Does nothing by default.
  #
  # interaction_object - Object that has contacted.
  # intersection_side - side that the object has touched.
  #                     :top, :left, :right, :bottom, :none (Default value)
  #
  # Returns nothing.
  def contacted_with(interaction_object, intersection_side = :none)
  end

  # By default draws square with center at 
  # (abs_pos.x + rel_pos.x, abs_pos.y + rel_pos.y)
  # Should be changed by subclass if different drawing is needed
  def draw(window, absolute_position, scale = 1.0)
    x_center = absolute_position.x + relative_position.x
    y_center = absolute_position.y + relative_position.y
    window.draw_quad((x_center - width / 2) * scale,
                     (y_center + height / 2) * scale, @color,
                     (x_center + width / 2) * scale,
                     (y_center + height / 2) * scale, @color,
                     (x_center + width / 2) * scale,
                     (y_center - height / 2) * scale, @color,
                     (x_center - width / 2) * scale,
                     (y_center - height / 2) * scale, @color,
                     ZOrder::Block)
  end

  # Public: check whether point belongs to this object's rectangle.
  #
  # x - x-coordinate of the point.
  # y - y-coordinate of the point.
  #
  # Returns true if contains, false otherwise.
  def contains_point(x, y)
    (@relative_position.x - @width / 2 <= x && x <= @relative_position.x + @width / 2) && \
      (@relative_position.y - @height / 2 <= y && y <= @relative_position.y + @height / 2)
  end

  # Public: make a deep copy of this object.
  #
  # Returns new object, deep copy of this one.
  def clone
    GameObject.new(@width, @height, @color, @relative_position)
  end

  # Methods for getting relative coordinates of different object's edges
  def top_edge
    @relative_position.y - @height / 2
  end

  def left_edge
    @relative_position.x - @width / 2
  end

  def right_edge
    @relative_position.x + @width / 2
  end

  def bottom_edge
    @relative_position.y + @height / 2
  end

  # Public: get this object's bounding rectangle.
  #
  # Returns rectangle bounded by this object's edges.
  def bounds
    Rectangle.new(left_edge, bottom_edge, right_edge, top_edge)
  end

  # Public: check whether two GameObjects are same.
  #
  # obj - object to be checked with.
  #
  # Returns result of check.
  def ==(obj)
    bounds == obj.bounds &&
      #@active == obj.active &&
      @moving == obj.moving
  end
end
