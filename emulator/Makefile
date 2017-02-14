# Makefile for controlling the emulation
# inside bochs


FLOPPY = floppy.img
MOUNT_LOC = /media/floppy/

STAGE1 = stage1.bin
STAGE2 = stage2.bin

DISKDUMP = dd bs=512
MKFS = mkfs.fat -F 12
REMOVE = rm -f

.PHONY: all
all:
	@ echo "Virtual floppy formatted"
	@ ${DISKDUMP} if=${STAGE1} of=${FLOPPY} count=1 conv=notrunc
	@ echo "Bootloader stage-1 written to floppy"
	@ sudo cp ${STAGE2} ${MOUNT_LOC}
	@ echo "Bootloader stage-2 copied to floppy"
	@ ${MAKE} emulate

.PHONY: clean
clean:
	@ ${REMOVE} *.bin
	@ ${MKFS} ${FLOPPY}

.PHONY: emulate
emulate:
	@ bochs
