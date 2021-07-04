.include "m16def.inc"

.dseg
string: .byte 7

.cseg

stack_init:
	ldi r24, low(RAMEND)
	out SPL, r24
	ldi r24, high(RAMEND)
	out SPH, r24
	
string_init:
	
	ldi XL , low(string)
	ldi XH , high(string)
	
	ldi r24 , 'H'
	st X+ , r24
	
	ldi r24 , 'e'
	st X+ , r24
	
	ldi r24 , 'l'
	st X+ , r24
	
	ldi r24 , 'l'
	st X+ , r24
	
	ldi r24 , 'o'
	st X+ , r24
	
	ldi r24 , '\n'
	st X+ , r24
	
	ldi r24 , '\0'
	st X+ , r24
	
	rcall usart_init
	
	
start:
	ldi xl , low(string)
	ldi xh , high(string)
loop_:	
	ld r24 , X+
	mov r16 , r24
	rcall usart_transmit
	cpi r16 , '\0'
	brne loop_
	ldi r24 , low(1000)
    ldi r25 , high(1000)
    rcall wait_msec
	jmp start

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
