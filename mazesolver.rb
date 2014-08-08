
require 'pry'
require 'colorize'
require_relative 'mazegenerator'


class MazeSolver
attr_accessor :traveled_path, :node_queue, :visited_nodes, :maze, :solution_path, :matrix
  
  def initialize (num)
    maze= MazeGenerator.new(num)
    @maze = maze.to_s
    @traveled_path = [ ]
    @node_queue = [ ]
    @visited_nodes = [ ]
    @possible_nodes = [ ]
    @solution_path = [ ]
  end

  def matrix
    @matrix = @maze.split("\n").map do |row|
            row.strip.split("")
            end
  end

  def find_start
    self.matrix.each_index do |y| 
      x = self.matrix[y].index("→") 
      return [x,y] if x
    end
  end

  def find_end
    self.matrix.each_index do |y| 
      x = self.matrix[y].index( "@" ) 
      return [x,y] if x
    end
  end

  def valid?(move)
    find_char(move) != "█"
  end

  def goleft(move)
    return [move[0]-1,move[1]]
  end

  def goright(move)
    return [move[0]+1,move[1]]
  end

  def goup(move)
    return [move[0],move[1]+1]
  end

  def godown(move)
    return [move[0],move[1]-1]
  end

  def find_char(move)
    return self.matrix[move[1]][move[0]]
  end


  def solve
    @node_queue << self.find_start
    @traveled_path << [ self.find_start, self.find_start ]
    @visited_nodes << self.find_start
    found_exit = false

    while !@node_queue.empty? && !found_exit
      move = @node_queue.shift
      positions = [goright(move), goup(move), godown(move), goleft(move)]
      if positions.include?(self.find_end)
        @traveled_path <<  [ self.find_end, move ]
        found_exit = true
      else
        positions.each do |next_move|
          if valid?(next_move) && !@visited_nodes.include?(next_move)
            @visited_nodes << next_move
            if find_char(next_move) != "█"
              @node_queue << next_move
              @traveled_path <<  [ next_move, move ]
            end
          end
        end
      end
    end
    self.solution_path
    self.display_solution_path
  end


  def solution_path
    move_pair = @traveled_path.pop
    @solution_path << move_pair[0]
    @traveled_path.reverse!
    while move_pair[0] != self.find_start
      @traveled_path.each do |prev_pair|
        if prev_pair[0] == move_pair[1]
          @solution_path << prev_pair[0]
          move_pair = prev_pair
          break
        end
      end
    end
    @solution_path.reverse
  end

  def display_solution_path
    maze_array = self.matrix
    self.solution_path.each do |position|
      maze_array[position[1]][position[0]] =  "≡".colorize( :background => :red)
    end

    maze_array[self.find_start[1]][self.find_start[0]] = "→"
    maze_array[self.find_end[1]][self.find_end[0]] = "@"

    flat_maze = ""
    maze_array.each do |maze_row|
      flat_row = maze_row.join("")
      flat_maze += flat_row + "\n"
    end
    flat_maze = flat_maze.chomp
    puts flat_maze.colorize(:blue)
  end

end

maze = MazeSolver.new(50)
maze.solve