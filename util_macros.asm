# CS 2640.02
#
# Author: Laila Tatum, Shuvashree Basnet
# Date: 11/23/2025
# Description: file containing macros for final project

#macro to print strings
.macro printStr(%str)
	li $v0, 4	#print a string
	la $a0, %str	#specify the string as string parameter
	syscall
.end_macro

#macro to print integers
.macro printInt(%int)
	li $v0, 1	#print a integer
	move $a0, %int	#specify the string as integer parameter
	syscall
.end_macro

#macro to print a random tile between null, 2, and 4
.macro printTile(%tileVal1, %tileVal2, %tileVal3)
	li $a1, 3	#set max bound to 3
    	li $v0, 42	#generates the random number
    	syscall
    	
    	move $t9, $a0	#save random integer to $t9
    	
    	beq $t9, 0, _printNull
    	beq $t9, 1, _printTwo
    	beq $t9, 2, _printFour
	    	
	#if we get 0, print null
    	_printNull:
    		printStr(%tileVal3)
    		j _endPrint
    	
    	#if we get 1, print 2
    	_printTwo:
    		printInt(%tileVal1)
    		j _endPrint
    	
    	#if we get 2, print 4
    	_printFour:
    		printInt(%tileVal2)
    		j _endPrint
    	
    	_endPrint:
    		#end the printTile macro
.end_macro

.macro printArr	# S - prints array that is stored in $s0
	.data
	tab: .asciiz "	"	#for formatting, tab space and next line
	nextLine: .asciiz "\n"
	.text
	main:
	li $v0, 1	# printing first element
	lw $a0, 0($s0)
	syscall
	printStr(tab)	# printing spacer
	
	li $v0, 1
	lw $a0, 4($s0)	# print second element
	syscall
	printStr(tab)	# print spacer
	
	li $v0, 1
	lw $a0, 8($s0)	# 3rd element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 12($s0)	# 4th element
	syscall
	
	printStr(nextLine)	# printing next line
	
	li $v0, 1
	lw $a0, 16($s0)	# 5th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 20($s0)	# 6th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 24($s0)	# 7th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 28($s0)	# 8th element 
	syscall
	
	printStr(nextLine)
	
	li $v0, 1
	lw $a0, 32($s0)	# 9th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 36($s0)	# 10th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 40($s0)	# 11th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 44($s0)	# 12 element 
	syscall
	
	printStr(nextLine) # printing next line
	
	li $v0, 1
	lw $a0, 48($s0)	# 13th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 52($s0)	# 14th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 56($s0) # 15th element + spacer
	syscall
	printStr(tab)
	
	li $v0, 1
	lw $a0, 60($s0) # 16th element
	syscall
	
	printStr(nextLine)	# printing next line
.end_macro
#macro to get string from user
.macro getStr(%buffer, %length, %result)
	li $v0, 8
	la $a0, %buffer
	li $a1, %length
	syscall
	move %result, $a0
.end_macro

#macro to get integer from user
.macro getInt(%result)
	li $v0, 5
	syscall
	move %result, $v0
.end_macro

