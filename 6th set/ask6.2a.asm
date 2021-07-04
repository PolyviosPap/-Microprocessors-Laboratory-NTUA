.include "m16def.inc"

.DSEG
_tmp_: .byte 2

.CSEG
.org 0x00
	rjmp stack_init

stack_init:
	ldi r24 , low(RAMEND)				;initialization of the stack.
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	
ports:
	ser r24
	out DDRA , r24
	out DDRD , r24						;PORTD eksodos (lcd).
	out DDRB , r24
	clr r19
	rcall lcd_init

start:
	rcall one_wire_reset
	sbrs r24 , 0							;If LSB is set, the device is connected.
	rjmp no_device

connected_device:
	ldi r24 , 0xCC							;send 0xCC command to ds1820.
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

	mov r17 , r24
	mov r16 , r25
	
	cp r19 , r16
	breq start
	mov r19 , r16
	rcall lcd_init
											;Check if temp is negative or positive.
	cpi r17 , 0xFF							
	breq negative

	cpi r17 , 0x00
	breq positive
	
no_device:
	rcall lcd_init
	ldi r24, 'N'					;Print 'No Device' in lcd.
	rcall lcd_data
	ldi r24, 'o'
	rcall lcd_data
	ldi r24, ' '
	rcall lcd_data
	ldi r24, 'D'
	rcall lcd_data
	ldi r24, 'e'
	rcall lcd_data
	ldi r24, 'v'
	rcall lcd_data
	ldi r24, 'i'
	rcall lcd_data
	ldi r24, 'c'
	rcall lcd_data
	ldi r24, 'e'
	rcall lcd_data
 	
	jmp start
	

negative:
	ldi r24,'-'
	rcall lcd_data

	com r16							;symplirwma ws pros 2.
	inc r16
	
	mov r18 , r16					;metefere ton ston r18.
	andi r18 , 0x01					;krata mono to LSB
	lsr r16							;kai peta to apo ton r16.
	
	jmp convert_and_print 
	
positive:
	ldi r24,'+'
	rcall lcd_data
	
	mov r18 , r16
	andi r18 , 0x01
	lsr r16
	
;r29 -> 100ades.
;r30 -> 10ades.
;r31 -> monades.	
convert_and_print:
	clr r29							;arxikopoihse tis metavlites.
	clr r30
	clr r31
	
	cpi r16 , 0x64					;sygrisi me to 100.
	brlo dekades					;an einai mikrotero, fyge,
	inc r29							;alliws auksise tis 100ades.
	subi r16 , 0x64					;afairese 100.
dekades:
	cpi r16 , 0x0A					;sygrisi me to 10.
	brlo monades
	inc r30
	subi r16 , 0x0A
	jmp dekades
monades:
	mov r31 , r16					;metefere tis monades ston r31.

print_ekatontades:
	cpi r29 , 0x00
	breq print_dekades
	mov r24 , r29					;metefere tis 100ades ston r24.
	subi r24 , -48
	rcall lcd_data					;typwse tis.

print_dekades:
	cpi r30 , 0x00
	breq print_monades
	mov r24 , r30					;typwse tis 10ades.
	subi r24 , -48
	rcall lcd_data

print_monades:	
	mov r24 , r31					;typwse tis monades.
	subi r24 , -48
	rcall lcd_data
	
klasmatiko:
	sbrs r18 , 0					;an o r18 einai 0,
	rjmp _C_						;fyge,
	ldi r24 , ','					;alliws typwse to ',5'.
	rcall lcd_data
	ldi r24,'5'
	rcall lcd_data
	
_C_:
	ldi r24,'C'
	rcall lcd_data

	jmp start
	
;------------------------------------------------------------------------------------------------;

lcd_clear:
	push r24
	push r25
	ldi r24 , 0x01 					;clear display

	rcall lcd_command
	ldi r24 , low(1530)				;wait for clear
	ldi r25 , high(1530)
	rcall wait_usec
	pop r25
	pop r24
	ret

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


write_2_nibbles:
	push r24
	in r25, PIND
	andi r25, 0x0f
	andi r24, 0xf0
	add r24, r25
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	pop r24
	swap r24
	andi r24, 0xf0
	add r24, r25
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ret

	
lcd_data:
	sbi PORTD , PD2
	rcall write_2_nibbles
	ldi r24 , 43
	ldi r25 , 0
	rcall wait_usec
	ret
	
lcd_command:
	cbi PORTD , PD2
	rcall write_2_nibbles
	ldi r24 , 39
	ldi r25 , 0
	rcall wait_usec
	ret	
	
lcd_init:
	ldi r24 , 40
	ldi r25 , 0
	rcall wait_msec
	ldi r24 , 0x30
	out PORTD , r24
	sbi PORTD , PD3
	cbi PORTD , PD3
	ldi r24 , 39
	ldi r25 , 0
	rcall wait_usec
	ldi r24 , 0x30
	out PORTD , r24
	sbi PORTD , PD3
	cbi PORTD , PD3
	ldi r24 , 39
	ldi r25 , 0
	rcall wait_usec
	ldi r24 , 0x20
	out PORTD , r24
	sbi PORTD , PD3
	cbi PORTD , PD3
	ldi r24 , 39
	ldi r25 , 0
	rcall wait_usec
	ldi r24 , 0x28
	rcall lcd_command
	ldi r24 , 0x0c
	rcall lcd_command
	ldi r24 , 0x01
	rcall lcd_command
	ldi r24 , low(1530)
	ldi r25 , high(1530)
	rcall wait_usec
	ldi r24 , 0x06
	rcall lcd_command
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
	ldi	r24 , low(998)
	ldi	r25 , high(998)
	rcall wait_usec
	pop	r25
	pop	r24
	sbiw r24 , 1
	brne wait_msec
	ret
