[BITS 16]		; It is still 16 bits

section .text	; Text (only) section

extern Stage2CMain

%define GENERAL_SEGMENT 0x07E0
%define STACK_SEGMENT 0x7000

StageTwoEntry:
jmp StageTwo	; jump to the main code

StageTwo:
	; This is where stage2 actually starts

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

	call Stage2CMain

	cli			; halt
	hlt			; the system
