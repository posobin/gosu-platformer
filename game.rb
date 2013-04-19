require 'gosu'
require_relative 'block'
require_relative 'gameobject'
require_relative 'player'
require_relative 'slidingblock'
require_relative 'invisibleblock'
require_relative 'bullet'
require_relative 'enemy'
require_relative 'movingenemy'
require_relative 'quadtree'
require_relative 'pair'
require_relative 'rectangle'
require_relative 'prizebottom'

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

class GameWindow < Gosu::Window
  # Public: create new GameWindow and load level.
  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT, false, 16
    @blocks_array = Array.new
    @player = Player.new self, [100.0, 100.0].to_vec2d
    @level_file = "level.lvl"
    @x_viewport, @y_viewport = 100.0, -30.0
    @x_bounds, @y_bounds = 200.0, 150.0
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @previous_direction = :none
    if File.exists?(@level_file)
      File.open(@level_file) do |file|
        @blocks_array = Marshal::load(file)
      end
    end
    @updated_blocks = @blocks_array

    @level_bounds = Rectangle.new(0.0,0.0,0.0,0.0)
    @blocks_array.each do |block|
      if block.left_edge < @level_bounds.left_edge
        @level_bounds.left_edge = block.left_edge - 10.0
      end
      if block.top_edge < @level_bounds.top_edge
        @level_bounds.top_edge = block.top_edge - 10.0
      end
      if block.right_edge > @level_bounds.right_edge
        @level_bounds.right_edge = block.right_edge + 10.0
      end
      if block.bottom_edge > @level_bounds.bottom_edge
        @level_bounds.bottom_edge = block.bottom_edge + 10.0
      end
    end
    @quadtree = QuadTree.new(*@level_bounds.to_a)
    @blocks_array.each do |block|
      @quadtree.insert(Pair.new(block, block))
    end
  end

  # Public: update game scene.
  #
  # Returns nothing.
  def update
    if @paused
      return 0
    end
    next_direction = :none
    if button_down? Gosu::KbRight
      @player.move_right 
      next_direction = :right
    end
    if button_down? Gosu::KbLeft
      @player.move_left 
      next_direction = :left
    end
    @player.move_down if button_down? Gosu::KbDown
    @player.jump if button_down? Gosu::KbUp
    if (next_direction != @previous_direction) || !((button_down? Gosu::KbRight) || (button_down? Gosu::KbLeft))
      @player.stop_horizontally
    end
    @previous_direction = next_direction
    
    @updated_blocks = Array.new
    @blocks_array.each do |block|
#      # Don't update this block if it is not in 3x3 screens area
#      unless ((-@x_viewport - SCREEN_WIDTH)..
#              (-@x_viewport + 2 * SCREEN_WIDTH)).include?(block.relative_position.x) &&
#              ((-@y_viewport - SCREEN_HEIGHT)..
#               (-@y_viewport + 2 * SCREEN_HEIGHT)).include?(block.relative_position.y)
#        next
#      end
#      # Don't update if this block is not in 2x2 screens area and moving
#      unless (!block.moving ||
#              ((-@x_viewport - SCREEN_WIDTH * 0.5)..
#              (-@x_viewport + 1.5 * SCREEN_WIDTH)).include?(block.relative_position.x) &&
#              ((-@y_viewport - SCREEN_HEIGHT * 0.5)..
#               (-@y_viewport + 1.5 * SCREEN_HEIGHT)).include?(block.relative_position.y))
#        next
#      end
      old_block = block.clone
      @quadtree.remove(block) unless block.active

      block.update unless block.moving || !block.active
      if block.active
        @updated_blocks << block
      else
        @quadtree.remove(old_block)
      end
    end
#    @updated_blocks.each_index do |index|
#      new_block = Pair.new(@updated_blocks[index], old_blocks[index])
#      @quadtree.insert(new_block)
#    end

    # Delete not active blocks
    @blocks_array.keep_if { |block| block.active }
    @updated_blocks.each do |block|
      next unless block.moving && block.active
      old_block = block.clone

      block.update(@quadtree) if block.is_a? Enemy
      block.update unless block.is_a? Enemy

      @quadtree.update(old_block, block) if block.active
      @quadtree.remove(old_block) unless block.active
    end
    @player.update @quadtree

    # Move "camera" if player is near screen bounds
    if @player.relative_position.x + @x_viewport > SCREEN_WIDTH - @x_bounds
      @x_viewport = SCREEN_WIDTH - @x_bounds - @player.relative_position.x
    elsif @player.relative_position.x + @x_viewport < @x_bounds
      @x_viewport = @x_bounds - @player.relative_position.x
    end

    if @player.relative_position.y + @y_viewport > SCREEN_HEIGHT - @y_bounds
      @y_viewport = SCREEN_HEIGHT - @y_bounds - @player.relative_position.y
    elsif @player.relative_position.y + @y_viewport < @y_bounds
      @y_viewport = @y_bounds - @player.relative_position.y
    end
  end

  # Public: draw all level onto the screen.
  #
  # Returns nothing.
  def draw
    @updated_blocks.each do |block|
      block.draw(self, [@x_viewport, @y_viewport].to_vec2d)
    end
    @player.draw(self, [@x_viewport, @y_viewport].to_vec2d)
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI,
               1.0, 1.0, Gosu::Color::WHITE)
  end

  # Public: detect button down event.
  #
  # id - integer number of key that was pressed.
  #
  # Returns nothing.
  def button_down(id)
    case id
    when Gosu::KbEnter, Gosu::KbReturn
      @paused = !@paused
    end
  end
end

window = GameWindow.new
window.show
