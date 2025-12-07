# CS 2640.02

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

#macro to print a random tile value between 0, 2, and 4
.macro generateVal(%tile)
	#get a number between 0-2 to determine tile value
	li $v0, 42	#generates the random number
	li $a1, 3	#set max bound to 3
    	syscall
    	
    	#multiply the random integer by 2 and store
	#the product in %tile
    	mul %tile, $a0, $2
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
