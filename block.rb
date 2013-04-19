require_relative 'gameobject'
require_relative 'vector2d'

BLOCK_SIZE = 30.0

# Float and Fixnum modifications in order to 
# convert to grid size easier
class Fixnum
  def u
    return BLOCK_SIZE * self
  end
end

class Float
  def u
    return BLOCK_SIZE * self
  end
end

EPSILON = 1.0e-6

class Block < GameObject
  def initialize(relative_position)
    super BLOCK_SIZE, BLOCK_SIZE, Gosu::Color::GREEN, relative_position
  end
end

# Returns hash showing x-intersection type and y-intersection type.
# REVIEW needed. This method does not belong to this file.
def intersections(first, second)
  def get_vertical_state(first, second)
    if (first.top_edge + EPSILON) < second.bottom_edge &&
      second.bottom_edge < (first.bottom_edge - EPSILON)
      if (first.top_edge + EPSILON) < second.top_edge && 
        second.top_edge < (first.bottom_edge - EPSILON)
        return :second_in_first
      else
        return :intersect_top
      end
    elsif (first.top_edge + EPSILON) < second.top_edge && 
      second.top_edge < (first.bottom_edge - EPSILON)
      return :intersect_bottom
    elsif second.top_edge >= first.bottom_edge - EPSILON
      return :lower_side
    elsif second.bottom_edge <= first.top_edge + EPSILON
      return :upper_side
    else
      return :first_in_second
    end
  end

  def get_horizontal_state(first, second)
    if (first.left_edge + EPSILON) < second.right_edge &&
      second.right_edge < (first.right_edge - EPSILON)
      if (first.left_edge + EPSILON) < second.left_edge && 
        second.left_edge < (first.right_edge - EPSILON)
        return :second_in_first
      else
        return :intersect_left
      end
    elsif (first.left_edge + EPSILON) < second.left_edge &&
      second.left_edge < (first.right_edge - EPSILON)
      return :intersect_right
    elsif second.right_edge <= first.left_edge + EPSILON
      return :left_side
    elsif second.left_edge >= first.right_edge - EPSILON
      return :right_side
    else
      return :first_in_second
    end
  end
  x_state = get_horizontal_state(first, second)
  y_state = get_vertical_state(first, second)
  dist_x = case x_state
           when :intersect_left then first.left_edge - second.right_edge
           when :intersect_right then first.right_edge - second.left_edge
           else Float::INFINITY
           end
  dist_y = case y_state
           when :intersect_top then first.top_edge - second.bottom_edge
           when :intersect_bottom then first.bottom_edge - second.top_edge
           else Float::INFINITY
           end
  intersection = (x_state != :left_side && x_state != :right_side) &&
    (y_state != :upper_side && y_state != :lower_side)
  {:x => x_state, :y => y_state, :intersect => intersection,
  :dist_x => dist_x, :dist_y => dist_y}
end
