# CS 2640.02 Final Project
# Avery King, Laila Tatum, Josh Guzman, and Shuvashree Basnet
# 11/12/2025-11/20/2025
#
# Graphics routines for driving the bitmap display.

# Draws a rectangle onto the bitmap display.
#
# Be sure to call with jal as this returns back to the caller.
#
# Parameters
#   - $s0: X coordinate
#   - $s1: Y coordinate
#   - $s2: Width
#   - $s3: Height
#   - $s4: Color
drawRectangle:
	# To get the starting address, first convert the starting coordinate to a
	# memory address (stored in $t0).
	mul $t0, $s0, 4
	add $t0, $t0, $gp

	# Then, shift the memory address down y times
	mul $t1, $s1, 2048	# $t1 is used as a temporary here
	add $t0, $t0, $t1

	# Next, figure out how many bytes we are going to write to each row of the
	# display (stored in $t1). Also find the end address of the current row ($t2).
	mul $t1, $s2, 4
	add $t2, $t0, $t1

	# Finally, setup our counter for the outer loop
	move $t3, $0

	# Now begin the actual drawing
	drawHeight:
		drawWidth:
			# Write the color to memory
			sw $s4, ($t0)

			# Increment our display pointer ($t0)
			addi $t0, $t0, 4

			# Continue as long as we're not at the ending address
			blt $t0, $t2, drawWidth

		# Reset $t0 back to its beginning address
		sub $t0, $t0, $t1

		# Move the current and ending display pointers down one row
		add $t0, $t0, 2048
		add $t2, $t2, 2048

		# Increment our counter
		addi $t3, $t3, 1

		# Continue drawing until we've hit the end of the painting region
		blt $t3, $s3, drawHeight

	# Once we're all done, simply return to the caller
	jr $ra
