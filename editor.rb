require 'gosu'
require_relative 'block'
require_relative 'zorder'
require_relative 'slidingblock'
require_relative 'invisibleblock'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'movingenemy'
require_relative 'prizebottom'

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

class EditorWindow < Gosu::Window
  # Public: get coordinates of the grid square containing specified point.
  #
  # x, y - coordintes of the point
  #
  # Returns array of square center's coordinates ([x, y])
  def adjust_block_coordinates(x, y)
    new_x = x - x % 1.u + 1.u / 2
    new_y = y - y % 1.u + 1.u / 2
    [new_x, new_y]
  end

  # Public: get one block of current type at the specified coordinates.
  #
  # x, y - coordinates, adjusted to grid automatically.
  #
  # Returns block of current type at the specified position.
  def get_current_block(x, y)
    case @block_type
    when :ordinary
      Block.new(adjust_block_coordinates(x,y).to_vec2d)
    when :sliding_horizontally
      SlidingBlock.new(adjust_block_coordinates(x, y).to_vec2d,
                                        :horizontal) 
    when :sliding_vertically
      SlidingBlock.new(adjust_block_coordinates(x, y).to_vec2d,
                                        :vertical) 
    when :moving_enemy
      MovingEnemy.new(adjust_block_coordinates(x, y).to_vec2d)
    when :prize
      PrizeBottom.new(adjust_block_coordinates(x,y).to_vec2d)
    end
  end

  # Public: write level to the file.
  #
  # Returns nothing.
  def save_level
    File.open(@file_name, 'w') do |file|
      @blocks_array.each do |block|
        new_block = Block.new block.relative_position
        puts new_block.to_s
      end
    end
  end

  def initialize 
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false, 16)
    @blocks_array = Array.new
    @x_viewport = @y_viewport = 0
    @block_type = :ordinary
    @block_types = [:ordinary, :sliding_horizontally, :sliding_vertically, :moving_enemy, :prize]
    @file_name = "level.lvl"
    if File.exists?(@file_name)
      File.open(@file_name) do |file|
        @blocks_array += Marshal::load(file)
      end
    end
  end

  def needs_cursor?
    true
  end

  def update
    unless button_down? Gosu::MsLeft
      @block_under_mouse = get_current_block(mouse_x - @x_viewport,
                                             mouse_y - @y_viewport)
    else
      @block_under_mouse = nil
    end
    if button_down? Gosu::KbLeft
      @x_viewport += 10
    end
    if button_down? Gosu::KbRight
      @x_viewport -= 10
    end
    if button_down? Gosu::KbUp
      @y_viewport += 10
    end
    if button_down? Gosu::KbDown
      @y_viewport -= 10
    end
    @blocks_array.each do |block|
      block.update unless block.moving
    end
  end

  def draw
    @blocks_array.each do |block|
      block.draw(self,
                 [@x_viewport, @y_viewport].to_vec2d)
    end
    if @block_under_mouse
      @block_under_mouse.draw(self, [@x_viewport,@y_viewport].to_vec2d) 
    end
  end

  def button_down(id)
    case id
    when Gosu::KbEnter, Gosu::KbReturn # Save level
      File.open(@file_name, 'w') do |file|
        puts "Saving"
        file.puts Marshal::dump(@blocks_array)
      end
    when Gosu::KbTab # Switch block type
      @block_type = @block_types.rotate![0]
    when Gosu::MsLeft # Add new block
      @blocks_array << get_current_block(mouse_x - @x_viewport,
                                         mouse_y - @y_viewport)
      puts "new block added"
    when Gosu::MsRight # Delete block
      @blocks_array.each_index do |index|
        if @blocks_array[index].contains_point(mouse_x - @x_viewport, mouse_y - @y_viewport)
          puts "block deleted, #{@blocks_array[index].relative_position.x}, #{@blocks_array[index].relative_position.y}"
          @blocks_array.delete_at index 
        end
      end
    end
  end
end

window = EditorWindow.new
window.show
