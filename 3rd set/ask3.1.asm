.include "m16def.inc"

start:
	ldi r24 , low(RAMEND)			;Initializing stack pointer.
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	ser r24				  			;Setting PORTA for output.
	out DDRA , r24

	clr r26
	out DDRB,r26					;Setting PORTB for input.

	ldi r27,0x01					;Register r27 represents the moving led on PortA.
	ldi r28,0x00					;Register r28 is a flag for led's direction.

process:
	out PORTA,r27
	ldi r24 , low(500)  			;Setting r24,r25 value for the msec routine.
	ldi r25 , high(500) 			;We need to wait 0.5 sec = 500 msec so r25:r24 = 500.
	rcall wait_msec
	in r26,PINB			 			;Read PORTB input.
	andi r26,0x01	
	cpi r26,0x01		 			;Check if PB0 is 1.
	breq process
	cpi r28,0x00
	breq left
	rjmp right

left:
	lsl r27							;Left shift logical of the moving led.
	out PORTA,r27
	cpi r27,0x80					;Check if moving led is at PA7 (left limit).
	brne process
	ldi r28,0x01					;If moving led at PA7 set flag at 1 so we move right.
	rjmp process

right:
	lsr r27							;Right shift logical of the moving led.
	out PORTA,r27
	cpi r27,0x01					;Check if moving led is at PA7 (left limit).		`
	brne process
	ldi r28,0x00					;If moving led at PA0 set flag at 0 so we move left.
	rjmp process


wait_usec:
	sbiw r24 ,1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret

 wait_msec:
	push r24
	push r25
	ldi r24 , low(998)
	ldi r25 , high(998)
	rcall wait_usec
	pop r25
	pop r24
	sbiw r24 , 1
	brne wait_msec
	ret