# CS 2640.02 Final Project
# Avery King, Laila Tatum, Josh Guzman, and Shuvashree Basnet
# 11/12/2025-11/20/2025
#
# Graphics routines for driving the bitmap display.
#
# Note: coordinates have their own unique way of storage to be space efficient.
# You may use the create_coordinate, get_x_value, and get_y_value macros to
# deal with coordinates. See create_coordinate's documentation for more details
# about how coordinates are represented.
.include "stack_macros.asm"

# Creates a coordinate from two 16-bit unsigned immediate integers and store
# them in a single destination register.
#
# The X-value of the coordinate is stored in the upper 16 bits of a register,
# while the Y-value is stored in the lower 16 bits of a register.
#
# The purpose of storing coordinates this way is due to the limited number of
# argument registers available to use. Using drawRectangle as an example, we
# would normally store all our information in 5 registers. We can easily use a
# stack, but to avoid memory access, we pack coordinates into a single register
# and unpack them that way.
#
# Parameters:
# - %x: The 16-bit immediate X value
# - %y: The 16-bit immediate Y value
# - %reg: The destination register to store the result
.macro create_coordinate(%x, %y, %reg)
	# First, load the upper 16-bits of '%reg' with the X-value
	lui %reg, %x

	# Then, OR the value in %reg with the Y-value
	ori %reg, %reg, %y
.end_macro

# Loads the X value from a coordinate in a given register and save its result
# in another given register.
#
# Parameters:
# - %coor: The register containing the coordinate
# - %dest: The destination register to store the X value in
.macro get_x_value(%coor, %dest)
	# Shift %coor to the right 16 bits to get the X value
	# Note: the 'srl' instruction also clears the lower 16-bits automatically, so
	# we don't need to worry about clearing any upper bits after the fact
	srl %dest, %coor, 16
.end_macro

# Loads the Y value from a coordinate in a given register and save its result
# in another given register.
#
# Parameters:
# - %coor: The register containing the coordinate
# - %dest: The destination register to store the Y value in
.macro get_y_value(%coor, %dest)
	# Clear the upper 16-bits while preserving the lower 16-bits
	# Turns out CS 1300 came in really handy ;)
	and %dest, %coor, 0x0000FFFF
.end_macro

# Converts an (x,y) coordinate point to a memory address
#
# Parameters:
# - %src: The source register containing the coordinate point value
# - %dst: The destination register to store the converted coordinate point
.macro coordinate_to_address(%src, %dst)
	# To get the starting address, first get the X value of the current coordiante
	# and convert it to a memory address. Store it all in $t0 also.
	get_x_value(%src, %dst)
	mul %dst, %dst, 4
	add %dst, %dst, $gp

	# Then, shift the memory address down y times
	get_y_value(%src, $t1)
	mul $t1, $t1, 2048
	add %dst, %dst, $t1
.end_macro

# Draws a horizontal or vertical 1 px line onto the bitmap display.
#
# All lines drawn by this function are either horizontal or vertical. Diagonal
# lines are NOT supported
#
# Parameters:
# - $a0: Starting memory address (must be converted from a coordinate beforehand)
# - $a1: Length of the line (in pixels)
# - $a2: Color of the line
# - $a3: Set to 1 (or any value really) to draw vertically, otherwise for
# horizontally.
drawLine:
	# First, copy $a0 to $t0 so we don't modify our argument
	move $t0, $a0

	# Then, determine how much we increment our current display pointer by. If we
	# are drawing a vertical line, we increment it by 2048 bytes as that moves
	# the display pointer down to the next root. Otherwise, we increment it by 4
	# bytes as it moves the display pointer to the next column.
	bnez $a3, _drawVertical
	j _drawHorizontal
	_drawVertical:
		li $t1, 2048
		j _drawContinue

	_drawHorizontal:
		li $t1, 4

	_drawContinue:
		# Next, find the end address of the line. We will draw up to this point
		# (inclusive). Do this by multiply the number of bytes we will increment our
		# display pointer by ($t1) by the length of the line ($a1). Then, add our
		# starting display pointer address ($t0) to it.
		mul $t2, $t1, $a1
		add $t2, $t2, $t0

		# While we're not at the end pointer, draw to the display
		loop:
			sw $a2, ($t0)
			add $t0, $t0, $t1
			blt $t0, $t2, loop

	# Finally, return to the caller
	jr $ra

