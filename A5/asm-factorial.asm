; ************************************************
; Submitted by: 
;      Ben Wolfe | V00205547

; Submitted on: 
;      Nov 13, 2017
; 
; Course:
;      CSC 230 - Intro to Computer Architecture
; 
; Assignment:
;      Assignment 5 - Factorial
; 
; Description:
;      This program calculates the factorial of
;      numbers in the range 1 through 8 inclusive
;      then lights up the lower nibble of the lower
;      8 bits
; ************************************************


; ************************************************
; Macros
; ************************************************

; This macro adds two 16 bit numbers together
; Required usage: addw n1_h, n1_l, n2_h, n2_l
.macro addw
	add @1, @3
	adc @0, @2
.endmacro 


; ************************************************
; Assignments and Setup
; ************************************************

; LEDs
.equ PORTL  = 0x10B
.equ DDRL   = 0x10A

; Stack Pointer
.equ SPH    = 0x5E
.equ SPL    = 0x5D

; Registers
.def ZH     = r31                       ; Symbolic references for the low byte of Z register
.def ZL     = r30                       ; Symbolic reference for the high byte of Z register


; ************************************************
; Code Segment
; ************************************************
.cseg

	setup:
		ldi r16, high(0x21FF)
		sts SPH, r16                    ; Configure high byte of SP
	
		ldi r16, low(0x21FF)
		sts SPL, r16                    ; Configure low byte of SP 

		ldi r17, 0xFF	
		sts DDRL, r17                   ; Set the output mode for port L Leds

		ldi ZH, high(init<<1)
		ldi ZL, low(init<<1)  
		
		lpm r23, Z                      ; Get the starting constant from data memory
			
	main:
		push r23
		call factorial                  ; Result is temporarily stored in R25:R24
		pop r23

		ldi r26, low(result)            ; Configure register X to reference dest in data memory
		ldi r27, high(result)
		st X+, r24
		st X, r25

		call light_LEDs

done:
	jmp done


init:	.db 0x01 ; Starting constant


; ************************************************
; Functions
; ************************************************

; int factorial(int n) {
; 	if (n == 1) return 1
; 	return n * factorial(n-1)
; }
factorial:

	read_stack:
	
		lds ZH, SPH                       ; Get the current high byte of SP
		lds ZL, SPL                       ; Get the current low byte of SP
		ldd r23, Z+4                      ; Read the starting value

	base_case:
	
		cpi r23, 0x01                     ; Check for base case at each call
		brne recurse                      ; Recurse down to base case
 
		ldi r24, 0x01                     ; 1 is the answer base case
		ldi r25, 0x00                     ; 0 is in the answer high bytes to start
	
		ret

	recurse:
		
		dec r23
		rcall base_case

		push r23                           ; R23 is the factor
		push r24                           ; Push the low byte of answer
		push r25                           ; Push the high byte of answer
					
		rcall multiply                     ; Result of multiply is in 25:24

		pop r16                            ; Clear stack
		pop r17                            ; Clear stack
		pop r18                            ; Clear stack

		inc r23

		ret	

; multiply (byte factor, byte multiplier) {
;    word answer = 0;
;    while (factor-- > 0) answer += multiplier;    
;    return answer;
; }
multiply:

	lds ZH, SPH                             ; Get the current high byte of SP
	lds ZL, SPL                             ; Get the current low byte of SP

	ldd r16, Z+6                            ; Temp result for factor
	ldd r25, Z+4                            ; Temp result for answer (high)
	ldd r24, Z+5                            ; Temp result for answer (low)
		
	mov r26, r24                            ; A copy of answer is the multipler
	mov r27, r25

	while:                                  ; while the fator is > 0
		addw r25, r24, r27, r26
		dec r16

		cpi r16, 0x00
			brne while

	ret


light_LEDs:

	lds r16, result
	.def number          = r16
	.def temp            = r17				;  Stores an isolated bit
	.def mask            = r18				;  Stores the bit mask
	.def num_shifts      = r19              ;  Stores the number of bit shifts when getting a bit into the correct position
	.def required_shifts = r20              ;  Stores the required number of shifts to get a bit in the correct position
	.def led_output      = r21		        ;  Stores the correct sequence of bits for led output
	.def mask_count      = r25		        ;  Stores the number of masks completed

	ldi led_output, 0x00
	ldi mask, 0x01
	ldi num_shifts, 0x00
	ldi required_shifts, 0x01
	ldi mask_count, 0x00

	shift_bits:

		mov temp, number
		and temp, mask

		single_bit:
			lsl temp						;  Left shift the masked bit
			inc num_shifts					;  Increment the tracked number of shifts
			cp num_shifts, required_shifts	;  Comparing number of shifts to required number of shifts
			brne single_bit					;  Keep shifting until the bit has moved the required number of places

		ldi num_shifts, 0x00				;  Reset the tracked nunber of shifts
		inc required_shifts					;  Increment the required number of shifts (the required number of shifts increments by one for each bit)
		
		or led_output, temp					;  Include the status of the bit in the led_output
		
		lsl mask							;  Shift the mask left one
		inc mask_count						;  Increment the tracked number of iterations
		cpi mask_count, 4					;  Compared the tacked number of masks to required number of 4
			brne shift_bits

	sts PORTL, led_output					;  Output the result to the LEDs
	ret

; ************************************************
; Data Segment
; ************************************************

.dseg
.org 0x200
	
	result:	.byte 2
