require_relative 'gameobject'
require_relative 'block'

class Enemy < GameObject
  # Public: initialize moveless enemy at the specified coordinates.
  #
  # relative_position - place where center of the enemy will be located.
  # price - how much player earns if he kills one enemy.
  def initialize(relative_position, price = 200)
    super 1.u, 1.u, Gosu::Color::BLUE, relative_position
    @damage = 1.0
    @price = price
  end

  # Public: react to interaction with some object by
  # calling object's certain method and changing itself.
  #
  # interaction_object - Object that has intersected.
  # intersection_side - The side symbol where the intersection occured.
  #                     :top, :left, :right, :bottom, :none (Default value)
  #
  # Returns nothing.
  def contacted_with(interaction_object, intersection_side = :none)
    case interaction_object
    when Player
      # Die if player has jumped on top
      if intersection_side == :top
        interaction_object.force_jump
        @active = false
        @price ||= 200
        interaction_object.score += @price
      else
        interaction_object.add_damage(@damage)
      end
    end
  end
end
