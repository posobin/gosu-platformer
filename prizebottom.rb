require_relative 'prize.rb'

class PrizeBottom < Prize
  # Public: new prize that can be taken only if touched from the bottom side.
  #
  # relative_position - prize's coordinates.
  # points - how many points player will earn if he breaks the block.
  def initialize(relative_position, points = 100)
    super(relative_position, points)
    @color = Gosu::Color::CYAN
  end

  # Public: See Prize#contacted_with for info.
  def contacted_with(interaction_object, intersection_side = :none)
    case interaction_object
    when Player
      if intersection_side == :bottom
        interaction_object.score += @points
        @active = false
        interaction_object.stop_up
      end
    end
  end
end
