require_relative 'block'

class SlidingBlock < Block
  def initialize(relative_position, 
                 direction = :horizontal, 
                 length = 4, speed = 0.05,
                 movement_direction = :forward)
    super relative_position
    @direction = direction
    @length = length.u
    @current_step = @length / 2
    @speed = speed.u
    @start_step = @current_step
    @movement_direction = movement_direction
    @start_position = @relative_position
    @moving = true
    @color = Gosu::Color::RED
  end

  # Public: make new object that is equal to self.
  #
  # Returns this new object.
  def clone
    SlidingBlock.new(@relative_position, @direction, @length, @speed, @movement_direction)
  end

  def update(blocks_array = [], old_blocks_array = [])
    @current_step += @speed if @movement_direction == :forward
    @current_step -= @speed if @movement_direction == :backward
    if @current_step > @length
      @current_step -= (@current_step % @length) 
      @movement_direction = :backward
    elsif @current_step < 0.0
      @current_step = -@current_step
      @movement_direction = :forward
    end
    if @direction == :horizontal
      @relative_position = [@start_position.x + \
                            @current_step - @start_step,
                            @start_position.y].to_vec2d
    elsif @direction == :vertical
      @relative_position = [@start_position.x,
                            @start_position.y + \
                            @current_step - @start_step].to_vec2d
    end
  end
end
