; *****************************************
; Submitted by: Ben Wolfe | V00205547
; Suttmitted on: Dec 1st, 2017
; CSC 230 - Intro to Computer Architecture
; Assignment 6 - Interrupts
; *****************************************

; *****************************************
; Assignments
; *****************************************

; LEDs
; ----------------
.equ PORTB  = 0x25
.equ DDRB   = 0x24

.equ PORTL  = 0x10B
.equ DDRL   = 0x10A

; Stack Pointer
; ----------------
.equ SPH    = 0x5E
.equ SPL    = 0x5D

; Timers
; ----------------
; Store addresses for timer registers A
; (for adjusting timer operting mode)
.equ TCCR1A = 0x80   ; 
.equ TCCR3A = 0x90
.equ TCCR4A = 0xA0

; Store addresses for timer register B
; (for adjusting timer prescalar)
.equ TCCR1B = 0x81   ; 
.equ TCCR3B = 0x91
.equ TCCR4B = 0xA1

; Store addresses for timer register HIGH
; (high byte of timer value)
.equ TCNT1H = 0x85 
.equ TCNT3H = 0x95
.equ TCNT4H = 0xA5

; Store addresses for timer register LOW
; (low byte of timer value)
.equ TCNT1L = 0x84   ; 
.equ TCNT3L = 0x94
.equ TCNT4L = 0xA4

; Store addresses for the interrupt registers
.equ TIMSK1 = 0x6F   
.equ TIMSK3 = 0x71   
.equ TIMSK4 = 0x72   

.equ SREG	= 0x5F   

; *****************************************
; Interupt Table
; *****************************************

.org 0x0000
	jmp setup

; For 1 flash/second interrupt
.org 0x0028
	jmp timer1_isr

; For 3 flashes/second interrupt
.org 0x0046
	jmp timer3_isr

; For 5 flashes/second interrupt
.org 0x005A
	jmp timer4_isr

.org 0x0060

	
; *****************************************
; Setup

; LED stip occupies Ardruino pins 42, 44, 46, 
; 48, 50, 52 and Gnd; bits are numbered 7->0

; Pin 42 Port L: bit 7 (PL7)
; Pin 44 Port L: bit 5 (PL5)
; Pin 46 Port L: bit 3 (PL3)
; Pin 48 Port L: bit 1 (PL1)
; *****************************************

setup:

	ldi r16, high(0x21FF)
	sts SPH, r16       ; Configure high byte of SP
	
	ldi r16, low(0x21FF)
	sts SPL, r16       ; Configure low byte of SP 

	ldi r17, 0xFF	
	sts DDRB, r17      ; Set the output mode for port B LEDs
	sts DDRL, r17      ; Set the output mode for port L Leds

	call timer_init
	ldi r17,0x01
	ldi r18, 0x00

lp:
	rjmp lp


timer_init:

	nop
	ldi r16, 0x00
	sts TCCR1A, r16    ; Set operting mode to normal mode
	sts TCCR3A, r16
	sts TCCR4A, r16

	ldi r16, 0x04
	sts TCCR1B, r16    ; Set the presecalr to clock / 256
	sts TCCR3B, r16
	sts TCCR4B, r16

	; NOTE: Using a prescalar of 256 meaning we have 62,500
	;       cycles per second.

	; Start the 1/second timer at 0xffff = 65535-62500 = 3535
	; 62500 counts will take 1 second
	ldi r16, 0x0B
	sts TCNT1H, r16    ; WRITE the high byte first (reseting to 0x0B)
	ldi r16, 0xDB
	sts TCNT1L, r16	   ; Write the low byte second (reseting to 0xDB)

	; Start the 3/second timer at 55118; 65535-55118 = 10417
	; 10417 counts will take 1/6 of a second
	ldi r16, 0xD7 	
	sts TCNT3H, r16
	ldi r16, 0x4E
	sts TCNT3L, r16	

	; Start the 5/second timer at 59285; 65535-59285 = 6250
	; 6250 counts will take 1/10 of a second
	ldi r16, 0xE7
	sts TCNT4H, r16
	ldi r16, 0x95
	sts TCNT4L, r16

	ldi r16, 0x01
	sts TIMSK1, r16     ; Enable overflow interrupt
	sts TIMSK3, r16
	sts TIMSK4, r16
	sei                ; Enable global interrupts

	ret


; *****************************************
; Interrupt Service Routines
; *****************************************

; Interrupt 1 time a second
timer1_isr:

	lds r16, SREG
	push r16

	; toggle LEDs
	lds r16, PORTL
	ldi r17, 0b0000010
	eor r16, r17
	sts PORTL, r16

	ldi r16, 0x0B
	sts TCNT1H, r16    ; WRITE the high byte first (reseting to 0x0B)
	ldi r16, 0xDB
	sts TCNT1L, r16	   ; Write the low byte second (reseting to 0xDB)
		
	pop r16
	sts SREG, r16      ; Restore state
	reti               ; Interrrupt flag automatically cleared

; Interrupt 6 times a second
; The interrupt fires every 1/6 of a second
; 0/6 = off
; 1/6 = on
; 2/6 = off
; 3/6 = on ...
timer3_isr:
	lds r16, SREG
	push r16

	; toggle LEDs
	lds r16, PORTL
	ldi r17, 0b0001000
	eor r16, r17
	sts PORTL, r16

	ldi r16, 0xD7 	
	sts TCNT3H, r16
	ldi r16, 0x4E
	sts TCNT3L, r16	
		
	pop r16
	sts SREG, r16      ; Restore state
	reti               ; Interrupt flag automatically cleared

; Interrupt 10 times a second
; The interrupt fires every 1/10 of a second
; 0/10 = 0s off
; 1/10 = 0.1s on
; 2/10 = 0.2s off
; 3/10 = 0.3s on ...
timer4_isr:
	lds r16, SREG
	push r16

	; toggle LEDs
	lds r16, PORTL
	ldi r17, 0b00100000
	eor r16, r17
	sts PORTL, r16

	ldi r16, 0xE7
	sts TCNT4H, r16
	ldi r16, 0x95
	sts TCNT4L, r16
		
	pop r16
	sts SREG, r16      ; Restore state
	reti               ; Interrupt flag automatically cleared
