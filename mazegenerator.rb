require 'pry'
require 'colorize'
class MazeGenerator
   attr_accessor :side, :grid, :cell_stack, :cell_visited, :flat_grid

  def initialize (side_size)
    @side = side_size
    @dug_end = false
    @cell_stack = [ ]
    @cell_visited = [ ]
    @solution_path = [ ]
    self.build_grid
    self.carve_way
    self.to_s

  end

  def build_grid
    @grid = []
    row = "█" * @side
    row = row.scan(/./)
    @side.times{ @grid << row.clone }

    start_cell_y = rand(1...(@side-1))
    @start_cell = [ 0, start_cell_y ]
    dig(@start_cell, "→")
  end

  def count_possible_cells
    total_cells = @side * @side
    total_cells - (@side * 4) + 2
  end

  def canDig(from_cell, to_cell)
    # special case: the first time we hit the right wall, it's the end
    if !@dug_end && to_cell[0] == @side-1
      dig(to_cell, "@")
      @dug_end = true
    end

    # cannot dig exterior walls
    if to_cell[0] <= 0 || to_cell[0] >= @side-1 || to_cell[1] <= 0 || to_cell[1] >= @side-1
      # puts "rejecting to_cell = #{to_cell}"
      return false
    end

    # review all 4 neighbors of to_cell to see if any were dug already
    neighbours = [ godown(to_cell), goup(to_cell), goleft(to_cell), goright(to_cell) ]

    # the cell we just came from is exempt
    neighbours.delete(from_cell)

    # filter the neighbors to any that are already dug
    neighbours.select! { |neighbor| isDug(neighbor) }

    # if none of the new neighbors are dug, we can dig
    neighbours.length == 0
  end

  def goleft(cell)
    return [cell[0]-1, cell[1]]
  end

  def goright(cell)
    return [cell[0]+1, cell[1]]
  end

  def goup(cell)
    return [cell[0], cell[1]-1]
  end

  def godown(cell)
    return [cell[0], cell[1]+1]
  end

  def find_char(cell)
    return @grid[(cell[1])][(cell[0])]
  end

  def dig(cell, marker)
    @grid[cell[1]][cell[0]] = marker
  end

  def isDug(cell)
    find_char(cell) == " " || find_char(cell) == "→" || find_char(cell) == "@"
  end

  def carve_way
    @cell_stack << [ @start_cell, @start_cell ]

    while @cell_visited.length < count_possible_cells
      # pop the current "from" position and mark it as visited
      break if @cell_stack.empty?
      cell_pair = @cell_stack.pop
      from_cell = cell_pair[0]
      to_cell = cell_pair[1]
      @cell_visited << to_cell

      # if the "from" position is still valid, dig
      if canDig(from_cell, to_cell)
        dig(to_cell, " ")
      end

      # if we were able to dig, try to keep digging from here
      if isDug(to_cell)
        # determine which neighbors are currently eligible for digging
        next_moves = [
          [ to_cell, godown(to_cell) ],
          [ to_cell, goup(to_cell) ],
          [ to_cell, goleft(to_cell) ],
          [ to_cell, goright(to_cell) ]
        ]
 
        next_moves.select! { |next_move| canDig(next_move[0], next_move[1]) }

        # puts "pushing next moves = #{next_moves}"
        @cell_stack.concat(next_moves.shuffle)
      end
    end
    @grid
  end

  def to_s
    flat_grid = ""
    @grid.each do |grid_row|
      flat_row = grid_row.join("") 
      flat_grid += flat_row + "\n" 
    end
    @flat_grid = flat_grid.chomp
  end
end