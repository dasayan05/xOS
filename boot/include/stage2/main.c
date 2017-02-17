#include "bios/interrupts.h"

void printString(char*);

void Stage2CMain()
{
	char str[12] = "Hello World";
	printString(str);
	halt();
}

void printString(char* str)
{
	int c = 0;
	while (str[c++] != '\0')
		printChar(str[c-1]);
}
