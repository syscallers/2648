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
		blt $t0, 4, _combineTiles

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

#shifts the gameboard left
shiftGameboardLeft:
	#set $s6 as the outer loop counter
	li $s6, 0
	
	#set $s7 as the array pointer starting at the current row
	move $s7, $a0
	
outerLoop_Left:
	#if the outer loop counter hits 4, jump to cleanup_Left
	bge $s6, 4, cleanup_Left
	
	#set $t0 and $t1 as a loop counter and current pointer
	li $t0, 0	#inner loop counter
	move $t1, $s7	#pointer to current tile
	
	combineTiles_Left:
		#if loop counter hits 3, jump to endCombine_Left
		bge $t0, 3, endCombine_Left
		
		#load current tile
		lw $t2, ($t1)
		
		#load next tile
		lw $t9, 4($t1)
		
		#if current tile is 0, skip combination
		beqz $t2, skipCombine_Left 
		
		#if current and next tile are equal and non-zero, combine them
		beq $t2, $t9, doCombine_Left

		#otherwise, jump to the skipCombine_Left label
		j skipCombine_Left 
		
	doCombine_Left:
		#combine tiles
		mul $t2, $t2, 2		#double the current tile value
		sw $t2, ($t1)		#store the new value to the current tile
		
		li $t9, 0		#clear the next tile value
		sw $t9, 4($t1)		#store the 0 into the next tile
		
		#increment the pointer and counter
		addi $t1, $t1, 8	#skip the current and the cleared tile
		addi $t0, $t0, 2	#increment counter by 2
		
		#return to the combineTiles_Left label
		j combineTiles_Left

	skipCombine_Left:
		#move to the next tile
		addi $t1, $t1, 4    #increment pointer by 4
		addi $t0, $t0, 1    #increment counter by 1
		
		#return to the combineTiles_Left label
		j combineTiles_Left

	endCombine_Left:
	#PASS 2: shift the tiles to the left
	
	#reset the counters and pointers
	li $t1, 0		#inner loop counter
	addi $t2, $s7, 12		#current tile pointer starts at $s7
	li $t3, 0		#number of items pushed onto the stack

	pushStack_Left:
		#push non-zero tiles onto stack
		lw $t4, ($t2)

		#if the tile is 0, skip the tile
		beqz $t4, endPush_Left

		#otherwise, push the tile onto the stack
		push_word($t4)
		
		#increment the number of items pushed by 1
		addi $t3, $t3, 1

	endPush_Left:
		#increment the array pointer and loop counter
		subi $t2, $t2, 4
		addi $t1, $t1, 1
		
		#if the loop counter is less than 4,
		#loop through the pushStack_Left label again
		blt $t1, 4, pushStack_Left

	#if there are no items allocated onto the stack, skip pop
	beqz $t3, skipPop_Left

	#reset the loop counter and array pointer
	li $t1, 0		#reset the inner loop counter
	move $t2, $s7		#reset the array tile value pointer to row start

	popStack_Left:
		#pop elements off the stack
		pop_word($t5)
		
		#write them to the start of the row
		sw $t5, ($t2)

		#increment the array pointer and loop counter
		addi $t2, $t2, 4
		addi $t1, $t1, 1
		
		#if the loop counter is less than number of items pushed,
		#loop through the popStack_Left label again
		blt $t1, $t3, popStack_Left

	#clear remaining tiles (if $t3 < 4)
	clearRemaining_Left:
		#reset $t5 to 0
		li $t5, 0
		
		#if the loop counter hit 4, jump to the
		#skipClear_Left label
		bge $t1, 4, skipClear_Left 
		
		#set the array tile to 0
		sw $t5, ($t2)
		
		#increment the array pointer and loop counter
		addi $t2, $t2, 4
		addi $t1, $t1, 1
		
		#loop through the clearRemaining_Left label
		j clearRemaining_Left

	skipClear_Left:
	skipPop_Left:
		
	#increment the outer loop and current array pointer
	addi $s7, $s7, 16
	addi $s6, $s6, 1
	
	#loop through the outerLoop_Left label
	j outerLoop_Left

cleanup_Left:
	#return to the caller
	jr $ra
	
