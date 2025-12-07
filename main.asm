#CS 2640.02
#final project: write and test the basic game logic by using regular registers to simulate the combination and randomization
#of tiles in the game before implementing them into graphics

#Author: Laila Tatum, Shuvashree Basnet
#Date: 11/23/2025
#Description: create a program that:
	#1.) creates an array to hold the tile values
	#2.) use a random number generator to get tile values
	#3.) store the values into the gameboard array
	#4.) print the gameboard array values into a 4x4 grid
	#5.) prompt the user to "swipe" to combine tiles

.include "util_macros.asm"
.include "game_logic.asm"

#constants
.eqv FINAL_TILE 2048	#value of the tile needed to end the game

.data
#strings for formatting
tabSpacer: .asciiz "	"
newLine: .asciiz "\n"

#gameboard array; stores 16 elements of grid in array
gameboardArr: .space 64

#swipe message
swipePrompt: .asciiz "Enter one of the following characters to swipe:\n(w)Up\n(a) Left\n(s) Down\n(d) Right\n"

#exit messageciiz 
exitMessage: .asciiz "\nExiting the game.\n"

.text
main:
	#set $sp to the highest address in the user stack segment
	li $sp, 0x7ffffffc
	
	#create the initial gameboard array
	jal storeIntArrVal

game:
	#print the array values to the console
	jal printArrTiles
	
	#start swiping the tiles
	jal swipe
	
	#check for game over
	jal checkTiles
	
	#if game isn't over, loop through the game label
	beqz $v0, game
	
	#if the game is over, jump to the game over label
	j game_over
	
game_over:
	#jump to the exit label
    	j exit
	
storeIntArrVal:
	#save the old value of $ra and $s0 in the stack
	addi $sp, $sp, -8
   	sw $ra, 4($sp)
   	sw $s0, 0($sp)
   	
	#formatting for game board (4x4)
	li $t2, 0	#set $t2 as the horizontal loop counter
	li $t3, 0	#set $t3 as the vertical loop counter
	
	#save gameboard values array into $s0
	la $t5, gameboardArr
	
	storeIntArrVal_loop:
		#store the values into $s0 array
		generateVal($t0)
	
		#store tile values in the array
		sw $t0, ($t5)
		
		#increment the loop counter and array pointer
		addi $t2, $t2, 1
		addi $t5, $t5, 4
		
		#reset $t0 for the next generation
		li $t0, 0
		
		#if the loop counter hits 16, loop through the label again
		blt $t2, 16, storeIntArrVal_loop
		
		#otherwise, return to the main label
		j storeIntArrVal_end
	
	storeIntArrVal_end:
		#restore $ra and $s0 from the stack
		lw $s0, 0($sp)
		lw $ra, 4($sp)
		
		#deallocate stack space
    		addi $sp, $sp, 8
    
		#return to the game label
		jr $ra
		
printArrTiles:
	#save the olde value of $ra and $s0 in the stack
	addi $sp, $sp, -8
   	sw $ra, 4($sp)
   	sw $s0, 0($sp)
   	
	#reset the loop counter and array pointer
	li $t2, 0
	li $t3, 0
	la $t5, gameboardArr
	
	printArrTiles_loop:
		#store the tile value from the array in $t1
		lw $t1, ($t5)
	
		#print the tile
		printInt($t1)
		
		#print space between tiles
		printStr(tabSpacer)
		
		#increment the horizontal loop counter by 1
		addi $t2, $t2, 1
	
		#increment the array pointer by 4
		addi $t5, $t5, 4
		
		#if the row doesn't have 4 tiles,
		#  loop back through the printGameBoard label
		bne $t2, 4, printArrTiles_loop
		
		#otherwise, move to the next line
		printStr(newLine)
		
		#reset the horizontal loop counter
		li $t2, 0
		
		#increment the vertical loop counter by 1
		addi $t3, $t3, 1
		
		#if the vertical loop counter hits 4,
		#  jump to the endPrint label
		beq $t3, 4, printArrTiles_end
		
		#loop through the printGameBoard label again
		j printArrTiles_loop
	
	printArrTiles_end:
		#restore $ra and $s0 from the stack
		lw $s0, 0($sp)
		lw $ra, 4($sp)
		
		#deallocate stack space
    		addi $sp, $sp, 8
    		
		#jump back to main label
		jr $ra
	
