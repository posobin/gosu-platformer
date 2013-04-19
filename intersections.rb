require_relative 'block'

module Intersections
  # Public: get more info about intersection of two blocks.
  #
  # next_self - next state of the self object.
  # block - block that is intersected.
  # old_block - block's old state.
  #
  # Returns hash containing info about the collision.
  # :side - side of the intersection.
  # :position_change - how self's relative_position should be changed
  #                    in order to eliminate intersection.
  def get_intersection_info(next_self, block, old_block)
    state_old = intersections(old_block, self)
    state_new = intersections(block, next_self)
    unless state_new[:intersect]
      return {:side => :none, :position_change => [0.0, 0.0].to_vec2d}
    end
    dist_x = state_new[:dist_x]
    dist_y = state_new[:dist_y]
    intersection_side = :none
    change_x = (state_new[:x] != state_old[:x] &&
                (![:left_side, :right_side].include? state_new[:x]) &&
                (![:first_in_second, :second_in_first].include? state_old[:x]))
    change_y = (state_new[:y] != state_old[:y] &&
                (![:lower_side, :upper_side].include? state_new[:y]) &&
                (![:first_in_second, :second_in_first].include? state_old[:y]))

    position_change = [0.0, 0.0].to_vec2d
    if change_x && change_y && !(dist_x.infinite? || dist_y.infinite?)
      if dist_x / (@speed.x - 
                   (block.relative_position.x - old_block.relative_position.x)) <
        dist_y / (@speed.y - 
                  (block.relative_position.y - old_block.relative_position.x))
        position_change = [dist_x, 0.0].to_vec2d
      else
        position_change = [0.0, dist_y].to_vec2d
      end
    elsif !dist_x.infinite? && (change_x || dist_y.infinite?)
      position_change = [dist_x, 0.0].to_vec2d
    elsif !dist_y.infinite? && (change_y || dist_x.infinite?)
      position_change = [0.0, dist_y].to_vec2d
    end
    intersection_side = :right if position_change.x > 0.0
    intersection_side = :left if position_change.x < 0.0
    intersection_side = :top if position_change.y < 0.0
    intersection_side = :bottom if position_change.y > 0.0
    {:side => intersection_side, :position_change => position_change}
  end
end
