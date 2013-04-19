require_relative 'vector2d'
require_relative 'gameobject'

class QuadTree
  attr_reader :objects, :nodes
  MAX_OBJECTS = 4
  MAX_LEVELS = 9

  # Public: create new quadtree that has certain dimensions.
  #
  # left_edge, bottom_edge, right_edge, top_edge - coordinates of the edges
  #    (only one coordinate required for each edge).
  # level - level of tree in the hierarchy.
  def initialize(left_edge, bottom_edge, right_edge, top_edge, level = 0)
    @level = level
    @objects = Array.new
    @left_edge, @right_edge = left_edge, right_edge
    @top_edge, @bottom_edge = top_edge, bottom_edge
    @nodes = Array.new
  end

  # Public: clear tree and all it's descendands.
  #
  # Returns nothing.
  def clear
    @objects.clear
    @nodes.each { |node| node.clear; node = nil }
    nil
  end

  # Public: split current tree in four new ones.
  #
  # Returns nothing.
  def split
    sub_width = (@right_edge - @left_edge) / 2.0
    sub_height = (@bottom_edge - @top_edge) / 2.0
    @nodes = [
      QuadTree.new(@left_edge, @top_edge + sub_height,
                   @left_edge + sub_width, @top_edge, @level + 1),
      QuadTree.new(@left_edge, @bottom_edge,
                   @left_edge + sub_width, @top_edge + sub_height, @level + 1),
      QuadTree.new(@left_edge + sub_width, @bottom_edge,
                   @right_edge, @top_edge + sub_height, @level + 1),
      QuadTree.new(@left_edge + sub_width, @top_edge + sub_height,
                   @right_edge, @top_edge, @level + 1)
    ]
  end

  # Public: get index of the node that could fully contain specified rectangle.
  #
  # Returns index of the node if such exists, nil otherwise.
  def get_index(left_edge, bottom_edge, right_edge, top_edge)
    mid_point_x = (@left_edge + @right_edge) / 2.0
    mid_point_y = (@top_edge + @bottom_edge) / 2.0

    if mid_point_x < left_edge && right_edge < @right_edge
      if @top_edge < top_edge && bottom_edge < mid_point_y 
        return 0
      elsif mid_point_y < top_edge && bottom_edge < @bottom_edge
        return 3
      end
    elsif @left_edge < left_edge && right_edge < mid_point_x
      if @top_edge < top_edge && bottom_edge < mid_point_y
        return 1
      elsif mid_point_y < top_edge && bottom_edge < @bottom_edge
        return 2
      end
    end
  end

  # Public: add new object to the tree.
  #
  # object - object to be added.
  #
  # Returns nothing.
  def insert(object)
    unless @nodes.empty?
      index = get_index(*object.bounds.to_a)
      if index
        @nodes[index].insert(object)
        return
      end
    end

    if @objects.size > MAX_OBJECTS && @level < MAX_LEVELS && @nodes.empty?
      if @nodes.empty?
        split
        @objects << object
        @objects.delete_if do |obj|
          index = get_index(*obj.bounds.to_a)
          @nodes[index].insert(obj) if index
          index
        end
      else
        index = get_index(*object.bounds.to_a)
        @nodes[index].insert(object) if index
        @objects << object unless index
      end
    else
      @objects << object
    end
    return
  end

  # Public: remove specified object from the tree. Object is being searched
  # by it's bounding rectangle's coordinates.
  #
  # object - object to be removed from the tree.
  #
  # Returns object if it was deleted, nil otherwise.
  def remove(object)
    index = get_index(*object.bounds.to_a)
    if (!index || @nodes.empty?)
      return @objects.delete(object) 
    else
      return @nodes[index].remove(object)
    end
  end

  # Public: get all objects that could intersect specified object.
  #
  # object - object we are searching intersecting objects for.
  #
  # Returns Array of possible candidates.
  def retrieve(object)
    index = get_index(*object.bounds.to_a)
    list = @objects.map(&:clone)
    if !index && !@nodes.empty?
      @nodes.each { |node| list += node.retrieve(object) }
    elsif index && !@nodes.empty?
      list += @nodes[index].retrieve(object)
    end
    list
  end

  # Public: move old_object to new_object.
  #
  # old_object - previous object's state.
  # new_object - new object's state.
  #
  # Returns nothing.
  def update(old_object, new_object)
    old_index = get_index(*old_object.bounds.to_a)
    new_index = get_index(*new_object.bounds.to_a)
    if (old_index == new_index) && old_index && !@nodes.empty?
      @nodes[new_index].update(old_object, new_object) 
    else
      insert(Pair.new(new_object.clone, old_object.clone)) if remove(old_object)#|| remove(new_object)
    end
  end
end
