#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//$ sudo gcc -z execstack test.c -o test
//$ sudo gcc -m32 -z execstack test.c -o test32
//$ sudo gcc -m32 test.c -o test32x
//$ sudo chmod +s test test32 test32x

void showInput(char *arg)
{
    char buffer[1024];
    strcpy(buffer,arg);
    puts("IN DEP/ASLR WE TRUST!");
}

int main(int argc, char *argv[])
{
	if (argc != 2)
		printf("EXPLOIT THE ARGUMENT!\n");
	else
		showInput(argv[1]);
	return 1;
}
