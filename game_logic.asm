# CS 2640.02
# 12/5/2025
# Avery King and Laila Tatum
#
# Contains logic to shift the gameboard up, down, left, and right

# Used by shiftGameboardUp. DO NOT USE AS A STANDALONE FUNCTION.
__doubleTile:
	add $t1, $t1, $t2	# Double the previous tile value
	sw $t1, -16($a0)
	jr $ra

# Shifts the gameboard
#
# Parameters:
# - $a0: Pointer to the gameboard data
shiftGameboardUp:
	# This function works in 2 passes: combining tiles and actually shifting
	# tiles. First, we combine the tiles

	move $t0, $0		# Counter for outer loop
	move $t1, $0		# Counter for inner loop
	move $t2, $a0		# Current game data pointer (offset by 1 column)

	# Increment the current game data pointer by 16 so we start at the second tile
	addi $t2, $t2, 16

	# Pass 1: For each column starting off at the 2nd row, check the tile at the
	# previous row. If they are the same, multiple the previous tile and clear the
	# current tile.
	_combineTilesUp:
		__checkTilesUp:
			lw $t3, -16($t2)	# Previous tile's value
			lw $t4, ($t2)		# Current tile's value

			# If both tiles are NOT equal, continue the loop
			bne $t3, $t4, __endCheckTilesUp

			# Otherwise, double the previous tile's value, and write the updated tile
			# values to the game data in memory
			mul $t3, $t3, 2
			sw $t3, -16($t2)	# Update the previous tile
			sw $0, ($t2)		# Clear the current tile

			__endCheckTilesUp:
				addi $t1, $t1, 1	# Increment the inner loop counter
				add $t2, $t2, 16	# Go to the next tile value
				blt $t1, 3, __checkTilesUp

		addi $t0, $t0, 1	# Increment the outer loop counter
		subi $t2, $t2, 28
		blt $t0, 4, _combineTilesUp

	# Reset some registers
	move $t0, $0	# Reset the outer loop counter
	move $t1, $0	# Reset the inner loop counter
	move $t2, $a0	# Reset the game data pointer
	move $t3, $0	# Number of items pushed onto the stack

	# Pass 2: For each column, push the current tile's value onto the stack unless
	# it's zero. If it's zero, skip it.
	__rowTraverseUp:
		# Part 1: copy over non-zero elements onto the stack
		__copyStackUp:
			# Get the current element from the data pointer
			lw $t4, ($t2)

			# If the current element is equal to zero, skip it
			beqz $t4, __copyStackUpFinish

			# Otherwise, push it onto the stack
			push_word($t4)
			addi $t3, $t3, 1

			__copyStackUpFinish:
				addi $t1, $t1, 1	# Increment the inner loop counter
				addi $t2, $t2, 16	# Increment the tile value data pointer
				blt $t1, 4, __copyStackUp

		# Adjust $t2 after the loop. It will have been incremented beyond a valid
		# address at this point (exactly by 16 bytes). Also reset the inner loop
		# counter
		subi $t2, $t2, 16
		move $t1, $0

		# Next, check if we copied any elements to the stack. If so, continue to __padStack
		bge $t3, 1, __padStack

		# Otherwise, if we have copied 4 elements, skip padding the stack as we don't
		# need anymore elements.
		beq $t3, 4, __popStackUp

		# Finally, if we are still here, then we have pushed no elements onto the stack.
		# Subtract the current data pointer by 48 bytes and finish the loop
		subi $t2, $t2, 48
		j __rowTraverseUpFinish

		# Part 2: pad the stack with zeroes so we have 4 elements
		__padStack:
			push_word($0)
			addi $t3, $t3, 1
			blt $t3, 4, __padStack

		# Part 3: pop elements from the top of the stack into the current column.
		# Note that we start at the bottom of the current column as the top element
		# on the stack will be the last element in the current column and vice versa.
		__popStackUp:
			# Pop the current element off the stack and write it to the current tile
			pop_word($t3)
			sw $t3, ($t2)

			addi $t1, $t1, 1	# Increment the inner loop counter
			subi $t2, $t2, 16	# Decrement the current tile value pointer
			blt $t1, 4, __popStackUp

		__rowTraverseUpFinish:
			addi $t0, $t0, 1	# Increment the outer loop counter
			move $t1, $0		# Reset the inner loop counter
			addi $t2, $t2, 4	# Move over to the next column
			blt $t0, 4, __rowTraverseUp

	__retUp:
		# Finally, return back to the caller
		jr $ra

