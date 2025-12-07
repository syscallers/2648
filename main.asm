# CS 2640.02
# Final project: write and test the basic game logic by using regular registers to simulate the combination and randomization
# of tiles in the game before implementing them into graphics

# Author: Laila Tatum, Shuvashree Basnet
# Date: 11/23/2025
# Description: create a program that:
	#1.) creates an array to hold the tile values
	#2.) use a random number generator to get tile values
	#3.) store the values into the gameboard array
	#4.) print the gameboard array values into a 4x4 grid
	#5.) prompt the user to "swipe" to combine tiles

.include "util_macros.asm"

#constants
.eqv TILE_TWO 	2	#default value for randomized tiles
.eqv TILE_FOUR 	4	#default value for randomized tiles
.eqv NULL_TILE	"null"	#default value for randomized tiles
.eqv FINAL_TILE 2048	#value of the tile needed to end the game

.data
#strings for formatting
tabSpacer: .asciiz "	"
newLine: .asciiz "\n"

#gameboard array; stores 16 elements of grid in array (4 elements per array)
gameboardArr: .space 64

#exit message
exitMessage: .asciiz "Exiting the game"

.text
main:
	#formatting for game board (4x4)
	li $t2, 0	#set $s0 as the horizontal loop counter
	li $t3, 0	#set $s1 as the vertical loop counter
	
	#save gameboard values array into $s0
	la $s7, gameboardArr
	jal storeArrVal
	
	#reset the loop counter and array pointer
	li $t2, 0
	la $s7, gameboardArr
	
	#print the array values to the console
	j printArrTiles
	
storeArrVal:
	#store the values into $s0 array
	getTileVal($t0)
	sw $t0, ($s7)
		
	#increment the loop counter and array pointer
	addi $t2, $t2, 1
	addi $s7, $s7, 4
	
	#if the loop counter hits 16, loop through the label again
	ble $t2, 16, storeArrVal
		
	#otherwise, return to the main lable
	jr $ra
		
printArrTiles:
	#store the tile value from the array in $t1
	lw $t1, ($s7)
	
	#print the tile
	printInt($t1)
		
	#print space between tiles
	printStr(tabSpacer)
		
	#increment the horizontal loop counter by 1
	addi $t2, $t2, 1
	
	#increment the array pointer by 4
	addi $s7, $s7, 4
		
	#if the row doesn't have 4 tiles,
	#  loop back through the printGameBoard label
	bne $t2, 4, printArrTiles
		
	#otherwise, move to the next line
	printStr(newLine)
		
	#reset the horizontal loop counter
	li $t2, 0
		
	#increment the vertical loop counter by 1
	addi $t3, $t3, 1
		
	#if the vertical loop counter hits 4,
	#  jump to the swipe label
	beq $t3, 4, swipe
		
	#loop through the printGameBoard label again
	j printArrTiles
	

swipe:	
	li $s3, 0	# register for empty val s3
	li $s4, 0	# resetting array pointer of surrrounding value to 0 s4
	la $s5, ($s7)	# resetting array pointer to 0 s5
	
	#get the direction the user wants to swipe based on
	#  given character
	li $v0, 12	#read a character
	syscall
	move $a0, $v0	#save given character to $a0
	
	#check which way player wants to swipe
	beq $a0, 'w', swipeUp		#if the user enters 'w', the board will swipe up
	beq $a0, 'a', swipeLeft		#if the user enters 'a', the board will swipe left
	beq $a0, 's', swipeDown		#if the user enters 's', the board will swipe down
	beq $a0, 'd', swipeRight	#if the user enters 'd', the board will swipe right
	
	multiplyTwo:	# multiplies arr value by 2 (might have to place this label somewhere else)
		mulByTwo($s4)
	tileBelow:	# adds 16 to array pointer ( supposed lead array pointer to element below current element)
		addi $s6, $s6, 16
	tileLeft:	# adds 4 to array pointer ( supposed to lead array pointer to element left of current element)
		addi $s7, $s7, 4
	swipeUp:
		#check the tiles for potential combination
		# if at end of 3rd row of array, go back to swipe
		bge $s7, 48, swipe
		#check the tiles for potential combination
		# if $s0 is less than of equal to 16, add 16 to $s0 to get array pointer to next row
		addi $t4, $s7, 16	# stores an arraypointer to the val below current val ($s7) in $t4 
		beq $s7, $t4, multiplyTwo	# if the current value and left of it are the same, multiply
		sw $t4, ($s7)	# value of current arr val is now 2*val
		sw $t5, ($t4)	# arr val below array pointer is now empty
		
		addi $s7, $s7, 4	# incrementing array pointer by 4
		j swipeUp
	swipeDown:
		#check the tiles for potential combination
		# if at end of array, go back to swipe
		beq $s7, 64, printArrTiles
		lw $s6, ($s7)	# loading word located at current array pointer into s6
		ble $s6, 12, tileBelow	# if arraypointer (element) is on the first row, add 16 to array to go to next row
		subi $s4, $s6, -16	# array pointer for value above array pointer of current value is saved to $t4
		beq $s6, $s4, multiplyTwo # if current value and the value right under it are the same, the value below it becomes 2*val
		move $s6, $s4  # value of current val now 2*val
		li $s4, 0
		
		addi $s7, $s7, 4	# increment array pointer by 4
		j swipeDown
		
		
	swipeLeft:
		# if at end of array, go back to swipe
		beq $s7, 64, printArrTiles
		#check the tiles for potential combination
		# if array pointer $s7 is 0, 16, 32, or 48, (rightmost elements) add 4 to $s7 to move array pointer to element that is on left side of current element
		beq $s7, 0, tileLeft
		beq $s7, 16, tileLeft
		beq $s7, 32, tileLeft
		beq $s7, 48, tileLeft
		subi $t4, $s7, 4	# stores arraypointer to right of current val ($s7) in $t4 
		beq $s7, $t4, multiplyTwo	# if the current value and left of it are the same, multiply right tile by 2
		move $s7, $t4	# save $t4 (multiplied value) to current array pointer value (* not sure if i should do move or sw)
		move $t4, $t5	# arr val to right of current val now empty
		
		addi $s7, $s7, 4	# incrementing array pointer by 4
		j swipeLeft
		
	swipeRight:
		#check the tiles for potential combination
		# if at end of array, go back to swipe
		beq $s7, 64, swipe
		#check the tiles for potential combination
		# if $s7 is 12, 28, or 44 (leftmost tiles) add 4 to arraypointer
		beq $s7, 12, tileLeft
		beq $s7, 28 tileLeft
		beq $s7, 44, tileLeft
		addi $t4, $s7, 4	# stores arraypointer left of current val ($s7) in $t4 
		beq $s7, $t4, multiplyTwo	# if the current value and left of it are the same, multiply
		move $t4, $s7	# value to right of current arr val is now 2*val
		move $s7, $t5	# current arr val now empty
		
		addi $s7, $s7, 4	# incrementing array pointer by 4
		j swipeRight
	
	#check if there are no remaining tiles
	#if so, jump to the exit label to end the game
	beq $s7, 64, exit
	#otherwise, loop back through the main label
	j main
exit:
	#print the exit message
	printStr(exitMessage)
	
	#exit the program
	li $v0, 10
	syscall
