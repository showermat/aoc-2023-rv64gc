This repository implements Advent of Code day 1, part 1 in RISC-V bare-metal assembly.  It targets `rv64gc` and expects to run atop an SBI implementation (so arguably not *as* bare-metal as it could be).

`baselib.s` contains a variety of utility functions that take the place of a standard library.  `main.s` implements the Advent of Code solution.

The code, when run, reads lines of text on the debug console input, makes two-digit numbers by combining the first and last digit on each line, and adds them all together.  When you indicate the end of input by providing a blank line, it prints the accumulated sum to the debug console and halts the machine.

If you have the RISC-V GCC toolchain and RISC-V QEMU installed, you should be able to compile and run the code simply by executing `run.sh`, although you may need to adjust the path to the SBI binary in that file first.  Of course, the built file `kernel.elf` should run as an SBI payload on real RISC-V 64GC hardware as well.  Please enjoy using it on your soldering iron.
