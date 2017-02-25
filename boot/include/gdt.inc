; The global descriptor table
; to use in 32 bit protected mode

start_gdt:
	; GDT starts here
	null_desc:		; mandatory null descriptor @ offset 0x00
		dd 0x00		; full of zeros
		dd 0x00		; doesn't do anything

	code_desc:		; code descriptor @ offset 0x08
		dw 0xFFFF 	; limit low
		dw 0x0000		; base low
		db 0x00 		; base middle
		db 0x9A	 	; access
		db 0xCF	 	; granularity
		db 0x00 		; base high

	data_desc:		; data descriptor @ offset 0x16
		dw 0xFFFF 	; limit low (Same as code)
		dw 0x00 		; base low
		db 0x00 		; base middle
		db 0x92	 	; access
		db 0xCF	 	; granularity
		db 0x00		; base high
end_gdt:

gdt_struct:
	; the GDT pointer structure
	gdt_size: dw end_gdt - start_gdt - 1
	gdt_addr: dd start_gdt
