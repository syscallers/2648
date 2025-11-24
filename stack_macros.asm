# CS 2640.02 Final Project
# Avery King, Laila Tatum, Josh Guzman, and Shuvashree Basnet
# 11/12/2025-11/20/2025
#
# Stack-related macros to help make using the stack easier. Note that most of
# these macros expect the user to manually set $fp to the initial stack
# pointer.
#
# Note for check-in: these macros are unused as of now, but later we expect to
# use them.

# Pushes a word in a given register onto the stack.
#
# This macro pushes the value stored in '%reg' onto the top of the stack and
# then allocates an additional word on the stack.
#
# Parameters:
#   - %reg: The register to take data from and push onto the stack.
.macro push(%reg)
	sw %reg, ($sp)
	subi $sp, $sp, 4
.end_macro

# Pops a word from the top of the stack into a given register.
#
# This macro automatically deallocates the stack space after popping the
# topmost element off the stack.
#
# Parameters:
#   - %reg: The register to store the topmost element onto
.macro pop(%reg)
	lw %reg, ($sp)
	addi $sp, $sp, 4
.end_macro
