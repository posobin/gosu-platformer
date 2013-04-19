require_relative 'block'

class InvisibleBlock < Block
  def initialize(relative_position)
    super relative_position
    @color = Gosu::Color::NONE
  end
end
