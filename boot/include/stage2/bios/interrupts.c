void printChar(char c)
{
	asm (
		".intel_syntax noprefix \n\t"
		"mov ah, 0x0e \n\t"
		"int 0x10 \n\t"
		:			// outputs
		: "a"(c)		// inputs
		:			// clobbers
	);
}
