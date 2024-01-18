.equ BUFSIZE, 128

.section .bss

buf: .zero BUFSIZE


.section .text

main:
	call init

	li a0, 0x0a
	call putch

	li s0, 0 # s0 is our accumulator

main_loop:
	# Read a line of text
	la a0, buf
	li a1, BUFSIZE
	call readline

	# Put its length into s1 and break if it's empty
	la a0, buf
	call strlen
	beqz a0, main_done
	mv s1, a0

	# Put the first digit into s2
	la a0, buf
	call finddigit
	mv s2, a0

	# Reverse the string and put the last digit into s3
	la a0, buf
	mv a1, s1
	call rev
	la a0, buf
	call finddigit
	mv s3, a0

	# Add the digits into the accumulator s0
	li t0, 10
	mul s2, s2, t0
	add s2, s2, s3
	add s0, s0, s2
	j main_loop

main_done:
	# Convert the assumulator to ASCII
	mv a0, s0
	la a1, buf
	li a2, BUFSIZE
	call itoa

	# Print
	la a0, buf
	call print

	li a0, 0x0a
	call putch

	call halt

# Return the first digit in null-terminated string at address a0
finddigit:
	addi sp, sp, -16
	sd ra, 0(sp)

finddigit_loop:
	lb t0, 0(a0)
	beqz t0, finddigit_none

	addi a0, a0, 1

	li t1, 0x30 # First ASCII digit
	blt t0, t1, finddigit_loop
	li t1, 0x39 # Last ASCII digit
	bgt t0, t1, finddigit_loop

	# Otherwise, it's a digit
	addi a0, t0, -0x30
	j finddigit_done

finddigit_none:
	# No digit found; return zero
	li a0, 0
finddigit_done:
	ld ra, 0(sp)
	addi sp, sp, 16
	ret
