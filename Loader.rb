
# load the maze from file
# helps verify whether a string can form a valid maze.
# the length of the string must be the product of 2 odd numbers which are lager than 1
# solvability of the maze is not concerned
# ntoe: might have more than one valid combination
module Loader
	class LoaderHelper
		attr_accessor :validation, :mazes
		def initialize(num_string)
			@num_string = num_string
			@mazes = []
			@facs = []
			@validation = false
		end

		# load the num_string into maze(s)
		def load_maze
			@facs = find_odd_factors(@num_string.size)
			return false if @facs == []
			@facs.each do |comb|
				maze = devide_maze(@num_string, comb)
				@mazes.push(maze) if valid_maze?(maze)
			end
			return @mazes
		end

		# check whether a maze is a valid maze by checking the rows
		def valid_maze?(maze)
			maze.each_with_index do |row, index|
				if index == 0 || index == maze.length - 1
					return false if !valid_row?(row, "border")
				else
					return false if !valid_row?(row)
				end
			end
			return true
		end

		# find odd factors larger than 1 of a number
		# return result in a 2-d array [[r1, c1], [r2, c2]...]
		def find_odd_factors(num)
	    		facs = ((1..num).collect { |n| [n, num/n] if ((num/n) * n) == num && n.odd? && (num/n).odd?}.compact)
	    		facs.select {|comb| comb if comb.first > 1 && comb.last > 1}
		end

		# devide the num_string into n*m form based on the size
		# size is one of the factor combinations [r, c]
		# return result in a 2-d array
		def devide_maze(num_string, size)
			num_string.scan(/.{#{size.last}}/).map {|e| e.split(//).map {|i| i.to_i}}
		end	

		# verify if a row is valid.
		# if the row is border, all its elements are 1
		# if not the border, first and last element has to be 1
		def valid_row?(row, which = nil)
			if which == "border"
				return row.grep(1).size == row.size ? true : false
			else
				return row[0] == 1 && row[-1] == 1 ? true : false
			end
		end
	end

	def Loader.load_file(file_path)
		num_string = open(file_path).read.chomp
		lh = LoaderHelper.new(num_string)
		return lh.load_maze
	end
end
