.include "m16def.inc"
.org 0x0
rjmp reset
.org 0x4
rjmp ISR1

reset:
	ldi r24 , low(RAMEND) 					;initialize stack pointer.
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	
	ldi r24 , (1 << ISC11)|(1 << ISC10)		;INT0 se sima thetikhs akmhs.
	out MCUCR , r24
	
	ldi r24 , (1 << INT1)					;energopoihsh diakopis INT0
	out GICR , r24
	sei										;kai twn diakopwn genika.
	
init:
	ser r26
	out DDRA, r26							;ports A kai C outputs.
	out DDRC, r26
	clr r26
	out DDRB, r26							;port B input.
	out DDRD, r26							;port D input.
	clr r21									;arxikopoihsh metriti.

loop:
	;o r26 einai o metritis tou programmatos.
	out PORTC , r21							;emfanisi metritwn.
	out PORTA , r26
	ldi r24 , low(200)						;0.2 sec delay.
	ldi r25 , high(200)
	rcall wait_msec
	inc r26
	rjmp loop

ISR1:
	push r26
	in r26 , SREG
	push r26
	push r25

check_bit_7:
	ldi r24 , (1 << INTF1)
	out GIFR , r24							;midenismos tou bit7.

	ldi r24 , low(5)						;5 msec delay.
	ldi r25 , high(5)
	rcall wait_msec
	
	in r26 , GIFR							;elegxos tou bit7.
	sbrc r26 , 7
	rjmp check_bit_7

	in r26 , PIND							;elegkse an einai patimenos o 
	andi r26 , 0x01							;diakoptis PD0.
	cpi r26 , 0x01
	brne exit 
	in r22 , PINB
	ldi r23 , 8
	clr r21
loop2:										;Me auto to loop briskoume
											;ton plithos twn diakoptwn B
											;pou einai patimenoi.
	mov r20 , r22							
	andi r20 , 0x01
	add r21 , r20
	lsr r22									
	dec r23
	brne loop2
exit:	
	pop r25
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