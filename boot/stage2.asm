[bits 16]

call Main

data: dq 0x00

Main:
	mov al, 'Q'
	mov ah, 0x0e
	int 0x10

	hlt

times 510-($-$$) db 0x00
dw 0xAA55
