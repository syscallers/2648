# CS 2640.02
# Final project: write and test the basic game logic by using regular registers to simulate the combination and randomization
# of tiles in the game before implementing them into graphics
#
# Author: Laila Tatum, Shuvashree Basnet
# Date: 11/23/2025

.include "util_macros.asm"

#constants
.eqv TILE_TWO 	2	#default value for randomized tiles
.eqv TILE_FOUR 	4	#default value for randomized tiles
.eqv FINAL_TILE 2048	#value of the tile needed to end the game

.data
#strings for formatting
tabSpacer: .asciiz "	"
newLine: .asciiz "\n"
# array
arr: .space 64	# S - stores 16 elements of grid in array

#null tile string
nullTile: .asciiz "null"

#exit message
exitMessage: .asciiz "Exiting the game"

.text
main:
	#save the default tile values to registers
	li $t0, TILE_TWO	#$t0 will store 2
	li $t1, TILE_FOUR	#$t1 will store 4
	
	#formatting for game board (4x4)
	li $t2, 0	#set $t0 as the horizontal loop counter
	li $t3, 0	#set $t1 as the vertical loop counter
	
	printGameBoard:
		#output the values onto the game board
		la $s0, arr	# S - loading array into $s0
		printTile($t0, $t1, nullTile)	
		beq $t9, 1, multByTwo	# S - saving random value, if == 1, multiply by 2
		beq $t9, 2, multByTwo	# S - saving random value, if == 2, multiply by 2
		sw $t9, 0($s0)		# stores value into arr[0]
		printTile($t0, $t1, nullTile)		
		beq $t9, 1, multByTwo	# S - saving random value, if == 1, multiply by 2
		beq $t9, 2, multByTwo	# S - saving random value, if == 2, multiply by 2
		sw $t1, 4($s0)		# ERROR - stores value into arr[1], won't work if $t0 is replaced by $t9
		printArr	# S - prints array
		
		
		
		#print space between tiles
		#printStr(tabSpacer)
		
		#increment the horizontal loop counter by 1
		#addi $t2, $t2, 1
		
		#if the row doesn't have 4 tiles,
		#  loop back through the printGameBoard label
		#bne $t2, 4, printGameBoard
		
		#otherwise, move to the next line
		#printStr(newLine)
		
		#reset the horizontal loop counter
		#li $t2, 0
		
		#increment the vertical loop counter by 1
		#addi $t3, $t3, 1
		
		#if the vertical loop counter hits 4,
		#  jump to the swipe label
		#beq $t3, 4, swipe
		
		#loop through the printGameBoard label again
		#j printGameBoard
	
	#randomizing tiles for game board
multByTwo:
	# S- multiplies random value stored in $t9 by 2
	mul $t9, $t9, 2
swipe:	
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
	
	swipeUp:
		#check the tiles for potential combination
	swipeDown:
		#check the tiles for potential combination
		
	swipeLeft:
		#check the tiles for potential combination
		
	swipeRight:
		#check the tiles for potential combination
	
	#check if there are no remaining tiles
	#if so, jump to the exit label to end the game
	
	#otherwise, loop back through the main label
	
exit:
	#print the exit message
	printStr(exitMessage)
	
	#exit the program
	li $v0, 10
	syscall