swipe:	
	#save the olde value of $ra and $s0 in the stack
	addi $sp, $sp, -8
   	sw $ra, 4($sp)
   	sw $s0, 0($sp)
   	
	#reset the array pointer and counter
	la $s0, gameboardArr
	li $t2, 0
	li $t3, 0
	
	#prompt the user to swipe
	printStr(swipePrompt)
	
	#get the direction the user wants to swipe based on given character
	li $v0, 12	#read a character
	syscall
	move $a0, $v0	#save given character to $a0
	
	#check which way player wants to swipe
	beq $a0, 'w', swipeUp		#if the user enters 'w', the board will swipe up
	beq $a0, 'a', swipeLeft		#if the user enters 'a', the board will swipe left
	beq $a0, 's', swipeDown		#if the user enters 's', the board will swipe down
	beq $a0, 'd', swipeRight	#if the user enters 'd', the board will swipe right
	
	#jump to end if invalid key is entered
	j swipe_end
	
	#check the tiles for potential combination
	swipeUp:
		#move the gameboard array to $a0
		move $a0, $s0
		
		#jump to shift gameboard up
		#jal shiftGameboardUp
		
		#jump to the end of the swipe label
		j swipe_end
		
	swipeDown:
		#move the gameboard array to $a0
		move $a0, $s0
		
		#jump to shift gameboard down
		#jal shiftGameboardDown
		
		#jump to the end of the swipe label
		j swipe_end
		
	swipeLeft:
		#move the gameboard array to $a0
		move $a0, $s0
		
		#jump to shift gameboard left
		jal shiftGameboardLeft
		
		#jump to the end of the swipe label
		j swipe_end
		
	swipeRight:
		#move the gameboard array to $a0
		move $a0, $s0
		
		#jump to shift gameboard right
		#jal shiftGameboardRight
		
		#jump to the end of the swipe label
		j swipe_end
		
	swipe_end:
		#restore $ra and $s0 from the stack
		lw $s0, 0($sp)
		lw $ra, 4($sp)
		
		#deallocate stack space
    		addi $sp, $sp, 8
    		
		#return to main label
		jr $ra
	
#check if there are no remaining tiles
checkTiles:
	#save the olde value of $ra and $s0 in the stack
	addi $sp, $sp, -8
   	sw $ra, 4($sp)
   	sw $s0, 0($sp)
   	
	#reset counter and array pointer
	li $t2, 0
	la $s0, gameboardArr

	checkTiles_loop:
		#check all 16 tiles
		bge $t2, 16, checkTiles_full
		
		#load the current tile value
		lw $t1, ($s0)
	
		#if the tile is empty, the game continues
		beqz $t1, checkTiles_continue 
			
		#check for the winning tile and end game
		li $t9, FINAL_TILE
		beq $t1, $t9, checkTiles_win 
	
		#increment the counter and array pointer
		addi $t2, $t2, 1
		addi $s0, $s0, 4
		
		#loop through the checkTiles loop
		j checkTiles_loop

	checkTiles_continue:
		#a zero tile was found, game is NOT over
		li $v0, 0
		
		#jump to the checkTiles_end label
		j checkTiles_end

	checkTiles_win:
		#found the 2048 file
    		li $v0, 2
    		
    		#jump to the checkTiles_end label
		j checkTiles_end
    
	checkTiles_full:
		#since all 16 tiles are full, game's over
	   	li $v0, 1
	    	
	checkTiles_end:
		#restore $ra and $s0 from the stack
		lw $s0, 0($sp)
		lw $ra, 4($sp)
		
		#deallocate stack space
    		addi $sp, $sp, 8
	    
	    	#return the game label
	    	jr $ra
	
exit:
	#print the exit message
	printStr(exitMessage)
	
	#exit the program
	li $v0, 10
	syscall
