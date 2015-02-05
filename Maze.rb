require "#{File.dirname(__FILE__)}/MazeVerification.rb"

class Maze
	# r rows, c columns
	def initialize(r, c)
		@show_trace = false
		@maze_matrix = []
		@maze_matrix_size = [r, c]
		@mazes = []
		row = []
		(0...(2*c+1)).each do |i|
			row.push(1)
		end
		(0...(2*r+1)).each do |i|
			@maze_matrix.push(row)
		end
	end	

	# return the maze using a string of ones and zeros
	# if the string can form more than 1 possible mazes, result stored in a 2-d array
	# return false if the string cannot form a valid maze
	def load(num_string)
		facs = MazeVerification.find_odd_factors(num_string.size)
		return false if facs == []
		facs.each do |comb|
			rows = MazeVerification.devide_maze(num_string, comb)
			err = false
			rows.each_with_index do |row, index|
				if index == 0 || index == rows.length - 1
					if !MazeVerification.valid_row?(row, "border")
						err = true
						break
					end
				else
					if !MazeVerification.valid_row?(row)
						err = true
						break
					end
				end
			end
			@mazes.push(rows) if !err
		end
		return @mazes
	end

	def gen_maze(file_path = nil)
		if file_path != nil
			load(open(file_path).read.chomp)
			if @mazes.size > 1
				puts "In this case, the string can generate more than one maze. Not implemented."
			elsif @mazes.size == 0
				puts "invalid maze string. File not loaded."
				return false
			else
				temp_maze = []
				@maze_matrix.clear # 
				@mazes[0].each {|row| temp_maze.push(row.split(""))}
				@maze_matrix = temp_maze.map{|row| row.map {|e| e.to_i}}
			end
		else
			puts "Generate a random maze. Not implemented."
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

	# return the value of the coordinate
	def get_coor_value(coor)
		return @maze_matrix[coor.first][coor.last]
	end

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
		if !solution.empty?
			solution.each do |coor|
				@maze_matrix[coor.first][coor.last] = "*"
				display
				sleep(0.5)
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

maze = Maze.new(4,4)
maze.gen_maze("#{File.dirname(__FILE__)}/maze_string")

maze.trace(0,0,3,3)