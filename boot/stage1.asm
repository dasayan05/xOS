[BITS 16]		; It all starts with 16 bit
[ORG 0x00]

section .text	; Text (only) section

StageOneEntry:
jmp StageOne	; jump to the main code

# BIOS Parameter block - BPB
BPB_OEM: 				db "xOS     " 		; Just a name
BPBBytesPerSector:  	dw 512 			; i.e. 512
BPBSectorsPerCluster: 	db 1				; Simplest case in floppy
BPBReservedSectors: 	dw 1				; the boot sector
BPBNumberOfFATs: 		db 2				; one is for backup
BPBRootEntries: 		dw 224			; 224 entries in the root dir
BPBTotalSectors: 		dw 2880			; 2880 x 512B(BPBBytesPerSector) ~ 1.44M
BPBMedia: 			db 0xF8			; 0x11111000
BPBSectorsPerFAT: 		dw 9				; 9 sector per FAT - two FATs total 18
BPBSectorsPerTrack: 	dw 18			; floppy has 18 sectors/track (SPT)
BPBHeadsPerCylinder: 	dw 2				; two heads, one platter (HPC)
BPBHiddenSectors: 		dd 0				; nope!!
BPBTotalSectorsBig:     	dd 0
BSDriveNumber: 	     db 0
BSUnused: 			db 0
BSExtBootSignature: 	db 0x29
BSSerialNumber:	     dd 0xa0a1a2a3
BSVolumeLabel: 	     db "MOS: FLOPPY"	; Volume label
BSFileSystem: 	        	db "FAT12   "		; FAT12 file system
# BIOS Parameter block - BPB

; REAL MODE MEMORY MAP ;;;;;;;;;;;;;;;;;;;;
; 0x00000 -> 0x003FF (1KB): IVT-Real mode
; 0x00400 -> 0x004FF (256B): BDA
; 0x00500 -> 0x07BFF (~30KB): FREE
; 0x07C00 -> 0x07DFF (512B): Boot sector
; 0x07E00 -> 0x7FFFF (480.5KB): FREE
; 0x80000 -> 0x9FBFF (~120KB): FREE (not fixed)
; 0x9FC00 -> 0x9FFFF (1KB): EBDA
; 0xA0000 -> <END> (384KB): Video memory
; REAL MODE MEMORY MAP ;;;;;;;;;;;;;;;;;;;;


; choosing the data segment to be at the start of our
; bootloader so that an '[org 0]' aligns the data properly
%define GENERAL_SEGMENT 0x07C0

; randomly choosing the end of <0x7E00->0x7FFFF> to
; be the top of stack
; ss := 0x7000 & sp := 0xFFFF so ss:sp == 0x7FFFF (0x7000 * 0x10 + 0xFFFF)
%define STACK_SEGMENT 0x7000

; to fill the rest of the binary file
%define FILLER_BYTE 0x00

; size of the bootloader in BPBBytesPerSector
%define BOOTLOADER_SIZE 512

; the ID/drive number (given by BIOS) of the boot device
%define DISK_NUMBER 0x00

; two very important Parameter for LBAtoCHS conversion
%define HPC 2
%define SPT 18

%include "print.inc"
%include "disk.inc"

StageOne:
	; everything starts from here

	; setup segment registers
	cli
	mov ax, GENERAL_SEGMENT
	mov ds, ax
	mov es, ax

	mov ax, STACK_SEGMENT
	mov ss, ax
	mov sp, 0xFFFF
	sti
	; setup segment registers

	lea si, [welcomeMsg]	; just a
	call PrintString		; welcome msg

	DiskReset DISK_NUMBER


	mov ax, 0x0023			; the LBA value
	call LBAtoCHS
	mov ax, 0x07E0
	mov es, ax
	xor bx, bx
	mov al, 0x01
	mov dl, DISK_NUMBER
	call ReadDisk


	; DiskRead DISK_NUMBER, CHS(0,1,17), 1, 0x07E0

	cli
	hlt

data_area:
	welcomeMsg: db "Welcome! ",0
	errorMsg: db "Error! ",0

times (BOOTLOADER_SIZE-2) - ($-$$) db FILLER_BYTE
BootLoaderSign:
	dw 0xAA55
