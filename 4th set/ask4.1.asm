.include "m16def.inc"
.org 0x0
rjmp reset
.org 0x2
rjmp ISR0

reset:
	ldi r24 , low(RAMEND) 					;initialize stack pointer.
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	
	ldi r24 , (1 << ISC01)|(1 << ISC00)		;INT0 se sima thetikhs akmhs.
	out MCUCR , r24
	
	ldi r24 , (1 << INT0)					;energopoihsh diakopis INT0
	out GICR , r24
	sei										;kai twn diakopwn genika.
	
init:
	ser r26
	out DDRA, r26							;ports A kai B outputs.
	out DDRB, r26
	clr r26
	out DDRD, r26							;port D input.
	
	clr r21									;arxikopoihsh metriti.

loop:
	;o r26 einai o metritis tou programmatos kai o r21 twn diakopwn.
	out PORTB , r21							;emfanisi metritwn.
	out PORTA , r26
	ldi r24 , low(200)						;0.2 sec delay.
	ldi r25 , high(200)
	rcall wait_msec
	inc r26
	rjmp loop

ISR0:
	push r26
	in r26 , SREG
	push r26

check_bit_6:
	ldi r24 , (1 << INTF0)
	out GIFR , r24							;midenismos tou bit6.

	ldi r24 , low(5)						;5 msec delay.
	ldi r25 , high(5)
	rcall wait_msec
	
	in r26 , GIFR							;elegxos tou bit6.
	sbrc r26 , 6
	rjmp check_bit_6

	in r26 , PIND							;elegkse an einai patimenos o
	sbrc r26 , 0							;diakoptis 0 kai an einai,
	inc r21									;auksise ton metriti.

	pop r26									;epanafora kai epistrofi.
	out SREG , r26
	pop r26

	reti

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
	
wait_usec:
	sbiw r24 , 1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret