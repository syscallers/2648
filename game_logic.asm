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

	move $t0, $0	# Counter for outer loop
	move $t1, $0	# Counter for inner loop
	move $t2, $a0	# Current pointer
	move $t3, $0	# Number of items pushed onto the stack

	# For each column
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
				addi $t2, $t2, 16
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
