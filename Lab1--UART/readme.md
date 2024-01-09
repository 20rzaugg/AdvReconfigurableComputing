Goals:

Review concepts of digital design, including Finite State Machines, FIFOs, PLLs, serial communication, ASCII, VHDL, etc.
Learn how to use the Intel Pin Planner.
 

Using the DE10-Lite Development Board, the Adafruit 954 USB-to-Serial Device, and a laptop or desktop running a serial terminal (e.g. PuTTy), implement a serial communication stream.  Meet the following requirements:

Implement a UART on the FPGA, using VHDL, that operates with 8 data bits, 1 stop bit, no parity, no flow control, and 19,200 Baud.  The UART receiver should over-sample by 8.
Configure a serial terminal session on the computer to communicate with the same parameters.
Uppercase characters typed in to the terminal should be converted to lowercase by the FPGA and sent back to the computer.
Lowercase characters typed in to the terminal should be converted to uppercase by the FPGA and sent back to the computer.
Any non-alphabetic characters received by the FPGA should result in a response of 'E', meaning "error".
Use the pin-planner utility to configure the TX and RX pins on the FPGA appropriately.