require "#{File.dirname(__FILE__)}/Loader.rb"
require 'pry-byebug'

class Maze
	# r rows, c columns
	# initialize a r*c sized rectangular maze will all cells surrounded by 4 walls
	def initialize(r, c)
		@num_row = r
		@num_colum = c
		@show_trace = false
		@maze_matrix = []
		@maze_size = [r, c]
		@mazes = []
		@start_point_coor = []
		@ending_point_coor = []
		(0...(2*r+1)).each do |i|
			row = [] # must generate a new row instance every iteration since ruby passes by reference
			(0...(2*c+1)).each do |k|
				row.push(k.even? ? 1 : 0) 
			end
			@maze_matrix.push(i.even? ? Array.new(2*c+1){1} : row)
		end
	end

	# generate a maze
	# if file_path is set, generate from file
	# if not set, generate a random maze
	def gen_maze(file_path = nil)
		if file_path != nil
			gen_from_file(file_path)
		else
			gen_random_maze
		end
	end

	def gen_random_maze
		@start_point_coor = cell2coor(rand(@num_row), rand(@num_colum))
		# set_coor_val(start_coor, "*")
		visited_cells = 0
		visited_cells_stack = []
		current_coor = @start_point_coor
		while visited_cells < @num_colum * @num_row - 1
			if find_intact_cell(current_coor).include?(0)
				went = go_random(current_coor)
				visited_cells_stack << current_coor
				current_coor = cell_adj(current_coor, "up") if went == 0
				current_coor = cell_adj(current_coor, "down") if went == 1
				current_coor = cell_adj(current_coor, "left") if went == 2
				current_coor = cell_adj(current_coor, "right") if went == 3
				visited_cells += 1
			else
				current_coor = visited_cells_stack.pop
			end
		end
		# last current_coor that has no empty cell around it is the ending point
		@ending_point_coor = current_coor
		# set_coor_val(ending_coor, "*")
	end

	def find_start_end_cell
		return [coor2cell(@start_point_coor), coor2cell(@ending_point_coor)]
	end

	# check if any intact cells around certain coordinate
	# if there are, go randomly into one cell
	# set the path wall to 0
	def go_random(coor)
		dir = find_intact_cell(coor)
		go = 0
		if dir.include?(0)
			while dir[go] == 1
				go = rand(4)
			end
			set_coor_val(coor_adj(coor, "up"), 0) if go == 0
			set_coor_val(coor_adj(coor, "down"), 0) if go == 1
			set_coor_val(coor_adj(coor, "left"), 0) if go == 2
			set_coor_val(coor_adj(coor, "right"), 0) if go == 3
			return go
		else
			return nil
		end
	end

	# find if there's a intact cell around certain coordinate
	# return an array representing accessibility of adjacent cells
	def find_intact_cell(coor)
		dir = [1,1,1,1]
		dir[0] = 0 if wall_intact?(cell_adj(coor, "up"))
		dir[1] = 0 if wall_intact?(cell_adj(coor, "down"))
		dir[2] = 0 if wall_intact?(cell_adj(coor, "left"))
		dir[3] = 0 if wall_intact?(cell_adj(coor, "right"))
		return dir
	end

	# return true if all walls around a coordinate are intact
	# if coor == [0, 0], then out of border, return false
	def wall_intact?(coor)
		return false if coor == [0, 0]
		return true if get_dir(coor) == [1,1,1,1]
	end

	# return the maze using a string of ones and zeros
	# if the string can form more than 1 possible mazes, result stored in a 2-d array
	# return false if the string cannot form a valid maze
	def gen_from_file(file_path)
		@mazes = Loader.load_file(file_path)
		if @mazes.size > 1
			puts "In this case, the string can generate more than one maze. Not implemented."
		elsif @mazes.size == 0
			puts "invalid maze string. File not loaded."
			return false
		else
			@maze_matrix = @mazes[0]
		end
	end

	# prints a diagram of the maze on the console. 
	# "|" starnds for wall, "o" stands for empty space, "*" stands for the cursor
	def display
		display_maze = @maze_matrix.map { |row| row.map  {|e| e == "*" ? "*" : e == 1 ? "|" : "o" }}
		display_maze.each {|row| print "#{row.join}\n"}
		puts
	end

	# convert the cell to matrix coordinate
	def cell2coor(r, c)
		return [2*r+1, 2*c+1]
	end

	def coor2cell(coor)
		return [(coor.first - 1) / 2, (coor.last - 1) / 2]
	end

	# return the value of the coordinate
	def get_coor_value(coor)
		# puts "get_coor_value: #{@maze_matrix[coor.first][coor.last]}"
		return @maze_matrix[coor.first][coor.last]
	end

	def set_coor_val(coor, val)
		@maze_matrix[coor.first][coor.last] = val
	end

	# didn't check border!!!
	# return the adjacent coordinate of a coordinate
	def coor_adj(coor, dir)
		case dir
		when "up" 
			return [coor.first - 1, coor.last]
		when "down" 
			return [coor.first + 1, coor.last]
		when "left" 
			return [coor.first, coor.last - 1]
		when "right" 
			return [coor.first, coor.last + 1]
		end
	end

	# return the adjacent cell of a coordinate
	# if out of border, return [0, 0]
	def cell_adj(coor, dir)
		case dir
		when "up"
			return [coor.first - 2, coor.last] if coor.first - 2 > 0
		when "down"
			return [coor.first + 2, coor.last] if coor.first + 2 < 2 * @num_row + 1
		when "left"
			return [coor.first, coor.last - 2] if coor.last - 2 > 0
		when "right"
			return [coor.first, coor.last + 2] if coor.last + 2 < 2 * @num_colum + 1
		end
		return [0, 0]
	end

	# get the possible directions of a coordinate
	# return [0, 0, 0, 0] if all four paths are free. 1 if path blocked
	# [0, 0, 0, 0] stands for "up", "down", "left", "right"
	def get_dir(coor)
		# coor = cell2coor(r, c) a coor or a cell??
		dir = [1, 1, 1, 1]
		dir[0] = 0 if get_coor_value(coor_adj(coor, "up")) == 0
		dir[1] = 0 if get_coor_value(coor_adj(coor, "down")) == 0
		dir[2] = 0 if get_coor_value(coor_adj(coor, "left")) == 0
		dir[3] = 0 if get_coor_value(coor_adj(coor, "right")) == 0
		# puts "dir of #{coor} is : #{dir}"
		return dir
	end

	# determines if there’s a way to walk from a specified beginning position to a specified ending position
	# if there is, return the array of path coordinates
	# if no, return empty array
	def solve(begX, begY, endX, endY)
		start_point = Point.new(cell2coor(begX, begY), nil)
		ending_point = Point.new(cell2coor(endX, endY), nil)
		exit_reached = false
		queue = []
		queue.push(start_point)
		while !queue.empty? && !exit_reached
			point = queue.shift
			if point.coor == ending_point.coor
				exit_reached = true
			else
				@maze_matrix[point.coor.first][point.coor.last] = "*"
				dir = get_dir(point.coor)
				queue.push Point.new(coor_adj(point.coor, "up"), point) if dir[0] == 0
				queue.push Point.new(coor_adj(point.coor, "down"), point) if dir[1] == 0
				queue.push Point.new(coor_adj(point.coor, "left"), point) if dir[2] == 0
				queue.push Point.new(coor_adj(point.coor, "right"), point) if dir[3] == 0
			end
		end

		# after BFS, erase the traces in process of BFS
		erase_trace
		
		# display the trace if show_trace set true
		if exit_reached
			solution_path = []
			while point.parent
				solution_path.push(point.coor)
				point = point.parent
			end
			solution_path.push(start_point.coor)
			solution_path.reverse!
			erase_trace
			return solution_path
		else
			return []
		end
	end

	def trace(begX, begY, endX, endY)
		solution = solve(begX, begY, endX, endY)
		set_coor_val(cell2coor(begX, begY), "*") # set the begining and ending point as "*". Note, only modify this after maze is solved by solve()
		set_coor_val(cell2coor(endX, endY), "*")
		if !solution.empty?
			solution.each do |coor|
				@maze_matrix[coor.first][coor.last] = "*"
				display
				sleep(0.1)
			end
		else
			puts "This maze cannot be solved."
		end
		erase_trace
	end	

	# erase the trace during BFS, converting all "*" to 0
	def erase_trace
		@maze_matrix.each do |row|
			row.each do |e|
				e.to_s.gsub!("*", "0")
			end
			row.map!(&:to_i)
		end
	end

end

class Point
	attr_accessor :coor, :parent
	def initialize(coor, parent)
		@coor = coor
		@parent = parent
	end
end

maze = Maze.new(15,15)


# ***TEST***
# ------- Generate from file, unquote the code between -------
# maze.gen_maze("#{File.dirname(__FILE__)}/maze_string")
# maze.trace(0,0,3,3)
# ------- Generate from file, unquote the code between -------

# ------- Generate random maze, unquote the code between -------
maze.gen_maze()
start_end = maze.find_start_end_cell
maze.trace(start_end[0][0], start_end[0][1], start_end[1][0], start_end[1][1])
# ------- Generate random maze, unquote the code between -------