#shifts the gameboard right
shiftGameboardRight:
	#set $s6 as the outer loop counter
	li $s6, 0
	
	#set $s7 as the array pointer starting at the current row
	move $s7, $a0
	
outerLoop_Right:
	#if the outer loop counter hits 4, jump to cleanup_Right
	bge $s6, 4, cleanup_Right
	
	#set $t0 and $t1 as a loop counter and current pointer
	li $t0, 0		#inner loop counter
	addi $t1, $s7, 12	#pointer to current tile
	
	combineTiles_Right:
		#if loop counter hits 3, jump to endCombine_Right
		bge $t0, 3, endCombine_Right
		
		#load current tile
		lw $t2, ($t1)
		
		#load next tile
		lw $t9, -4($t1)
		
		#if current tile is 0, skip combination
		beqz $t2, skipCombine_Right
		
		#if current and next tile are equal and non-zero, combine them
		beq $t2, $t9, doCombine_Right

		#otherwise, jump to the skipCombine_Right label
		j skipCombine_Right 
		
	doCombine_Right:
		#combine tiles
		mul $t2, $t2, 2		#double the current tile value
		sw $t2, ($t1)		#set the previous tile value to 0
		
		li $t9, 0		#set $t9 to 0
		sw $t9, -4($t1)		#store 0 into the left tile
		
		#increment the pointer and counter
		subi $t1, $t1, 8    #skip the current and the cleared tile
		addi $t0, $t0, 2    #increment counter by 2
		
		#return to the combineTiles_Right label
		j combineTiles_Right

	skipCombine_Right:
		#move to the next tile
		subi $t1, $t1, 4    #increment pointer by 4
		addi $t0, $t0, 1    #increment counter by 1
		
		#return to the combineTiles_Right label
		j combineTiles_Right

	endCombine_Right:
	#PASS 2: shift the tiles to the right
	
	#set the counters and pointers
	li $t1, 0		#inner loop counter
	addi $t2, $s7, 12	#current tile pointer starts at $s7
	li $t3, 0		#number of items pushed onto the stack

	pushStack_Right:
		#push non-zero tiles onto stack
		lw $t4, ($t2)

		#if the tile is 0, skip the tile
		beqz $t4, endPush_Right

		#otherwise, push the tile onto the stack
		push_word($t4)
		
		#increment the number of items pushed by 1
		addi $t3, $t3, 1

	endPush_Right:
		#increment the array pointer and loop counter
		subi $t2, $t2, 4
		addi $t1, $t1, 1
		
		#if the loop counter is less than 4,
		#loop through the pushStack_Right label again
		blt $t1, 4, pushStack_Right

	#if there are no items allocated onto the stack, skip pop
	beqz $t3, skipPop_Right

	#reset the loop counter and array pointer, and set the stack pointer
	li $t1, 0		#reset the inner loop counter
	addi $t2, $s7, 12	#reset the array tile value pointer to row start
	
	popStack_Right:
		#pop elements off the stack
		pop_word($t5)
		
		#write them to the start of the row
		sw $t5, ($t2)

		#increment the array pointer and loop counter
		subi $t2, $t2, 4
		addi $t1, $t1, 1
		
		#if the loop counter is less than number of items pushed,
		#loop through the popStack_Right label again
		blt $t1, $t3, popStack_Right

	#clear remaining tiles (if $t3 < 4)
	clearRemaining_Right:
		#reset $t5 to 0
		li $t5, 0
		
		#if the loop counter hit 4, jump to the
		#skipClear_Left label
		bge $t1, 4, skipClear_Right 
		
		#set the array tile to 0
		sw $t5, ($t2)
		
		#increment the array pointer and loop counter
		subi $t2, $t2, 4
		addi $t1, $t1, 1
		
		#loop through the clearRemaining_Left label
		j clearRemaining_Right

	skipClear_Right:
	skipPop_Right:
		
	#increment the outer loop and current array pointer
	addi $s7, $s7, 16
	addi $s6, $s6, 1
	
	#loop through the outerLoop_Left label
	j outerLoop_Right

cleanup_Right:
	#return to the caller
	jr $ra