# Draws a given number onto the bitmap display.
#
# Each number is drawn rectangularly as an 8x15 character with 1px of padding
# around it. No conversion to a string is needed before hand.
#
# Parameters:
# - $a0: The starting coordinate to draw the number
# - $a1: The integer to draw. Must be greater than or equal to 1.
# - $a2: The color of the number
drawNumber:
	# First, we need to reverse our number so the order of digits are flipped. For
	# example, if we have the number 2048, we need to flip it so its 8402. To do
	# this, keep dividing the value of $a1 (our number to print) by 10, storing
	# the quotient there as well. Then, continue doing that until our quotient is
	# zero. Meanwhile, get the remainder, add it to $t1, and multiply $t1 by 10.
	# Also, at the same time, keep a counter for the number of digits we are going
	# to print out in case we encounter a number divisible by 10.
	li $t0, 10
	move $t1, $0	# Contains the reversed number temporarily
	move $t3, $0	# Number of digits
	_reverseNum:
		# First, multiply our result by $t1. Do this in case we encounter a number
		# divisible by 10, such as 10 or 100.
		mul $t1, $t1, 10

		# Then, divide our number by 10, store the quotient in $a1, and store the
		# remainder in $t2.
		div $a1, $t0	# $a1 / 10
		mflo $a1	# Get the quotient
		mfhi $t2	# Get the remainder

		# Add the remainder to $t1
		add $t1, $t1, $t2

		# Add to the number of digits
		addi $t3, $t3, 1

		# Continue until our quotient is zero
		bnez $a1, _reverseNum

	# Next, setup some registers
	move $s1, $t1	# Copy our flipped number here. $a1 gets discarded later
	coordinate_to_address($a0, $s0)
	move $s2, $0	# Current digit
	move $s3, $0	# Counter
	move $s4, $t3	# Number of total digits to draw
	li $s5, 10	# Number to divide by

	# Save the current return address onto the stack too. It will get overwritten
	# when we make a call to drawLine
	push_word($ra)

	_drawLoop:
		# To get the least significant digit, we can use the 'div' instruction and
		# then the 'mfhi' to get the remainder (stored in HI)
		div $s1, $s5
		mflo $s1	# Get the quotient
		mfhi $s2	# Get the remainder

		# Draw the current digit
		beqz $s2, _drawZero
		beq $s2, 1, _drawOne
		beq $s2, 2, _drawTwo
		beq $s2, 3, _drawThree
		beq $s2, 4, _drawFour
		beq $s2, 5, _drawFive
		beq $s2, 6, _drawSix
		beq $s2, 7, _drawSeven
		beq $s2, 8, _drawEight
		beq $s2, 9, _drawNine

		# Draws three lines, one at the top, another in the middle, and another at
		# the bottom. Used in numbers 2, 3, 5, 6, and 8
		#
		# Note: be sure to call with jal
		_drawMiddleLines:
			# Push the current return address onto the stack
			push_word($ra)

			# Setup our arguments and counter
			move $a0, $s0
			li $a1, 8
			move $t3, $0	# Counter
			__loop:
				jal drawLine
				add $a0, $a0, 14336	# Move the display pointer down 7 px (14336 bytes)
				addi $t3, $t3, 1
				blt $t3, 3, __loop

			# Return back to the caller
			pop_word($ra)
			jr $ra

		# Zero case
		#
		# Draw two horizontal lines across the top and bottom, respectively, and then
		# draw two vertical lines on the left and right sides, respectively.
		_drawZero:
			# First draw the top
			move $a0, $s0
			li $a1, 8
			move $a3, $0
			jal drawLine

			# Then draw the left side
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Now draw the bottom
			addi $a0, $a0, 28672	# Move the display pointer down 14 rows (2048 * 14 = 28672)
			li $a1, 8
			move $a3, $0
			jal drawLine

			# Finally, move the cursor back to its original spot and increment that
			# address by 8 pixels
			addi $a0, $s0, 32	# (8 * 4 = 32)
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Exit this case
			j _continue

		# One case
		#
		# The easiest case out there. Just draw a straight 15 px vertical line from
		# our current display pointer down.
		_drawOne:
			# Only draw the left side. First move the cursor over by 15 and draw a
			# vertical line
			move $a0, $s0
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Offset the display pointer by 7 px (28 bytes)
			subi $s0, $s0, 28

			# Exit this case
			j _continue

		# Two case
		#
		# This case involves drawing 3 lines in the middle and then drawing two
		# vertical lines in between the first two middle lines and the last two ones,
		# each on opposing sides.
		_drawTwo:
			# Start with 3 middle lines
			jal _drawMiddleLines

			# Then, move the display cursor to the far right 7 px (28 bytes) and draw a
			# vertical line there
			add $a0, $s0, 28
			li $a1, 8
			li $a3, 1
			jal drawLine

			# Finally, move the display cursor down 7 px (14336 bytes) and draw an 8px
			# vertical line
			add $a0, $s0, 14336
			li $a1, 8
			jal drawLine

			# Exit this case
			j _continue

		# Three case
		#
		# This case involves drawing 3 middle lines and drawing a vertical line on
		# the right. Most work is done in _drawMiddleLines.
		_drawThree:
			# Start with 3 middle lines
			jal _drawMiddleLines

			# Then draw a vertical line towards the far right
			add $a0, $s0, 28	# Move display pointer 7 px (28 bytes)
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Exit this case
			j _continue

		# Four case
		#
		# Draws an 8 px vertical line on the left, then an 8 px horizontal line
		# across, and finally a 15 px vertical line on the right.
		_drawFour:
			# First, draw an 8 px vertical line towards the left
			move $a0, $s0
			li $a1, 8
			li $a3, 1
			jal drawLine

			# Then, draw an 8 px horizontal line after moving the display pointer down
			# 7 px (14336 bytes)
			add $a0, $a0, 14336
			move $a3, $0
			jal drawLine

			# Finally, draw a vertical line to the left
			add $a0, $s0, 28	# Move display pointer right 7 px (28 bytes)
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Exit this case
			j _continue

		# Five case
		#
		# Much like the two case, except we draw the first vertical line to the left
		# and the second vertical line to the right
		_drawFive:
			# Start with 3 middle lines
			jal _drawMiddleLines

			# Then, reset the display cursor and draw a vertical line there
			move $a0, $s0
			li $a1, 8
			li $a3, 1
			jal drawLine

			# Finally, move the display cursor down 7 px (14336 bytes) and over 7 px (28
			# bytes) and draw an 8px vertical line
			add $a0, $s0, 14364	# 14336 + 28 = 14364
			li $a1, 8
			jal drawLine

			# Exit this case
			j _continue

		# Six case
		#
		# Also uses 3 middle lines, drawing a 15 px line on the right and an 8 px
		# line on the right.
		_drawSix:
			# Start with 3 middle lines
			jal _drawMiddleLines

			# Then, reset the display cursor and draw a 15 px vertical line there
			move $a0, $s0
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Finally, move the display cursor to the far right (7 px or 28 bytes) and
			# down 7 px (14336 bytes) and draw an 8 px vertical line there
			add $a0, $s0, 14364	# 14336 + 28 = 1434 bytes
			li $a1, 8
			jal drawLine

			# Exit this case
			j _continue

		# Seven case
		#
		# This is perhaps the second most easiest branch out of all the numbers. We
		# just draw a line across the top and a line on the right side.
		_drawSeven:
			# First, draw the top
			move $a0, $s0
			li $a1, 8
			jal drawLine

			# Finally, draw the right side
			add $a0, $a0, 28
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Exit this case
			j _continue

		# Eight case
		#
		# This could be drawn like a 0, but the code is much easier to read if we
		# instead draw the middle lines first and then 2 vertical lines on each side.
		_drawEight:
			# First, draw the 3 middle lines
			jal _drawMiddleLines

			# Then, draw the left vertical line
			move $a0, $s0
			li $a1, 15
			li $a3, 1
			jal drawLine

			# Finally, draw the right vertical line
			add $a0, $a0, 28
			jal drawLine

			# Exit this case
			j _continue

		# Nine case
		_drawNine:
			# First, draw the top
			move $a0, $s0
			li $a1, 8
			jal drawLine

			# Next, draw the left vertical line
			li $a3, 1
			jal drawLine

			# Do the same thing but on the right side and the line height is 15 px
			add $a0, $a0, 28
			li $a1, 15
			jal drawLine

			# Finally, draw the middle line
			add $a0, $s0, 14336	# Move the display pointer down 7 px (14336 bytes)
			li $a1, 8
			move $a3, $0
			jal drawLine

		_continue:
			# Move the display pointer over by 10 px (40 bytes)
			add $s0, $s0, 40

			# Clear $a3 if it was set
			move $a3, $0

			# Increment our counter and continue as long as our counter is less than the
			# number of digits
			addi $s3, $s3, 1
			blt $s3, $s4 _drawLoop

	# Finally, restore the return address and return to the caller
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

