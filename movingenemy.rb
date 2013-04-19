require_relative 'block'
require_relative 'enemy'
require_relative 'intersections'
require_relative 'constants'
require_relative 'vector2d'

class MovingEnemy < Enemy
  include Intersections
  attr_reader :speed

  # Public: initialize moving enemy at the specified position
  #
  # relative_position - place where center of the enemy 
  #                     is placed before moving
  # speed - speed at which block will be moving
  def initialize(relative_position, speed = [2.0, 0.0].to_vec2d)
    super relative_position
    @speed = speed
    @moving = true
  end

  # Public: make a deep copy of the object.
  #
  # Returns new object, equal to self.
  def clone
    MovingEnemy.new(@relative_position, @speed)
  end

  # Public: change object's properties according to the overall situation.
  #
  # quadtree - QuadTree showing current level's state, consisting of pairs,
  #            second (not active) element of which shows previous state of 
  #            the block.
  #
  # Returns nothing.
  def update(quadtree)
    @speed += GRAVITY_SPEED
    @relative_position += @speed
    blocks_array = quadtree.retrieve(self)
    old_blocks_array = blocks_array.map do |elem|
      cloned = elem.clone
      cloned.default = :second
      cloned
    end
    @relative_position -= @speed
    # Don't let speed increase if enemy is on top of the other block
    blocks_array.each_index do |index|
      next unless blocks_array[index].top_edge > self.bottom_edge - EPSILON
      @relative_position += @speed
      new_state = intersections(blocks_array[index], self)
      @relative_position -= @speed
      if new_state[:intersect] && new_state[:y] == :intersect_top
        @speed -= GRAVITY_SPEED
        if old_blocks_array[index].top_edge - self.bottom_edge <= GRAVITY_SPEED.y
          @relative_position += [blocks_array[index].relative_position.x -
                                 old_blocks_array[index].relative_position.x, 
                                 0.0].to_vec2d
        end
      end
    end
    blocks_array = quadtree.retrieve(self)
    old_blocks_array = blocks_array.map do |elem|
      cloned = elem.clone
      cloned.default = :second
      cloned
    end

    overall_position_change = [0.0, 0.0].to_vec2d
    blocks_array.each_index do |index|
      next if blocks_array[index].is_a? Enemy
      block, old_block = blocks_array[index], old_blocks_array[index]
      next if ((block.right_edge < (self.left_edge + @speed.x)) ||
        (block.left_edge > (self.right_edge + @speed.x)) ||
        (block.top_edge > (self.bottom_edge + @speed.y)) ||
        (block.bottom_edge < (self.top_edge + @speed.y)))
      next_position = GameObject.new(@width, @height, Gosu::Color::NONE,
                                     @relative_position + @speed)
      state = get_intersection_info(next_position, block, old_block)
      if state[:side] == :left || state[:side] == :right
        @speed = [-@speed.x, @speed.y].to_vec2d
      else
        @relative_position += state[:position_change]
        overall_position_change += state[:position_change]
      end
    end
    @relative_position += @speed
    @speed += overall_position_change
  end

  # Public: check two moving enemies' equality.
  #
  # obj - object to be checked with.
  #
  # Returns check's result.
  def ==(obj)
    super(obj) && (obj.class.method_defined?(:speed) && @speed == obj.speed)
  end
end
