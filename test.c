#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//$ sudo gcc -z execstack test.c -o test
//$ sudo gcc -m32 -z execstack test.c -o test32
//$ sudo chmod +s test test32

void showInput(char *arg)
{
    char buffer[1024];
    strcpy(buffer,arg);
    puts("IN ASLR WE TRUST!");
}

int main(int argc, char *argv[])
{
	if (argc != 2)
		printf("PUT SHELLCODE INTO ENVIRONMENT!\n");
	else
		showInput(argv[1]);
	return 1;
}


