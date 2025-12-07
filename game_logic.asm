#CS 2640.02
#final project: write and test the basic game logic by using regular registers to simulate the combination and randomization
#of tiles in the game before implementing them into graphics

#Author: Laila Tatum, Avery King
#Date: 12/5/2025
#Description: contains logic to shift the gameboard up, down, left, and right

.include "stack_macros.asm"

#insert code for shiftUp

#insert code for shiftDown

#shifts the gameboard left
shiftGameboardLeft:
	#push the return address, row counters, and temporary 
	#register for state/logic onto the stack
	push_word($ra)	#save the return address
	push_word($s6)  #save row index counter
	push_word($s7)  #save row start pointer
	push_word($s5)  #save a temporary register for state/logic

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
		lw $t3, 4($t1)
		
		#if current tile is 0, skip combination
		beqz $t2, skipCombine_Left 
		
		#if current and next tile are equal and non-zero, combine them
		beq $t2, $t3, doCombine_Left

		#otherwise, jump to the skipCombine_Left label
		j skipCombine_Left 
		
	doCombine_Left:
		#combine tiles
		mul $t2, $t2, 2		#double the current tile value
		sw $t2, ($t1)		#store the new value to the current tile
		
		li $t3, 0		#clear the next tile value
		sw $t3, 4($t1)		#store the 0 into the next tile
		
		#increment the pointer and counter
		addi $t1, $t1, 8    #skip the current and the cleared tile
		addi $t0, $t0, 2    #increment counter by 2
		
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
	li $t1, 0	#inner loop counter
	move $t2, $s7	#current tile pointer starts at $s7
	li $t3, 0	#number of items pushed onto the stack

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
		addi $t2, $t2, 4
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
	#restore registers
	pop_word($s5)
	pop_word($s7)
	pop_word($s6)
	pop_word($ra)
	
	#return to the caller
	jr $ra
	
#shifts the gameboard right
shiftGameboardRight:
	#push the return address, row counters, and temporary 
	#register for state/logic onto the stack
	push_word($ra)	#save the return address
	push_word($s6)  #save row index counter
	push_word($s7)  #save row start pointer
	push_word($s5)  #save a temporary register for state/logic

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
		lw $t3, -4($t1)
		
		#if current tile is 0, skip combination
		beqz $t2, skipCombine_Right
		
		#if current and next tile are equal and non-zero, combine them
		beq $t2, $t3, doCombine_Right

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
	#restore registers
	pop_word($s5)
	pop_word($s7)
	pop_word($s6)
	pop_word($ra)
	
	#return to the caller
	jr $ra
