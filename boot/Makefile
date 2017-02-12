# Makefile for building stage-1 & stage-2
# bootloaders from source ASMs.

ASM_SRC = $(wildcard *.asm)
BOOTL_BIN = $(ASM_SRC:%.asm=./../${EMULDIR}/%.bin)
INC_DIR = ./include/

ASM = nasm -f bin

.PHONY: all
all: ${BOOTL_BIN}

./../${EMULDIR}/%.bin: %.asm
	${ASM} $^ -o $@ -i ${INC_DIR}
