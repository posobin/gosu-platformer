require_relative 'gameobject'
require_relative 'intersections'
require_relative 'constants'
require 'set'

MAX_SPEED_X = 20.0
MAX_SPEED_Y = 20.0
JUMP_SPEED = [0.0, -14.0].to_vec2d
SPEED_LEFT = [-0.2, 0.0].to_vec2d
SPEED_RIGHT = [0.2, 0.0].to_vec2d

class Player < GameObject
  include Intersections

  attr_reader :relative_position
  attr_accessor :score

  # Public: initialize player at the specified position.
  #
  # window - Window at which to draw player's image.
  # relative_position - relative coordinates of the player's center.
  def initialize(window, relative_position)
    @relative_position = relative_position
    @image = Gosu::Image.new(window, "./media/Player.png")
    super @image.width, @image.height, Gosu::Color::NONE, relative_position
    @speed = [0.0, 0.0].to_vec2d
    @stop_down = false
    @jump_speed = [0.0, 0.0].to_vec2d
    @health = 1.0
    @score = 0
  end

  # Public: decrease health by amount, specified in the argument.
  #
  # damage - amount do decrease health value by.
  #
  # Returns nothing.
  def add_damage(damage)
    @health -= damage
    puts "You are dead now" if @health <= 0.0
  end

  # Public: accelerate player left.
  #
  # Returns new player's speed.
  def move_right
    @speed += SPEED_RIGHT
  end

  # Public: accelerate player to the left.
  #
  # Returns new speed.
  def move_left
    @speed += SPEED_LEFT
  end

  # Public: move player down.
  #
  # Returns new speed.
  def move_down
    @speed += [0.0, 0.5].to_vec2d
  end
  
  # Public: jump if player is on the ground.
  #
  # Returns nothing.
  def jump
    @jump_speed = JUMP_SPEED
    return
  end

  # Public: obligatory jump.
  #
  # Returns new speed.
  def force_jump
    @speed += JUMP_SPEED
  end

  # Public: stop moving up.
  #
  # Returns new speed.
  def stop_up
    @speed = [@speed.x, 0.0].to_vec2d if @speed.y < 0.0
  end

  # Public: stop all horizontal movement.
  #
  # Returns new speed.
  def stop_horizontally
    @speed = [0.0, @speed.y].to_vec2d
  end

  # Public: update player's speed and position using info passed.
  #
  # quadtree - QuadTree containing pairs of new and old level's objects states.
  #
  # Returns nothing.
  def update(quadtree)
    # Regulate speed if it's past maximum values.
    if @speed.x.abs > MAX_SPEED_X
      @speed = [(@speed.x <=> 0) * MAX_SPEED_X, @speed.y].to_vec2d
    end
    if @speed.y.abs > MAX_SPEED_Y
      @speed = [@speed.x, (@speed.y <=> 0) * MAX_SPEED_Y].to_vec2d
    end
    @speed += GRAVITY_SPEED
    blocks_array = quadtree.retrieve(self)
    old_blocks_array = blocks_array.map do |elem|
      cloned = elem.clone
      cloned.default = :second
      cloned
    end
    @stop_down = false
    blocks_array.each_index do |index|
      next_player = GameObject.new @width, @height, 
        Gosu::Color::NONE, @relative_position + @speed

      old_state = intersections(old_blocks_array[index], self)
      new_state = intersections(blocks_array[index], next_player)

      next unless new_state[:intersect]
      if old_state[:y] == :upper_side && new_state[:y] == :intersect_top
        @speed -= GRAVITY_SPEED
        @stop_down = true
        blocks_array[index].contacted_with(self, :top)
        if old_blocks_array[index].top_edge - self.bottom_edge <= GRAVITY_SPEED.y
          @relative_position += [blocks_array[index].relative_position.x -
                                 old_blocks_array[index].relative_position.x, 
                                 0.0].to_vec2d
        end
      end
    end
    @speed += @jump_speed if @stop_down
    @jump_speed = [0.0, 0.0].to_vec2d
    overall_position_change = [0.0, 0.0].to_vec2d
    blocks_array = quadtree.retrieve(self)
    old_blocks_array = blocks_array.map do |elem|
      cloned = elem.clone
      cloned.default = :second
      cloned
    end

    # Test each block for intersections with player and act 
    # (change position and speed) accordingly.
    blocks_array.each_index do |index|
      block = blocks_array[index]
      old_block = old_blocks_array[index]
      next_player = GameObject.new @width, @height, 
        Gosu::Color::NONE, @relative_position + @speed
      state_old = intersections(old_block, self)
      state_new = intersections(block, next_player)
      next unless state_new[:intersect]

      intersection_info = get_intersection_info(next_player, block, old_block)
      # Inform block about contact
      block.contacted_with(self, intersection_info[:side])
      @relative_position += intersection_info[:position_change]
      overall_position_change += intersection_info[:position_change]
    end
    @relative_position += @speed
    @speed += overall_position_change
  end

  # Public: Draw player with center at 
  # (abs_pos.x + rel_pos.x, abs_pos.y + rel_pos.y).
  #
  # window - window where to draw
  # absolute_position - coordinates of the top left screen corner 
  #                     relative to the (0,0) point.
  # scale - the scale of the drawing.
  #
  # Returns nothing
  def draw(window, absolute_position, scale = 1.0)
    x_corner = absolute_position.x + relative_position.x - @width / 2
    y_corner = absolute_position.y + relative_position.y - @height / 2
    @image.draw(x_corner, y_corner, 0.0)
  end
end
