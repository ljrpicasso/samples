require 'rspec'
require 'curses'

class Cell
  attr_accessor :x, :y

  def initialize(world, x=0, y=0)
    @x = x
    @y = y
    @world = world
    @world.cells << self
  end

  def tick!
    if neighbors.count < 2
      return false
    elsif neighbors.count > 3
      return false
    else
      return true
    end
  end

  def neighbors
    my_neighbors = []
    my_rules = [
      [-1, 1], #nw
      [ 0, 1], #n
      [ 1, 1], #ne
      [-1, 0], #w
      [ 1, 0], #e
      [-1,-1], #sw
      [ 0,-1], #s
      [ 1,-1], #se
    ]
    @world.cells.each do |cell|
      my_rules.each do |x_offset, y_offset|
        if (self.x + x_offset == cell.x) and (self.y + y_offset == cell.y)
          my_neighbors << self
          break
        end
      end
    end
    my_neighbors
  end

end

class World
  attr_accessor :cells

  def initialize
    @cells = []
  end

  def tick!
    new_cells = []

    (0..20).each do |y|
      (0..20).each do |x|
        if !has_cell_at?(x,y)
          c = Cell.new(self,x,y)
          if c.neighbors.count == 3
            new_cells << [x, y]
          end
          @cells -= [c]   # only temporary
        end
      end
    end
          
    @cells.each do |cell|
      if cell.tick! != false
        new_cells << [cell.x, cell.y]
      end
    end

    # rebuild to grid with correct cells
    @cells = []
    new_cells.each do |x,y|
      Cell.new(self,x,y)
    end
  end

  def has_cell_at?(x,y)
    @cells.each do |cell|
      if cell.x==x and cell.y==y
        return true
      end
    end
    return false
  end

  def info
    if @cells.empty?
      "World grid is not yet defined."
    else
      "Grid contains #{@cells.count} cells" 
    end
  end

  def display
    Curses.setpos(1,4)
    Curses.clrtoeol
    Curses.addstr(info)
    (0..20).each do |y|
      line = ""
      (0..20).each do |x|
        if has_cell_at?(x,y)
          line << "* "
        else
          line << "  "
        end
      end
      Curses.setpos(y+2,4)
      Curses.addstr(line)
    end
  end
end

describe 'game of life' do
  before(:each) do
    @w = World.new
  end

  describe 'setup' do
    it 'supports cells and worlds' do
      @w.should
      cell = Cell.new(@w)
      cell.should
    end

    it 'sets a cell to specific location' do
      cell = Cell.new(@w)
      cell.x.should == 0
      cell.y.should == 0

      cell = Cell.new(@w,1,2)
      cell.x.should == 1
      cell.y.should == 2
    end

    it 'adds each cell to a world' do
      cell = Cell.new(@w)
      @w.cells.should include(cell)
    end
  end

  describe 'neighbors' do
    it 'knows a northern neighbor' do
      cell = Cell.new(@w)
      cell2 = Cell.new(@w, 0, 1)
      cell.neighbors.count.should == 1
    end
    it 'knows a southern neighbor' do
      cell = Cell.new(@w)
      cell2 = Cell.new(@w, 0, -1)
      cell.neighbors.count.should == 1
    end
    it 'knows a eastern neighbor' do
      cell = Cell.new(@w)
      cell2 = Cell.new(@w, 1, 0)
      cell.neighbors.count.should == 1
    end
    it 'knows a western neighbor' do
      cell = Cell.new(@w)
      cell2 = Cell.new(@w, -1, 0)
      cell.neighbors.count.should == 1
    end
  end

  describe 'rules of life' do
    it 'dies with less than 2 neighbors' do
      cell = Cell.new(@w)
      @w.tick!
      @w.cells.should_not include(cell)
    end

    it 'lives with 2 or 3 neighbors' do
      cell = Cell.new(@w,2,2)
      cell2 = Cell.new(@w,2,3)
      cell3 = Cell.new(@w,2,1)
      cell4 = Cell.new(@w,1,2)
      @w.tick!
      @w.has_cell_at?(2,2).should be_true
    end

    it 'dies with more than 3 neighbors' do
      cell = Cell.new(@w,2,2)
      cell2 = Cell.new(@w,2,3)
      cell3 = Cell.new(@w,2,1)
      cell4 = Cell.new(@w,1,1)
      cell5 = Cell.new(@w,1,2)
      @w.tick!
      @w.has_cell_at?(2,2).should_not be_true
    end

    it 'comes to life with exactly 3 neighbors' do
      cell2 = Cell.new(@w,2,3)
      cell3 = Cell.new(@w,2,1)
      cell5 = Cell.new(@w,1,2)
      @w.tick!
      @w.has_cell_at?(2,2).should be_true 
    end
  end

  describe 'various outputs' do
    it 'knows when the board is undefined' do
      msg = "World grid is not yet defined."
      @w.info.should == msg
      cell = Cell.new(@w, 1, 1)
      @w.info.should_not == msg
    end

    it 'can display its status' do
      Curses.init_screen
      pulsar = [
        [4, 2], [5, 2], [6, 2],
        [10,2], [11,2], [12,2],
        [2, 4], [2, 5], [2, 6],
        [7, 4], [7, 5], [7, 6],
        [9, 4], [9, 5], [9, 6],
        [14,4], [14,5], [14,6],
        [4, 7], [5, 7], [6, 7],
        [10,7], [11,7], [12,7],
      ]
      pulsar.each do |x,y|
        Cell.new(@w, x, y)
      end
      @w.display
      Curses.refresh
      sleep 1.5
      1.upto(10) do
        @w.tick!
        @w.display
        Curses.refresh
        sleep 0.5
      end
      Curses.close_screen
    end
  end
end
