.include "m16def.inc"
.org 0x0
rjmp set_stack
.org 0x2
rjmp ISR0
.org 0x10
rjmp ISR_TIMER1_OVF

set_stack:									;initialize stack.
	ldi r16,LOW(RAMEND)			
	out SPL,r16
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	
eisodos_eksodos:
	ser r16
	out DDRA , r16							;portA = output.
	clr r16
	out DDRB , r16							;portB = input.
		
set_int0:
	
	ldi r16 , (1 << ISC01)|(1 << ISC00)		;INT0 se sima thetikhs akmhs.
	out MCUCR , r16
	ldi r16 , (1 << INT0)					;energopoihsh diakopis INT0.
	out GICR , r16

set_timer1:
	
	ldi r24 ,(1<<TOIE1) 					;energopoihsh diakopis tou 
	out TIMSK ,r24							;metriti TCNT1 gia ton timer1.
	ldi r17,(1<<CS12)|(0<<CS11)|(1<<CS10)	;Orizoume ti sixnotita auksisis tou timer1.
	out TCCR1B,r17							
	
	
	sei										;energopoihsh diakopwn genika.

flag_init:									;Xrhsimopoioume tria flag gia thn swsth leitourgia.
	clr r21									;to flag1 (r21) deixnei an exoun perasei ta 3 second.
	clr r22									;to flag2 (r22) deixnei an exoun perasei ta 0,5 second.
	clr r23									;to flag3 (r23) deixnei an einai anoixto to led PA7.	
	
routine:
	in r16 , PINB							;Elegkse an to b0 einai patimeno

input_check:
	in r30 , PINB
	cpi r30 , 0x01
	breq input_check

sbrc r16 , 0								;kai an einai
rjmp leds_on
jmp routine

;theloume delay 0,5 sec.
;0,5 x 7812,5 = 3906,25.
;i arxiki timi pou prepei na tou dwthei prin arxisei na metraei pros ta panw einai:
;65536 - 3906,25 = 61629,75 ~= F0BE.

leds_on:	
	ldi r17 , 0xF0
	out TCNT1H , r17
	ldi r17 , 0xBE
	out TCNT1L , r17
	
	ldi r19 , 0x80
	sbrc r23 , 0
	ldi r19 , 0xff
	out PORTA , r19
	clr r21
	clr r22
	ldi r23 , 0x01
	jmp routine
	
ISR0:
	sei
	push r24
	push r25
check_bit_6:
	ldi r24 , (1 << INTF0)
	out GIFR , r24							;midenismos tou bit6.

	ldi r24 , low(5)						;5 msec delay.
	ldi r25 , high(5)
	rcall wait_msec
	
	in r26 , GIFR							;elegxos tou bit6.
	sbrc r26 , 6
	rjmp check_bit_6
	
	pop r25
	pop r24
	jmp leds_on								;anapse ta led.
	
ISR_TIMER1_OVF:
	sei
	sbrc r21 , 0							;Elegxos an perasan ta 3 sec.
	rjmp three_sec							;An perasan ta 3 second.
	sbrs r22 , 0 							;Elegxos an perasan ta 0,5 sec.
	rjmp point_5_sec						;An perasan 0,5 second.
	rjmp routine
	

point_5_sec:
;theloume akoma delay 2,5 sec.
;2,5 x 7812,5 = 19531,25.
;i arxiki timi pou prepei na tou dwthei prin arxisei na metraei pros ta panw einai:
;65536 - 19531,25 = 46004,75 ~= B3B5.
	ldi r17 , 0xB3
	out TCNT1H , r17
	ldi r17 , 0xB5
	out TCNT1L , r17
	
	andi r19 , 0x80
	out PORTA , r19
	ldi r21 , 0x01
	ldi r22 , 0x01
	rjmp routine
	
three_sec:
	clr r19									;Thetoume r20 = 0x00.
	out PORTA , r19							;Svinoume ola ta leds.
	clr r23
	rjmp routine
	
wait_usec:
	sbiw r24 , 1
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