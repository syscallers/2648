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
# - $a0: Starting coordinate (see the create_coordinate macro for details)
# - $a1: Length of the line (in pixels)
# - $a2: Color of the line
# - $a3: Set to 1 (or any value really) to draw vertically, otherwise for
# horizontally.
drawLine:
	# First, convert the coordinate point into a memory address and store the
	# result in $t0.
	coordinate_to_address($a0, $t0)

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
