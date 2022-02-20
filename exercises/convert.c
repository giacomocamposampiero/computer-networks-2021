#include <stdio.h>

void flip_bytes(char* first, char* second);
float flip_float(float* n);
int flip_int(int* n);

int main() {
        int num1 = 16;
        float num2 = 16.25;

        //int flip1 = flip_int(&num1);
        //char* ref1 = (char*) &flip1;
        //printf("I byte int: %x                II byte int: %x \n", *ref1, *(ref1+1));

        float flip2 = flip_float(&num2);
        char* ref2 = (char*) &flip2;
        printf("I byte float: %x        II byte float: %x       III byte float: %x      IV byte float: %x \n", *ref2, *(ref2+1), *(ref2+2), *(ref2+3));
}

float flip_float(float* n){
        float rrr = *n;
        char* ref = (char*) &rrr;
        printf("Struttura dato in memoria\n");
        printf("%x	  	    address 0x%x \n", *(ref+0), ref);
        printf("%x      	    address 0x%x \n", *(ref+1), ref+1);
        printf("%x      	    address 0x%x \n", *(ref+2), ref+2);
        printf("%x      	    address 0x%x \n", *(ref+3), ref+3);
        flip_bytes(ref, ref+3);
        flip_bytes(ref+1, ref+2);
        return rrr;
}

int flip_int(int* n) {
        int tmp = *n;
        char* ref = (char*) &tmp;
        flip_bytes(ref, ref+1);
        return tmp;
}

void flip_bytes(char* first, char* second) {
        char tmp = *first;
        *first = *second;
        *second = tmp;
}
