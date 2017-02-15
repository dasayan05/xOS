# Makefile for building stage-1 & stage-2
# bootloaders from source ASMs.

STAGES_ASM_SRCS = $(wildcard *.asm)
STAGES_BIN = $(STAGES_ASM_SRCS:%.asm=./../${EMULDIR}/%.bin)

STAGE1_INC_DIR = ./include/stage1/
STAGE1_SRCS = $(wildcard ${STAGE1_INC_DIR}*.inc)

STAGE2_INC_DIR = ./include/stage2/
STAGE2_SRCS = $(wildcard ${STAGE2_INC_DIR}*.c) $(wildcard ${STAGE2_INC_DIR}**/*.c)
STAGE2_OBJS = $(STAGE2_SRCS:.c=.o)

ASM = nasm
GCC = gcc -m16 -ffreestanding -nostdlib -fno-asynchronous-unwind-tables
CC = ${GCC} -c -masm=intel
LD = ${GCC} -Wl,--build-id=none
REMOVE = rm -f

.PHONY: all
all: ${STAGES_BIN}

./../${EMULDIR}/stage1.bin: stage1.asm ${STAGE1_SRCS}
	${ASM} $< -o $@ -i ${STAGE1_INC_DIR} -f bin

./../${EMULDIR}/stage2.bin: stage2.o ${STAGE2_OBJS}
	${LD} $^ -o $@ -T stage2link.ld
	${MAKE} clean

stage2.o: stage2.asm
	${ASM} $^ -o $@ -f elf32

%.o: %.c
	${CC} $^ -o $@ -I ${STAGE2_INC_DIR}

.PHONY: clean
clean:
	${REMOVE} stage2.o ${STAGE2_OBJS}
