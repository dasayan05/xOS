# Makefile for building stage-1 & stage-2
# bootloaders from source ASMs.

ASM_SRC = $(wildcard *.asm)
BOOTL_BIN = $(ASM_SRC:%.asm=./../${EMULDIR}/%.bin)
INC_DIR = ./include/
INC_SRC = $(wildcard ${INC_DIR}*.inc)

ASM = nasm -f bin

.PHONY: all
all: ${BOOTL_BIN}

./../${EMULDIR}/%.bin: %.asm ${INC_SRC}
	${ASM} $< -o $@ -i ${INC_DIR}