# Shifts the gameboard down.
#
# Parameters:
# - $a0: Pointer to the gameboard data
shiftGameboardDown:
	# This function works in 2 passes: combining tiles and actually shifting
	# tiles. First, we combine the tiles

	move $t0, $0		# Counter for outer loop
	move $t1, $0		# Counter for inner loop
	move $t2, $a0		# Current game data pointer (offset by 1 column)

	# Increment the current game data pointer by 16 so we start at the second tile
	addi $t2, $t2, 16

	# Pass 1: For each column starting off at the 2nd row, check the tile at the
	# previous row. If they are the same, multiply the current tile and clear the
	# previous tile.
	_combineTilesDown:
		__checkTilesDown:
			lw $t3, -16($t2)	# Previous tile's value
			lw $t4, ($t2)		# Current tile's value

			# If both tiles are NOT equal, continue the loop
			bne $t3, $t4, __endCheckTilesDown

			# Otherwise, double the current tile's value, and write the updated tile
			# values to the game data in memory
			mul $t4, $t4, 2
			sw $0, -16($t2)	# Clear the previous tile
			sw $t4, ($t2)	# Update the current tile

			__endCheckTilesDown:
				addi $t1, $t1, 1	# Increment the inner loop counter
				add $t2, $t2, 16	# Go to the next tile value
				blt $t1, 3, __checkTilesDown

		addi $t0, $t0, 1	# Increment the outer loop counter
		subi $t2, $t2, 28
		blt $t0, 4, _combineTilesDown

	# Reset some registers
	move $t0, $0		# Reset the outer loop counter
	move $t1, $0		# Reset the inner loop counter
	add $t2, $a0, 48	# Reset the game data pointer to the end of the first row
	move $t3, $0		# Number of items pushed onto the stack

	# Pass 2: For each column, push the current tile's value onto the stack unless
	# it's zero. If it's zero, skip it.
	# Note that each column is traversed in reverse order, from the bottom column
	# to the top.
	__rowTraverseDown:
		# Part 1: copy over non-zero elements onto the stack
		__copyStackDown:
			# Get the current element from the data pointer
			lw $t4, ($t2)

			# If the current element is equal to zero, skip it
			beqz $t4, __copyStackDownFinish

			# Otherwise, push it onto the stack
			push_word($t4)
			addi $t3, $t3, 1

			__copyStackDownFinish:
				addi $t1, $t1, 1	# Increment the inner loop counter
				subi $t2, $t2, 16	# Decrement the tile value data pointer
				blt $t1, 4, __copyStackDown

		# Adjust $t2 after the loop. It will have been incremented beyond a valid
		# address at this point (exactly by 16 bytes). Also reset the inner loop
		# counter
		addi $t2, $t2, 16
		move $t1, $0

		# If we have copied 4 elements, skip padding the stack as we don't need
		# anymore elements.
		beq $t3, 4, __popStackDown

		# Otherwise, check if we copied any elements to the stack. If so, continue to
		# __padStackDown
		bge $t3, 1, __padStackDown

		# Finally, if we are still here, then we have pushed no elements onto the stack.
		# Increment the current data pointer by 48 bytes and finish the loop.
		addi $t2, $t2, 64
		j __rowTraverseDownFinish

		# Part 2: pad the stack with zeroes so we have 4 elements
		__padStackDown:
			push_word($0)
			addi $t3, $t3, 1
			blt $t3, 4, __padStackDown

		# Part 3: pop elements from the top of the stack into the current column.
		# Note that we start at the bottom of the current column as the top element
		# on the stack will be the last element in the current column and vice versa.
		__popStackDown:
			# Pop the current element off the stack and write it to the current tile
			pop_word($t3)
			sw $t3, ($t2)

			addi $t1, $t1, 1	# Increment the inner loop counter
			addi $t2, $t2, 16	# Increment the current tile value pointer
			blt $t1, 4, __popStackDown

		__rowTraverseDownFinish:
			addi $t0, $t0, 1	# Increment the outer loop counter
			move $t1, $0		# Reset the inner loop counter
			subi $t2, $t2, 12	# Move over to the bottom of the next column
			blt $t0, 4, __rowTraverseDown

	__retDown:
		# Finally, return back to the caller
		jr $ra
