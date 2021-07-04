.include "m16def.inc"
.org 0x00

init_stack:
	ldi r24 , low(RAMEND)
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	
ports:
	ser r16
	out DDRA , r16
	out DDRB , r16
	out DDRD , r16
	
	ldi r16 , 0x00
	
start:
	rcall one_wire_reset
	sbrs r24 , 0							;If LSB is set, the device is connected.
	rjmp no_device

connected_device:
	ldi r24 , 0xCC							;send 0xCC command.
	rcall one_wire_transmit_byte
	
get_temp:
	ldi r24 , 0x44							;send 0x44 command to start temp measurement.
	rcall one_wire_transmit_byte

measuring:
	rcall one_wire_receive_bit
	sbrs r24 , 0							;keep measuring while LSB is not set.
	rjmp measuring
	
	rcall one_wire_reset					;recheck if device is connected.
	sbrs r24 , 0
	rjmp no_device
	
	ldi r24 , 0xCC							;send 0xCC command to ds1820.
	rcall one_wire_transmit_byte
	
	ldi r24 , 0xBE							;send 0xBE command to ds1820.
	rcall one_wire_transmit_byte
	
	rcall one_wire_receive_byte				;read 1st byte and 
	push r24								;and save it.
	rcall one_wire_receive_byte				;read 2nd byte, it is in r24
	pop r25									;and pop the 1st in r25. 
	
temp_display:
	
	cpse r24 , r16							;If we have negative temp then take the complement of 2.
	neg r25
	jmp output
	
	
no_device:
	ldi r25 , 0x80							;When we have no device connected output 0x8000 on PORTB.
output:	
	out PORTB , r25
	jmp start
	
one_wire_receive_byte:
	ldi r27 , 8
	clr r26
loop_:
	rcall one_wire_receive_bit
	lsr r26
	sbrc r24 , 0
	ldi r24 , 0x80
	or r26 , r24
	dec r27
	brne loop_
	mov r24 , r26
	ret

one_wire_receive_bit:
	sbi DDRA , PA4
	cbi PORTA , PA4 						;generate time slot
	ldi r24 , 0x02
	ldi r25 , 0x00
	rcall wait_usec
	cbi DDRA , PA4 							;release the line
	cbi PORTA , PA4
	ldi r24 , 10 							;wait 10 ?s
	ldi r25 , 0
	rcall wait_usec
	clr r24 								;sample the line
	sbic PINA , PA4
	ldi r24 , 1
	push r24
	ldi r24 , 49 							;delay 49 ?s to meet the standards
	ldi r25 , 0 							;for a minimum of 60 ?sec time slot
	rcall wait_usec 						;and a minimum of 1 ?sec recovery time
	pop r24
	ret

one_wire_transmit_byte:
	mov r26 , r24
	ldi r27 , 8
_one_more_:
	clr r24
	sbrc r26 , 0
	ldi r24 , 0x01
	rcall one_wire_transmit_bit
	lsr r26
	dec r27
	brne _one_more_
	ret

one_wire_transmit_bit:
	push r24 								;save r24
	sbi DDRA , PA4
	cbi PORTA , PA4 						;generate time slot
	ldi r24 , 0x02
	ldi r25 , 0x00
	rcall wait_usec
	pop r24 								;output bit
	sbrc r24 , 0
	sbi PORTA , PA4
	sbrs r24 , 0
	cbi PORTA , PA4
	ldi r24 , 58 							;wait 58 ?sec for the
	ldi r25 , 0 							;device to sample the line
	rcall wait_usec
	cbi DDRA , PA4 							;recovery time
	cbi PORTA , PA4
	ldi r24 , 0x01
	ldi r25 , 0x00
	rcall wait_usec
	ret

one_wire_reset:
	sbi DDRA , PA4 							;PA4 configured for output
	cbi PORTA , PA4 						;480 ?sec reset pulse
	ldi r24 , low(480)
	ldi r25 , high(480)
	rcall wait_usec
	cbi DDRA , PA4 							;PA4 configured for input
	cbi PORTA , PA4
	ldi r24 , 100 							;wait 100 ?sec for devices
	ldi r25 , 0 							;to transmit the presence pulse
	rcall wait_usec
	in r24 , PINA 							;sample the line
	push r24
	ldi r24 , low(380) 						;wait for 380 ?sec
	ldi r25 , high(380)
	rcall wait_usec
	pop r25 								;return 0 if no device was
	clr r24 								;detected or 1 else
	sbrs r25 , PA4
	ldi r24 , 0x01
	ret
	
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