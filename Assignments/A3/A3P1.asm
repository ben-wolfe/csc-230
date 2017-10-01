; *********************************************************
; CSC 230 - Intro to Computer Architecture
; Assignment 3 - Part 1
; Submitted by: Ben Wolfe | V00205547
; Last Modified: 1.10.2017
; Description: This program adds three numbers together.
; *********************************************************

; Include Statements
; *************************
.include "m2560def.inc"

; Code Segment
; *************************
.cseg

; Configure the three numbers
.def number1 = R16
	ldi number1, 27 ; Initialize R16 with 27

.def number2 = R17
	ldi number2, 41  ; Initialize R17 with 41

.def number3 = R18
	ldi number3, 15 ; Initialize R18 with 15

; sum = 0
.def sum = R19
	ldi sum, 0 ; Initialize the sum register to 0

; Add the three numbers together
add sum, number1
add sum, number2
add sum, number3

; Store the result in SROM with direct addressing
sts result, sum

; End Program
; *************************
done:	jmp done

; Data Segment
; *************************
.dseg
.org 0x200 ; Set the location counter to memory address 0x200

; Memory location to hold the summation value
result: .db 1 ; Allocate one byte of memory for storage