#include <stdio.h>

int main() {
	int num = 1;
	char* ref = (char*) &num;
	printf("Primo byte: %x \n", *ref);
	printf("Secondo byte: %x \n", *(ref+1));
}
