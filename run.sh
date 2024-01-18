#! /bin/bash
set -eu

cd "$(dirname "$(readlink -e "$0")")"
riscv64-linux-gnu-as -march=rv64gc -mabi=lp64 -o main.o -c main.s
riscv64-linux-gnu-as -march=rv64gc -mabi=lp64 -o baselib.o -c baselib.s
riscv64-linux-gnu-ld -T layout.ld --no-dynamic-linker -m elf64lriscv -static -nostdlib -s -o kernel.elf main.o baselib.o
qemu-system-riscv64 -machine virt -nographic -bios /usr/share/opensbi/lp64/generic/firmware/fw_dynamic.elf -kernel ./kernel.elf

# Disassemble:
# riscv64-linux-gnu-objdump -d -j .text main.o
