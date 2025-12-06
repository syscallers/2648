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
	push_word($ra)	# Save the return address onto the stack

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
	_combineTiles:
		__checkTiles:
			lw $t3, -16($t2)	# Previous tile's value
			lw $t4, ($t2)		# Current tile's value

			# If both tiles are NOT equal, continue the loop
			bne $t3, $t4, __endCheckTiles

			# Otherwise, double the previous tile's value, and write the updated tile
			# values to the game data in memory
			mul $t3, $t3, 2
			sw $t3, -16($t2)	# Update the previous tile
			sw $0, ($t2)		# Clear the current tile

			__endCheckTiles:
				addi $t1, $t1, 1	# Increment the inner loop counter
				add $t2, $t2, 16	# Go to the next tile value
				blt $t1, 3, __checkTiles

		addi $t0, $t0, 1	# Increment the outer loop counter
		blt $t0, 4, __combineTiles

	# Reset some registers
	move $t1, $0	# Reset the inner loop counter
	move $t2, $a0	# Reset the game data pointer
	move $t3, $0	# Number of items pushed onto the stack

	# Pass 2: For each column, push the current tile's value onto the stack unless
	# it's zero. If it's zero, skip it.
	__rowTraverse:
		__pushStack:
			# Get the current tile value
			lw $t5, ($t2)

			# If $t4 is equal to zero, continue the loop
			beqz $t5, __endLoop

			# Otherwise, push the current tile value onto the stack
			subi $sp, $sp, 4
			sw $t4, ($sp)
			addi $t3, $t3, 1

			__endLoop:
				addi $t2, $t2, 16	# Increment the game data pointer
				addi $t1, $t1, 1
				blt $t1, 4, __pushStack

		# If there are no items allocated onto the stack, return
		beqz $t3, __ret

		# Otherwise, pop elements off the stack and into each tile value
		move $t1, $0		# Reset the inner loop counter
		move $t2, $a0		# Reset the current tile value pointer
		mul $t4, $t3, 4
		add $t4, $t4, $sp	# $t4 will initially point to the bottom of the stack

		__popStack:
			# Get the current element off the stack
			lw $t5, ($t4)

			# Store that element into the current row pointer
			sw $t5 ($t2)

			# Increment both the stack and current tile value pointers
			add $t2, $t2, 16
			add $t4, $t4, 4
			blt $t1, $t3, __popStack

	__ret:
		# Finally, return back to the caller
		pop_word($ra)
		jr $ra
