.include "m16def.inc"
.def temp = r16
.def counter = r17
.def vin_h = r18
.def vin_l = r19
	jmp stack_init

.org 0x1c
	jmp ADC_
	
stack_init:
	ldi r24, low(RAMEND)
	out SPL, r24
	ldi r24, high(RAMEND)
	out SPH, r24
	
port_init:
	ldi temp , 0xFF
	out DDRB , temp					;PORTB output.
	ldi temp , 0x00
	out PORTB , temp				;turn off all leds.
	
	clr counter						;initialize counter = 0.
	
	rcall ADC_init					;initialize ADC
	rcall usart_init				;and usart.

main:
	ldi r24 , low(100)
	ldi r25 , high(100)
	rcall wait_msec					;100ms delay.
	ldi r24 ,0xCF
	out ADCSRA , r24				;start an ADC measurement.
	inc counter						;increase counter.
	out PORTB , counter				;output counter.
	
	sei								;enable global interrupts.
	
stalling:
	brtc stalling					;stall till ADC is completed.
	
send_bytes:
	mov r24 , r20
	rcall usart_transmit			;print akeraio.
	ldi r24 , ','
	rcall usart_transmit			;print ','.
	mov r24 , r21
	rcall usart_transmit			;print klasmatiko.
	ldi r24 , '\n'
	rcall usart_transmit
	
	jmp main
	
ADC_:
	clr r20							;r20 = 0.
	clr r21
	clr vin_h
	clr vin_l						;reset Vin.	

loop_1:
	in r22 , ADCL
	in r23 , ADCH					;we will multiply ADC * 50.
	add vin_l , r22
	adc vin_h , r23
	inc r20
	cpi r20 , 50					;do it 50 times.
	brne loop_1
	
	lsr vin_h						;2 logical right shifts
	lsr vin_h
	clr r20							;r20 = 0.

dekades:
	cpi vin_h , 10
	brlo monades
	subi vin_h , 10
	inc r20							;r20 holds dekades.
	jmp dekades
	
monades:
	mov r21 , vin_h					;r21 holds monades.
	
ascii_convert:
	
	subi r20 , -48
	subi r21 , -48
	
	set								;T = 1.
	reti	

ADC_init:
	ldi r24 , (1<<REFS0) 			;Vref: Vcc 
	out ADMUX , r24 				;MUX4:0= 00000 forA0. 
	;ADC is Enabled (ADEN=1)
	;ADC Interrupts are Enabled (ADIE=1)
	;SetPrescaler CK/128 = 62.5Khz (ADPS2:0=111)
	ldi r24 , (1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	out ADCSRA , r24
	ret
	
usart_init:
	clr r24 									;initialize UCSRA to zero
	out UCSRA , r24
	ldi r24 , (1<<RXEN) | (1<<TXEN) 			;activate transmitter/receiver
	out UCSRB , r24
	ldi r24 , 0 								;baud rate = 9600
	out UBRRH , r24
	ldi r24 , 51
	out UBRRL , r24
	ldi r24 , (1 << URSEL) | (3 << UCSZ0)		;8-bit character size,
	out UCSRC , r24 							;1 stop bit
	ret
	
usart_transmit:
	sbis UCSRA , UDRE 							;check if usart is ready to transmit
	rjmp usart_transmit 						;if no check again, else transmit
	out UDR ,r24 								;content of r24
	ret
	
usart_receive:
	sbis UCSRA , RXC 							;check if usart received byte
	rjmp usart_receive 							;if no check again, else read
	in r24 , UDR 								;receive byte and place it in
	ret 										;r24	
	
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