# Draws a rectangle onto the bitmap display.
#
# Be sure to call with jal as this returns back to the caller.
#
# Parameters
#   - $a0: Starting coordinate (see the create_coordinate macro for details)
#   - $a1: Width
#   - $a2: Height
#   - $a3: Color
drawRectangle:
	# First, convert our coordinate point to an address (stored in $t0)
	coordinate_to_address($a0, $t0)

	# Next, figure out how many bytes we are going to write to each row of the
	# display (stored in $t1). Also find the end address of the current row 
	# (stored in $t2).
	mul $t1, $a1, 4
	add $t2, $t0, $t1

	# Finally, find the end address of the entire rectangle
	mul $t3, $a2, 2048
	add $t3, $t3, $t2

	# Now begin the actual drawing
	# Note: we don't use drawLine here for performance reasons. Calling drawLine
	# in a loop would mean it would have to continuously perform
	# coordinate-to-address over and over again.
	drawHeight:
		drawWidth:
			# Write the color to memory
			sw $a3, ($t0)

			# Increment our display pointer ($t0)
			addi $t0, $t0, 4

			# Continue as long as we're not at the ending address
			blt $t0, $t2, drawWidth

		# Reset $t0 back to its beginning address
		sub $t0, $t0, $t1

		# Move the current and ending display pointers down one row
		add $t0, $t0, 2048
		add $t2, $t2, 2048

		# Continue drawing until we've hit the rectangle's ending address
		blt $t2, $t3, drawHeight

	# Once we're all done, simply return to the caller
	jr $ra
