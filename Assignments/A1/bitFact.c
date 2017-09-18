/*
 * CSC 230 - Intro to Computer Architecture
 * Assignment 1
 *
 * Author: Ben Wolfe
 * Student Number: V00205547
 *
 * Last modified: 18.09.2017
 *
 */


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

	
	int bit_position = 0;
	unsigned short mask;
	unsigned short masked_number;
	unsigned short shifted_number;

	for(bit_position = 0; bit_position < SIZE_INT; bit_position++) {
		mask = 1 << bit_position;
		masked_number = mask & value;
		shifted_number = masked_number >> bit_position;
		inBits[SIZE_INT - bit_position - 1] = shifted_number;
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
