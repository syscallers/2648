#CS 2640.02

#Author: Laila Tatum, Shuvashree Basnet
#Date: 11/23/2025
#Description: file containing macros for final project

#macro to print strings
.macro printStr(%str)
	li $v0, 4	#print a string
	la $a0, %str	#specify the string as string parameter
	syscall
.end_macro

.macro printStrLit(%str)
.data
	_str: .asciiz %str
.text
	printStr(_str)
.end_macro

#macro to print integers
.macro printInt(%int)
	li $v0, 1	#print a integer
	move $a0, %int	#specify the string as integer parameter
	syscall
.end_macro

#macro to print a random tile between null, 2, and 4
.macro getTileVal(%tile)
	#store default tile values
	li $s1, 2
	
	#get a number between 0-2 to determine tile value
	li $v0, 42	#generates the random number
	li $a1, 3	#set max bound to 3
    	syscall
    	
    	move $s4, $a0	#save random integer to $s4
    	
    	beq $s4, 0, tileZero
    	beq $s4, 1, tileTwo
    	beq $s4, 2, tileFour
	    	
	#if we get 0, store null into the parameter
    	tileZero:
    		mul %tile, $s4, $s1
    		j end
    	
    	#if we get 1, store 2 into the parameter
    	tileTwo:
    		mul %tile, $s4, $s1
    		j end
    	
    	#if we get 2, store 4 into the parameter
    	tileFour:
    		mul %tile, $s4, $s1
    		j end
    	
    	end: #end the getTileVal macro
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

# multiplies arr value by 2
.macro mulByTwo(%val)
	mul %val, %val, 2
.end_macro

.macro printArr(%arr)	# prints array assuming array has 4 elements
	li $v0, 1
	la $a0, 0(%arr)
	syscall
	
	li $v0, 1
	la $a0, 4(%arr)
	syscall
	
	li $v0, 1
	la $a0, 8(%arr)
	syscall
	
	li $v0, 1
	la $a0 12(%arr)
	syscall
	
.end_macro