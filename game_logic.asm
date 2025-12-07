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
.include "stack_macros.asm"
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
shiftGameBoardDown:
	# set $s4 as outer loop counter
	li $s4, 0
	
	# set $s5 as arraypointer of current row ($a0)
	move $s5, $a0
	
outerLoop_Down:
	# if outer loop is 4, shift down
	bge $s4, 4, pushStack_Down
	
	# set $t4 as inner loop counter and $t5 as current pointer to tile
	li $t4, 0 
	move $t5, $s5
	
	combineTiles_Down:
		# PASS 1: COMBINE TILES THAT ARE NONZERO AND EQUAL
		# if loop counter is 3, go to endCombine_Down
		bge $t4, 3, endCombine_Down
		
		# load current tile into $t6
		lw $t6, ($t5)
			
		# load tile below current tile
		lw $t7, 16($t5)
		
		# if current tile is 0, skip
		beqz $t6, skipCombine_Down
		
		# if current tile and below tile are equal and both not zero, combine
		beq $t6, $t7, doCombine_Down
		
	doCombine_Down:
		# combine tiles
		mul $t6, $t6, 2	# doubles current value
		sw $t6, ($t4)	# saving updated value in current tile
		
		li $t7, 0	# set below tile value to 0
		sw $t7, 16($t4)	# store 0 into tile below
	skipCombine_Down:	
	# incrementing pointer and outer loop counter to move to next tile
		addi, $t1, $t1, 4	# moving to next tile by adding 4 to pointer
		addi $t4, $t4, 1	# add 1 to counter
	
	# loop back to combineDown
	j combineTiles_Down
		
	endCombine_Down:	# PASS 2: shifting all tiles down
		li $t4, 0	# resetting inner loop counter
		move $t5, $s5	# current tile pointer starts at $s7
		li $t7, 0	# num items pueshed onto stack
	
	pushStack_Down:
		# push nonzero tiles onto stack
		lw $t4, ($t5)

		# if tile is 0, skip tile
		beqz $t4, endPush_Down

		# else push tile onto stack
		push_word($t4)

		# increment num items in stack by 1
		addi $t7, $t7, 1
	endPush_Down:
		# increment array pointer to item below current item
		subi $t5, $t5, 4
		# increment loop counter
		addi $t4, $t4, 1
	
		# if loop counter < 4, loop again
		blt $t4, 4, pushStack_Down
		
	# if num items in stack is 0, skip pop
	beqz $t7, skipPop_Down
	
	li $t4, 0	# reset inner loop counter
	move $t5, $s7	# reset tile pointer to beginning of row
		
	popStack_Down:
		# pop elements
		pop_word($t7)
	
		sw $t7, ($t5)	# store item at start of row
		
		addi $t5, $t5, 4	# increment array pointer to next tile
		addi $t4, $t4, 1	# increment counter by 1
			
		# if loop counter less than num items in stack, continue loop
		blt $t4, $t6, popStack_Down
		
	# set remaining tiles to 0
	clearRemaining_Down:
		li $t7, 0	# reset to 0
		
		# if loop counter is 4, skip clear
		bge $t4, 4, skipClear_Down
			
		# set array tile to 0
		sw $t7, ($t5)
			
		# increment array pointer by 16
		addi $t5, $t5, 16
		# incrememnt loop counter by 1
		addi $t4, $t4, 1
		
		# loop 
		j clearRemaining_Down
	
	skipClear_Down:
	skipPop_Down:
		# increment array pointer by 16
		addi $t5, $t5, 16
		# incrememnt loop counter by 1
		addi $t4, $t4, 1
	
	# increment outer loop by 1
	addi $s4, $s4, 1
	# increment array pointer to next row
	addi $s5, $s5, 16
	
	# loop through outerLoop_Down label
	j outerLoop_Down
	
cleanup_Down:
	# return to main
	jr $ra
	

		
		
		
	
	
	
	
	
