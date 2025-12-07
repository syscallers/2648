# CS 2640.02
# 12/6/2025
# Shuvashree Basnet

# shifts gameboard down
shiftGameboardDown:
	push_word ($ra)	# saving return address in stack
	
	move $t0, $0	# outer loop counter
	move $t1, $0	# inner loop counter
	move $t2, $a0	# current pointer
	move $t3, $0	# num items pushed onto stack
	
	__rowTraverse:
		__pushStack:
			lw $t5, ($t2)	# getting current value and loading into t5
			
			# while t5 is 0, continue loop
			beqz $t5, __endloop
			
			# else push current val onto stack
			subi $sp, $sp, 4
			sw $t4, ($sp)
			addi $t3, $t3, 1
			
			__endLoop:
				addi $t2, $t2, 16
				addi $t1, $t1, 1
				blt $t1, 4, __pushStack
			
		# if no items in stack, return
		beqz $t3, __ret
		
		# else pop elements off stack and into each tile value
		move $t1, $0	# reset inner loop counter to 0
		move $t2, $a0	# reset current tile val pointer
		mul $t3, $t3, 4
		add $t4, $t4, $sp
		
		__popStack:
			# get current element from stack
			lw $t5, ($t4)
			
			# store current element into current row pointer
			sw $t5, ($t2)
			
			add $t2, $t2, 16 # incrementing current pointer to element below
			add $t4, $t4, 4
			blt $t1, $t3, __popStack
			
		__ret:
			# return to main
			pop_word($ra)
			jr $ra