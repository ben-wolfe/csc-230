; ****************************************
; Ben Wolfe | V00205547
; CSC 230 - Intro to Computer Architecture
; Assignment 3 Part 2
; Date submitted: 10.10.2017
; *****************************************


; *****************************************
;               CODE SEGMENT
; *****************************************
.cseg

.equ PORTL = 0x10B        ;  Set symbol for PORTL
.equ DDRL = 0x10A           ;  Symbol for Port L's data direction register

	ldi r17, 0xff  
	sts DDRL, r17           ;  Set the DDR to output

ldi r26, high(dest)		    ;  Configure register X to reference dest in data memory
ldi r27, low(dest)

.def number = r16			;  Store the desired number  
	ldi number, 15			;  number = /* choose a number between 1-15 inclusive */
.def temp = r17				;  Stores an isolated bit
.def mask = r18				;  Stores the bit mask
.def num_shifts = r19       ;  Stores the number of bit shifts when getting a bit into the correct position
.def required_shifts = r20  ;  Stores the required number of shifts to get a bit in the correct position
.def led_output = r21		;  Stores the correct sequence of bits for led output
.def mask_count = r25		;  Stores the number of masks completed
	
; while(number > 0)
decrement:

	; dest[count++] = number
	st X, r16
	ld r16, X+

	; Initializations
	ldi mask, 0x01
	ldi num_shifts, 0x00
	ldi required_shifts, 0x01
	ldi mask_count, 0x00

	; Output numbers on LEDs
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
	clr led_output							;  Clear the led_output register

	; Delay for 0.5 seconds
	ldi r24, 0x2A         ; approx. 0.5 second delay
	outer: ldi r23, 0xFF
		middle: ldi r22, 0xFF
			inner: dec r22
				brne inner
			dec r23
			brne middle
		dec r24
		brne outer

	; number--
	dec r16

	cpi r16, -1           
	brne decrement        ; Break if the last number was 0

done:	
	jmp done

; *****************************************
;               DATA SEGMENT
; *****************************************
.dseg
.org 0x200
dest: .byte 15
