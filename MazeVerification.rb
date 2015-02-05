
# a module that helps verify whether a string can form a valid maze
# the length of the string must be the product of 2 odd numbers which are lager than 1
# solvability of the maze is not concerned
# ntoe: might have more than one valid combination
module MazeVerification

	# find odd factors larger than 1 of a number
	# return result in a 2-d array
	def MazeVerification.find_odd_factors(num)
    		facs = ((1..num).collect { |n| [n, num/n] if ((num/n) * n) == num && n.odd? && (num/n).odd?}.compact)
    		facs.select {|comb| comb if comb.first > 1 && comb.last > 1}
	end

	# devide the num_string into n*m form based on the facs
	# return result in a 2-d array
	def MazeVerification.devide_maze(num_string, facs)
		num_string.scan(/.{#{facs.last}}/)
	end	

	# verify if a num_string representing a row is valid. first and last element has to be 1
	def MazeVerification.valid_row?(num_string, row = nil)
		if row == "border"
			return true if num_string.match(/[^1]/).nil?
			return false
		else
			if num_string[0].to_i == 1 && num_string[-1].to_i == 1
			return true
		else
			return false
			end
		end
	end
end
