[BITS 16]		; It all starts with 16 bit
[ORG 0x00]

section .text	; Text (only) section

StageOneEntry:
jmp StageOne	; jump to the main code

; BIOS Parameter block - BPB
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
; BIOS Parameter block - BPB

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

; the FAT load address (segment)
%define FAT_LOAD_ADDR 0x0050

; the ROOT load address and some other
; Parameters
%define ROOT_LOAD_ADDR 0x07E0
%define BYTES_PER_ROOT_ENTRY 0x20

; STAGE2 load address
; this is just below the bootloader
%define STAGE2_LOAD_ADDR_SEG 0x07C0
%define STAGE2_LOAD_ADDR_OFF 0x0200

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
	mov sp, 0xFFFF			; end of the segment
	sti
	; setup segment registers

	lea si, [welcomeMsg]	; just a
	call PrintString		; welcome msg

	DiskReset DISK_NUMBER

	; calculate # of sectors of ROOT DIR
	mov ax, 0x20 			; each rootdir entry: 32(0x20) bytes
	mul word [BPBRootEntries]
	xor dx, dx
	div word [BPBBytesPerSector]
	push ax				; push '# of sectors'

	; calculate starting sector
	mov ax, word [BPBSectorsPerFAT]
	mov bl, byte [BPBNumberOfFATs]
	xor bh, bh
	mul bx
	add ax, word [BPBReservedSectors]
	; ax: 'starting sector (LBA value)'

	call LBAtoCHS				; convert starting sector
	mov ax, ROOT_LOAD_ADDR		; to CHS
	mov es, ax
	mov dl, DISK_NUMBER
	pop bx
	mov al, bl
	xor bx, bx

	call ReadDisk				; READ the ROOT

	; search the root dir for the stage2 bootloader

	mov al, 0				; setting local counter
	mov di, -0x20			; init some indexing variables

.gotoNextEntry:
	xor al, al
	lea si, [stage2filename]		; for DS:SI - 0x7c0:stage2filename
	add di, BYTES_PER_ROOT_ENTRY	; for ES:DI - 0x7e0:0x00
	cmp byte [es:di], 0x00
	je .NotFound
	push di
.nextByte:
	cmpsb
	jne .charNotEqual
	inc al
	cmp al, 0x0b
	je .GotIt
	jmp .nextByte
.charNotEqual:
	pop di
	jmp .gotoNextEntry
.GotIt:
	pop di
	add di, 0x1A
	mov ax, word [es:di]
	mov word [NextFatEntry], ax	; Got the first logical
	jmp .SearchingDone			; cluster at 'NextFatEntry'
.NotFound:
	lea si, [NotFoundMsg]		; if stage 2 not found
	call PrintString
.SearchingDone:

	; read the FAT
	xor ax, ax
	add ax, word [BPBReservedSectors]
	call LBAtoCHS
	mov ax, FAT_LOAD_ADDR
	mov es, ax
	mov dl, DISK_NUMBER
	mov al, byte [BPBSectorsPerFAT]
	xor bx, bx
	call ReadDisk

	; browse through the FAT to find the
	; link chain of stage2 bootloader
.BrowseFat:
	mov ax, word [NextFatEntry]
	cmp ax, 0x0FFF					; means the chain ended here
	je .JumpToStageTwo
.LoadTheSector:
	; the entry is not FFF, so load the sector
	add ax, 0x1F					; from logical fat entry to LBA
	call LBAtoCHS					; LBA = 33 + (logical fat entry number) - 2
	mov ax, STAGE2_LOAD_ADDR_SEG
	mov es, ax
	mov dl, DISK_NUMBER
	mov al, 0x01
	mov bx, word [NextBXIndex]
	call ReadDisk
	add bx, 0x200
	mov word [NextBXIndex], bx

	; this is the ugliest part:
	; This is where I resolved the 12-bit FAT entries
	; and followed the link chain
	; I will later add a detail description on how I did it !!!

	mov ax, word [NextFatEntry]
	test ax, 0x0001
	jnz .ItsOdd
.ItsEven:
	mov bx, 0x02
	xor dx, dx
	div bx
	mov bx, 0x03
	mul bx
	add ax, 0x01				; this AX in LBA

	mov di, ax
	mov cx, FAT_LOAD_ADDR
	mov es, cx
	mov cl, byte [es:di]
	mov bl, byte [es:di-1]
	mov dl, byte [es:di+1]
	test word [NextFatEntry], 0x0001
	jnz .odd
.even:
	mov al, bl
	mov ah, cl
	and ax, 0x0FFF
	jmp .saveNextFatEntry
.odd:
	mov al, cl
	mov ah, dl
	shr ax, 4
.saveNextFatEntry:
	mov word [NextFatEntry], ax
	jmp .BrowseFat

.ItsOdd:
	sub ax, 0x01
	jmp .ItsEven

.JumpToStageTwo:
	; this is a FAR jump to the stage2 code
	jmp STAGE2_LOAD_ADDR_SEG:STAGE2_LOAD_ADDR_OFF

	cli
	hlt

data_area:
	welcomeMsg: db "WC! ",0
	errorMsg: db "ER! ",0
	stage2filename: db "BIGFILE TXT"
	NotFoundMsg: db "Not found",0
	NextFatEntry: dw 0x00
	NextBXIndex: dw STAGE2_LOAD_ADDR_OFF

times (BOOTLOADER_SIZE-2) - ($-$$) db FILLER_BYTE
BootLoaderSign:
	dw 0xAA55
