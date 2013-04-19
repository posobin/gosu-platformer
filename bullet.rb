require_relative 'gameobject'

class Bullet < GameObject
  def initialize(relative_position, speed, life_ticks = 60)
    super 0.5.u, 0.25.u, Gosu::Color::WHITE, relative_position
    @speed = speed
    @life_ticks = life_ticks
  end

  def update(blocks_array = [])
    @relative_position += @speed if @life_ticks > 0
    #@active = false unless @life_ticks > 0
    @life_ticks -= 1
  end
end
