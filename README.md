# 2648
https://github.com/syscallers/2648

This is a version of 2048 written in MIPS assembly. It works under the MARS simulator. It was made for our CS 2640 class, and hence the name.

## To Run
Open the `main.asm` file in MARS and assemble it. Then, go to Tools > Bitmap Display. In the Bitmap Display Window, ensure that both the display width and height are both set to '512'. Also be sure to set the base address to "0x10040000 (heap)". Leave all other settings the same and press the "Connect to MIPS" button.

Next, in the main MARS window, go to Tools > Keyboard and Display MMIO Simulator. Leave all settings in the window the same as press the "Connect to MIPS" button.

Finally, press the run button. The game will start and you can use any of the WASD keys to move up, left, down, and right, respectively. Ensure you type them in the Keyboard and Display MMIO Simulator windows to ensure the game receives them.

Enjoy! :D
