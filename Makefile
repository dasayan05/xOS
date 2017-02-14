# xOS - A hobby OS
# Build process starts right here

# Author: Ayan Das

BOOT_DIR = boot
EMULATOR_DIR = emulator
KERNEL_DIR = kernel

.PHONY: all
all: bootloader
	@ ${MAKE} -C ${EMULATOR_DIR}

.PHONY: bootloader
bootloader:
	@ ${MAKE} -C ${BOOT_DIR} EMULDIR=${EMULATOR_DIR}

.PHONY: clean
clean:
	@ ${MAKE} -C ${EMULATOR_DIR} clean

.PHONY: run
run:
	@ ${MAKE} -C ${EMULATOR_DIR} emulate
