/*
 * CSC 230 - Intro to Computer Architecture
 * Assignment 2
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

void printBitArray(unsigned char theBits[SIZE_INT]) {
/* printBitArray takes in an array of unsigned characters and prints out 
   the contents at each index */

	printf("0b"); // Leading 0b to denote binary number
	
	int i = 0;
	for(i = 0; i < SIZE_INT; i++) {
		printf("%d", theBits[i]);
	}

	printf("\n");
}

void toBits(unsigned short value, unsigned char inBits[SIZE_INT]) {
/* toBits takes in an unsigned short value and puts the individual bits
   in seperate indecies of an array */

	// Masking variables
	unsigned short mask;
	unsigned short masked_number;
	unsigned short shifted_number;
	
	int bit_position = 0;
	for(bit_position = 0; bit_position < SIZE_INT; bit_position++) {
		mask = 1 << bit_position;
		masked_number = mask & value;
		shifted_number = masked_number >> bit_position;
		inBits[SIZE_INT - bit_position - 1] = shifted_number;
	}
}

unsigned short factorial(unsigned short num) {
/* factorial takes in an unsigned short and calculates the
   factorial recursively */

	// Factorial returns 1 at the base case of 0
	if(num == 0) {
		return 1;
	}

	return num * factorial(num-1);
}

int main(int argc, char* argv[]){

	unsigned short conversion_value;
	unsigned char another_conversion = '\0';
	unsigned char inBits[SIZE_INT];
	unsigned short factorial_value = 0;
	
	// Keep the program running until the user enters 'n'
	while(1) {
	
		printf("\nInput a positive integer: ");
		scanf("%hd", &conversion_value);

		// Check that the user input is within a valid range
		if(conversion_value < 0) {
			printf("Input cannot be negative. Enter a new value\n");
			continue;
		} else if (conversion_value > 8) {
			printf("Input cannot be larger than 8.  Enter a new value\n");
			continue;
		}

		// Perform the calculation and bit manipulation
		factorial_value = factorial(conversion_value);
		printf("   %d Factorial = %d", conversion_value, factorial_value);
		toBits(factorial_value, inBits);
		printf(" or ");
		printBitArray(inBits);
		printf("\n");

		// Check for program execution
		printf("Do another converion (y/n): ");
		scanf("%s", &another_conversion);
		
		if(another_conversion == 'y') {
			continue;
		} else if (another_conversion == 'n') {
			printf("Program ending");
			break;
		} else {
			printf("Invalid entry - program ending\n");
			break;
		}
	}

	return 0;
}
