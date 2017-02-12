; library containing printing functions

%define TTY_INTERRUPT 0x10
%define TTY_OUTPUT 0x0E

; Macro-function to print single character
%macro PrintChar 1
	mov al, %1
	mov ah, TTY_OUTPUT
	int TTY_INTERRUPT
%endmacro

; DS:SI -> starting address of string
PrintString:
	mov ah, TTY_OUTPUT
.notdone:
	lodsb		; al := *(si++)
	or al, al		; if al==0
	jz .done
	int TTY_INTERRUPT
	jmp .notdone
.done:
	ret
