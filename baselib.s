.global init
.global puts
.global strlen
.global print
.global halt
.global putch
.global getch
.global rev
.global itoa
.global readline

.equ STACKSIZE, 4096

.section .bss

stack: .zero STACKSIZE
curchar: .dword 0


.section .text

init:
	# Set stack pointer
	la sp, stack
	li t0, STACKSIZE
	add sp, sp, t0
	ret

halt:
	li a7, 0x53525354
	li a6, 0
	li a0, 0
	li a1, 0
	li a2, 0
	ecall

# Print the string at address a1 with length a0
puts:
	addi sp, sp, -16
	sd ra, 0(sp)
	li a7, 0x4442434e
	li a6, 0
	li a2, 0
	ecall
	ld ra, 0(sp)
	addi sp, sp, 16
	ret

# Calculate the length of the zero-terminated string at a0
strlen:
	li t0, 0
strlen_loop:
	lb t1, 0(a0)
	beqz t1, strlen_end
	addi t0, t0, 1
	addi a0, a0, 1
	j strlen_loop
strlen_end:
	mv a0, t0
	ret

# Print the string at address a0
print:
	addi sp, sp, -16
	sd ra, 0(sp)

	sd a0, 8(sp)
	call strlen
	ld a1, 8(sp)
	call puts

	ld ra, 0(sp)
	addi sp, sp, 16
	ret

# Reverse the bytes at address a0 with length a1
rev:
	li t0, 1
	ble a1, t0, rev_done
	add a1, a0, a1 # a1 holds end index, a0 holds start
	addi a1, a1, -1
rev_loop:
	ble a1, a0, rev_done
	lb t0, 0(a0)
	lb t1, 0(a1)
	sb t0, 0(a1)
	sb t1, 0(a0)
	addi a0, a0, 1
	addi a1, a1, -1
	j rev_loop
rev_done:
	ret

# Convert the integer in a0 into a null-terminated string in the array starting at address a1 with length a2
# We build the string backwards, going from left to right from low to high digits.  Then we append a minus sign if necessary and reverse the string.
itoa:
	addi sp, sp, -16
	sd ra, 0(sp)
	# Handle zero- and one-byte output buffer, and zero argument
	blez a2, itoa_ret
	li t1, 1
	mv t3, a1 # t3 holds current byte storage address
	beq a2, t1, itoa_null
	beqz a0, itoa_zero

	# Set up registers
	li t1, 0 # tl holds negative number flag
	li t2, 10 # t2 holds the conversion base
	addi t4, a2, -1 # t4 holds the number of remaining bytes the string can fit

	# Adjust values if argument is negative
	bgtz a0, itoa_loop
	li t1, 1
	sub a0, x0, a0
	addi t4, t4, -1

itoa_loop:
	blez t4, itoa_loopend
	rem t0, a0, t2 # t0 holds current digit
	addi t0, t0, 0x30
	sb t0, 0(t3)
	addi t3, t3, 1
	div a0, a0, t2
	addi t4, t4, -1
	bnez a0, itoa_loop

itoa_loopend:
	beqz t1, itoa_done
	# Add the minus sign at the end
	li t0, 0x2d
	sb t0, 0(t3)
	addi t3, t3, 1

itoa_done:
	# Add null terminator
	sb x0, 0(t3)
	# Reverse string
	mv a0, a1
	sub a1, t3, a1
	call rev
	j itoa_ret

itoa_zero:
	li t0, 0x30
	sb t0, 0(a1)
	addi t3, a1, 1
itoa_null:
	sb x0, 0(t3)
itoa_ret:
	ld ra, 0(sp)
	addi sp, sp, 16
	ret

# Output the character in a0
putch:
	addi sp, sp, -16
	sd ra, 0(sp)
	li a7, 0x4442434e
	li a6, 2
	ecall
	ld ra, 0(sp)
	addi sp, sp, 16
	ret

# Read a character into a0
getch:
	addi sp, sp, -16
	sd ra, 0(sp)

getch_call:
	li a7, 0x4442434e
	li a6, 1
	li a0, 1
	la a1, curchar
	li a2, 0
	ecall
	beqz a1, getch_call

	la a1, curchar
	lb a0, 0(a1)
	ld ra, 0(sp)
	addi sp, sp, 16
	ret

# Read a line of text stripped of its newline into the buffer in a0 with length a1
readline:
	addi sp, sp, -32
	sd ra, 0(sp)

	# Return early if buffer is size zero
	blez a1, readline_ret

	# Set up registers
	addi t1, a1, -1 # t1 holds number of remaining characters we can read
	mv t2, a0 # t2 holds storage location for current character

readline_loop:
	# Finish early if there's no more space in the buffer
	blez t1, readline_done

	# Save registers and get a character into a0
	sd t1, 8(sp)
	sd t2, 16(sp)
	call getch
	ld t1, 0(sp)
	ld t2, 16(sp)

	# Exit the loop if it's a carriage return (this is what enter gives us)
	li t0, 0x0d
	beq a0, t0, readline_done

	# Echo the character
	sd a0, 8(sp)
	call putch
	ld a0, 8(sp)

	# Store into the next spot in the buffer
	sb a0, 0(t2)
	
	# Update counters and loop
	addi t1, t1, -1
	addi t2, t2, 1
	j readline_loop

readline_done:
	# Output a newline
	li a0, 0x0a
	call putch

	# Add the null terminator and return
	sb x0, 0(t2)
readline_ret:
	ld ra, 0(sp)
	addi sp, sp, 32
	ret
