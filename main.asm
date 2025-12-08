# CS 2640.02
# Final project: write and test the basic game logic by using regular registers to simulate the combination and randomization
# of tiles in the game before implementing them into graphics

# Author: Laila Tatum, Shuvashree Basnet, Avery King
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

.eqv KEYBOARD_CHECK_KEY		0xFFFF0000	# Address with whether or not we have a key press
.eqv KEYBOARD_CHAR_PRESSED	0xFFFF0004	# Address of the actual character pressed

.data
	# Gameboard array; stores 16 elements of grid in array
	gameboardData: .space 64

	#exit message
	exitMessage: .asciiz "Exiting the game"

.text
main:
	# Test case. Remove when we get proper random number generation done
	la $t0, gameboardData
	li $t2, 2
	addi $t0, $t0, 20	# 2nd row, 2nd column
	sw $t2, ($t0)
	addi $t0, $t0, 16	# Move down 1 column
	sw $t2, ($t0)

	# Draw the initial gameboard
	la $a0, gameboardData
	jal drawGameboard

mainLoop:
	# First, check if we have a key press. If we do, handle it. Otherwise, loop
	# main
	lw $t0, KEYBOARD_CHECK_KEY
	beq $t0, 1, keyPress
	j mainLoop

keyPress:
	# Get the key of the key press
	lw $t0, KEYBOARD_CHAR_PRESSED

	# Handle the escape key
	beq $t0, 0x1B, exit

	# Handle WASD keys
	la $a0, gameboardData
	beq $t0, 'w', moveUp
	beq $t0, 'a', moveLeft
	beq $t0, 's', moveDown
	beq $t0, 'd', moveRight

	# Update the gameboard
	# Note: there's no need to erase the screen as the old tiles will
	# automatically get erased when we redraw them.
	jal drawGameboard

	# Go back to main to keep the loop
	j mainLoop

moveUp:
	jal shiftGameboardUp
	j mainLoop

moveLeft:
	# TODO: Shift gameboard left
	j mainLoop

moveDown:
	# TODO: Shift gameboard down
	j mainLoop

moveRight:
	# TODO: Shift gamebaord right
	j mainLoop

exit:
	# Exit the program
	li $v0, 10
	syscall

# Include this last or else the program will start at the wrong location. Also,
# leave these in the order they are included.
.include "stack_macros.asm"
.include "game_logic.asm"
.include "graphics.asm"
