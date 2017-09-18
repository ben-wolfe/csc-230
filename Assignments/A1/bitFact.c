#include <stdlib.h>
#include <stdio.h>

#define SIZE_INT 16
#define TEST_VALUE 3
#define DIVISOR 2

void printBitArray(unsigned char theBits[SIZE_INT]) {
	
	int i = 0;
	printf("0b");
	for(i = 0; i < SIZE_INT; i++) {
		printf("%d", theBits[i]);
	}
	printf("\n");
}

void toBits(unsigned short value, unsigned char inBits[SIZE_INT]) {

	unsigned short quotient = value;
	unsigned short remainder = 0;
	
	unsigned short index = 0;
	while(quotient != 0){

		remainder = quotient % 2;
		quotient = quotient / DIVISOR;

		inBits[(SIZE_INT - index)-1] = remainder;

		index++;
	}
}

unsigned short factorial(unsigned short num) {

	if(num == 0) {
		return 1;
	} 

	return num * factorial(num-1);
}

int main(int argc, char* argv[]){

	int user_input = 0;
	unsigned short conversion_value;
	unsigned char another_conversion = '\0';
	unsigned char inBits[SIZE_INT];
	unsigned short factorial_value = 0;

	while(1) {
	
		printf("Input a positive integer: ");
		user_input = scanf("%hd", &conversion_value);

		if(user_input != 1) {
			printf("Invalid input.  Enter a integer between 0 and 65536\n");
			continue;
		}
	
		factorial_value = factorial(conversion_value);
		printf("   %d Factorial = %d", conversion_value, factorial_value);
		toBits(factorial_value, inBits);
		printf(" or ");
		printBitArray(inBits);

		printf("Do another converion (y/n): ");
		user_input = scanf("%s", &another_conversion);

		if(another_conversion == 'y') {
			continue;
		} else if (another_conversion == 'n') {
			break;
		} 

	}

	return 0;
}
