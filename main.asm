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

#gameboard array; stores 16 elements of grid in array
gameboardArr: .space 64

#exit message
exitMessage: .asciiz "Exiting the game"

.text
main:
	#formatting for game board (4x4)
	li $t2, 0	#set $t0 as the horizontal loop counter
	li $t3, 0	#set $t1 as the vertical loop counter
	
	#save gameboard values array into $s0
	la $s0, gameboardArr
	jal storeArrVal
	
	#reset the loop counter and array pointer
	li $t2, 0
	la $s0, gameboardArr
	
	#print the array values to the console
	j printArrTiles
	
storeArrVal:
	#store the values into $s0 array
	getTileVal($t0)
	sw $t0, ($s0)
		
	#increment the loop counter and array pointer
	addi $t2, $t2, 1
	addi $s0, $s0, 4
	
	#if the loop counter hits 16, loop through the label again
	ble $t2, 16, storeArrVal
		
	#otherwise, return to the main lable
	jr $ra
		
printArrTiles:
	#store the tile value from the array in $t1
	lw $t1, ($s0)
	
	#print the tile
	printInt($t1)
		
	#print space between tiles
	printStr(tabSpacer)
		
	#increment the horizontal loop counter by 1
	addi $t2, $t2, 1
	
	#increment the array pointer by 4
	addi $s0, $s0, 4
		
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
	beq $t3, 4, exit
		
	#loop through the printGameBoard label again
	j printArrTiles
	

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
