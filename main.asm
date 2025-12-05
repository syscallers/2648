# CS 2640.02
# Final project: write and test the basic game logic by using regular registers to simulate the combination and randomization
# of tiles in the game before implementing them into graphics

# Author: Laila Tatum, Shuvashree Basnet, Josh Guzman, Avery King
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
.eqv NULL_TILE	0	#default value for randomized tiles
.eqv FINAL_TILE 2048	#value of the tile needed to end the game

#register EQVs
.eqv hLoopCounter $t2
.eqv vLoopCounter $t3
.eqv arrPtr $s0

.data
tabSpacer: .asciiz "	"
newLine: .asciiz "\n"

#gameboard array; stores 16 elements of grid in array 
gameboardArr: .space 64 #16 elements x 4 bytes

#exit message
exitMessage: .asciiz "Exiting the game"

.text
main:
	#formatting for game board (4x4)
	li hLoopCounter, 0	#set hLoopCounter register = 0
	li vLoopCounter, 0	#set vLoopCounter register = 0
	
	#save gameboard values array into $s0 which will be our array pointer
	la arrPtr, gameboardArr
	
	#fill all array values to 0
	fillEmptyBoard
	
	#print every value in array
	
	jal storeArrVal
	
	# reset everything before printing
    	la arrPtr, gameboardArr      # back to start of array
    	li hLoopCounter, 0
    	li vLoopCounter, 0

	#print the array values to the console
	j printArrTiles
	
storeArrVal:
	#store the values into base address
	getTileVal($t0)
	sw $t0, (arrPtr) #store value of $t0 into location of array pointer
		

	addi hLoopCounter, hLoopCounter, 1 # hLoopCounter++
	addi arrPtr, arrPtr, 4 # arrPtr += 4
	
	#if the loop counter hits 16, loop through the label again
	blt hLoopCounter, 16, storeArrVal
		
	#otherwise, return to the main lable
	jr $ra
		
printArrTiles:

	lw $t1, (arrPtr) #store tile value from the array in $t1
	
	printInt($t1)	#print the tile
	
	printStr(tabSpacer)	#print space between tiles
		
	addi hLoopCounter, hLoopCounter, 1 #hLoopCounter++
	addi arrPtr, arrPtr, 4		#arrPtr += 4
		
	#if the row doesn't have 4 tiles,
	# loop back through the printGameBoard label
	bne hLoopCounter, 4, printArrTiles
		
	#otherwise, move to the next line
	printStr(newLine)
		
	#reset the horizontal loop counter
	li hLoopCounter, 0
		
	#increment the vertical loop counter by 1
	addi vLoopCounter, vLoopCounter, 1
		
	#if the vertical loop counter hits 4,
	#  jump to the swipe label
	beq vLoopCounter, 4, exit
		
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
