require_relative 'block.rb'

class Prize < Block
  # Public: create new prize block.
  #
  # relative_position - coordinates where block will be created.
  # points - how many points player gets when touches the block.
  def initialize(relative_position, points = 50)
    super relative_position
    @color = Gosu::Color::AQUA
    @points = points
  end

  # Public: react to interaction with some other object.
  #
  # interaction_object - object that has interacted.
  # intersection_side - Symbol, showing side of the intersection 
  #                     (see Enemy#contacted_with).
  # 
  # Returns nothing.
  def contacted_with(interaction_object, intersection_side = :none)
    case interaction_object
    when Player
      interaction_object.score += @points
      @active = false
    end
  end
end
