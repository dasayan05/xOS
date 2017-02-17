#ifndef BIOS_INTERRUPTS
#define BIOS_INTERRUPTS

/*
* Halt the system
*/
static void halt()
{
	asm(
		"cli \n\t"
		"hlt \n\t"
	);
}

static void printChar(char);

#endif
