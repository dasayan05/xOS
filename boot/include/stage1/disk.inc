; library containing functions for reading
; from disk uisng BIOS interrupt 0x13

%define LOW_LEVEL_DISK_INTERRUPT 0x13
%define LOW_LEVEL_DISK_RESET 0x00
%define LOW_LEVEL_DISK_READ 0x02

; just for convenience
%define CHS(a,b,c) a,b,c

ErrorHandler:
	lea si, [errorMsg]
	call PrintString
	cli
	hlt

ResetDisk:
	; DL: drive number
	mov ah, LOW_LEVEL_DISK_RESET
	int LOW_LEVEL_DISK_INTERRUPT
	jnc .done		; if no error
	; error handling
	jmp ErrorHandler
	; error handling
.done:			; normally exit
	ret


ReadDisk:
	; DL: drive number/ID by BIOS
	; CH/DH/CL: C(ylinder)H(ead)S(sector) value
	; AL: sector count
	; ES:BX: buffer to read into

	mov ah, LOW_LEVEL_DISK_READ
	int LOW_LEVEL_DISK_INTERRUPT
	jnc .done
	jmp ErrorHandler
.done:
	ret

LBAtoCHS:
	; converts LBA to CHS using stack
	; ax: LBA
	; CH-DH-CL: CHS
	push ax
	xor dx, dx
	mov bx, HPC*SPT
	div bx
	mov ch, al		; calculate 'C' into CH

	pop ax
	push ax
	xor dx, dx
	mov bx, SPT
	div bx
	mov ax, dx
	add ax, 0x01
	mov cl, al		; calculate 'S' into CL

	pop ax
	mov bx, SPT
	xor dx, dx
	div bx
	xor dx, dx
	mov bx, HPC
	div bx
	mov dh, dl		; calculate 'H' into DH

	ret


%macro DiskReset 1
	mov dl, %1
	call ResetDisk
%endmacro

%macro DiskRead 6
	; args -> DL,CH,DH,CL,AL,ES
	mov ax, %6
	mov es, ax
	mov dl, %1
	mov ch, %2
	mov dh, %3
	mov cl, %4
	mov al, %5
	xor bx, bx	; try to mention the buffer location
				; with ES only (hardcoding bx := 0)
	call ReadDisk
%endmacro
