.include "m16def.inc"

.DSEG
_tmp_: .byte 2

.CSEG
.org 0x00
	rjmp stack_init

stack_init:
	ldi r24 , low(RAMEND)				;Arxikopoihsh ths stack.
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	
ports:
	ldi r24 , 0xF0						;Diamorfwsi PORTC gia to
	out DDRC , r24						;keypad.
	ser r24
	out DDRA , r24
	out DDRD , r24						;PORTD eksodos (lcd).
	out DDRB , r24
	rcall lcd_init
	ldi r24 , 20
	rcall scan_keypad_rising_edge
	
first_digit:
	rcall read_key						;Diavase to 1o psifio
	push r24							;kai swse to.
	push r25
	rcall lcd_clear						;Katharise tin othoni.
	rcall print_key						;Typwse to 1o psifio.
	rcall no_key						;Perimene na afethei.
	
second_digit:	
	rcall read_key						;Diabase to 2o, idia logikh.
	push r24
	push r25
	rcall print_key
	rcall no_key
	
third_digit:	
	rcall read_key
	push r24
	push r25
	rcall print_key
	rcall no_key
	
fourth_digit:	
	rcall read_key
	push r24
	push r25
	rcall print_key
	rcall no_key
	
	ldi r24 , 0x0c					;apenergopoihsh kersora.
	rcall lcd_command
	
	ldi r24 , '='					;typwse to '='.
	rcall lcd_data

	pop r25							;pop 4o psifio.
	pop r24
	rcall ascii_to_hex				;metatropi se hex.
	mov r16 , r24					;metafora ston r16.
	
	pop r25							;pop 3o.
	pop r24
	rcall ascii_to_hex
	lsl r24							;4 aristera shifts.
	lsl r24
	lsl r24
	lsl r24
	add r16 , r24 					;prosthesi ston r16
									;o r16 exei ton hex arithmo.
	
	pop r25							;idia logiki.
	pop r24
	rcall ascii_to_hex
	mov r17 , r24
	
	pop r25
	pop r24
	rcall ascii_to_hex
	lsl r24
	lsl r24
	lsl r24
	lsl r24
	add r17 , r24					;o r17 exei to prosimo.
	
	cpi r17 , 0xFF					;Elegxe ton r17.
	breq negative
	
	cpi r17 , 0x00
	breq positive
	
	cpi r17 , 0x80
	breq no_device
	
ukn_state:							;An exoume ftasei edw,
	rcall lcd_clear					;eimaste se agnwsti katastasi,

	ldi r24, 'U'					;typwse to
	rcall lcd_data
	ldi r24, 'k'
	rcall lcd_data
	ldi r24, 'n'
	rcall lcd_data
	ldi r24, ' '
	rcall lcd_data
	ldi r24, 'S'
	rcall lcd_data
	ldi r24, 't'
	rcall lcd_data
	ldi r24, 'a'
	rcall lcd_data
	ldi r24, 't'
	rcall lcd_data
	ldi r24, 'e'
	rcall lcd_data

	jmp first_digit					;kai epestrepse.
	
no_device:
	cpi r16 , 0x00					;elegxe an exei dwthei to 0x8000.
	brne ukn_state					;an oxi, eimaste se agnwsti katastasi,
	
	rcall lcd_clear					;alliws katharise thn othonh
	
	ldi r24, 'N'					;kai typwse 'No Device'.
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
 	
	jmp first_digit
	

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
	jmp first_digit
	
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

read_key:
	ldi r24 , 20 					;Block mexri na paththei kati.
	rcall scan_keypad_rising_edge
	clr	r20
	or r20 , r24 
	or r20 , r25
	cpi r20 , 0
	breq read_key
	ret
	
print_key:
	rcall keypad_to_ascii			;Metetrepse to se ascii
	rcall lcd_data					;kai typwse ton.
	ret
	
no_key:
	ldi r24 , 20 					;Block mexri na mhn einai pathmeno
	rcall scan_keypad_rising_edge	;kati.
	clr r20
	or r20 , r24
	or r20 , r25
	cpi r20 , 0 
	brne no_key
	ret

scan_row:
	ldi r25 , 0x08
back_:
	lsl r25
	dec r24
	brne back_
	out PORTC , r25
	nop
	nop
	in r24 , PINC
	andi r24 , 0x0f
	ret
	
scan_keypad:
	ldi r24 , 0x01
	rcall scan_row
	swap r24
	mov r27 , r24
	ldi r24 , 0x02
	rcall scan_row
	add r27 , r24
	ldi r24 , 0x03
	rcall scan_row
	swap r24
	mov r26 , r24
	ldi r24 , 0x04
	rcall scan_row
	add r26 , r24
	movw r24 , r26
	ret

scan_keypad_rising_edge:
	mov r22 , r24
	rcall scan_keypad
	push r24
	push r25
	mov r24 , r22
	ldi r25 , 0
	rcall wait_msec
	rcall scan_keypad
	pop r23
	pop r22
	and r24 , r22
	and r25 , r23
	ldi r26 , low(_tmp_)
	ldi r27 , high(_tmp_)
	ld r23 , X+
	ld r22 , X
	st X , r24
	st -X , r25
	com r23
	com r22
	and r24 , r22
	and r25 , r23
	ret
	
keypad_to_ascii:						;Tropopoihmenh gia ta F, E.
	movw r26 , r24
	ldi r24 , 'E'
	sbrc r26 , 0
	ret
	ldi r24 , '0'
	sbrc r26 , 1
	ret
	ldi r24 , 'F'
	sbrc r26 , 2
	ret
	ldi r24 , 'D'
	sbrc r26 , 3
	ret
	ldi r24 , '7'
	sbrc r26 , 4
	ret
	ldi r24 , '8'
	sbrc r26 , 5
	ret
	ldi r24 , '9'
	sbrc r26 , 6
	ret
	ldi r24 , 'C'
	sbrc r26 , 7	
	ret
	ldi r24 , '4'
	sbrc r27 , 0
	ret
	ldi r24 , '5'
	sbrc r27 , 1
	ret
	ldi r24 , '6'
	sbrc r27 , 2
	ret
	ldi r24 , 'B'
	sbrc r27 , 3
	ret
	ldi r24 , '1'
	sbrc r27 , 4
	ret
	ldi r24 , '2'
	sbrc r27 , 5
	ret
	ldi r24 , '3'
	sbrc r27 , 6
	ret
	ldi r24 , 'A'
	sbrc r27 , 7
	ret
	clr r24
	ret

ascii_to_hex:
	movw r26 , r24
	ldi r24 , 0x0E
	sbrc r26 , 0
	ret
	ldi r24 , 0x00
	sbrc r26 , 1
	ret
	ldi r24 , 0x0F
	sbrc r26 , 2
	ret
	ldi r24 , 0x0D
	sbrc r26 , 3
	ret
	ldi r24 , 0x07
	sbrc r26 , 4
	ret
	ldi r24 , 0x08
	sbrc r26 , 5
	ret
	ldi r24 , 0x09
	sbrc r26 , 6
	ret
	ldi r24 , 0x0C
	sbrc r26 , 7	
	ret
	ldi r24 , 0x04
	sbrc r27 , 0
	ret
	ldi r24 , 0x05
	sbrc r27 , 1
	ret
	ldi r24 , 0x06
	sbrc r27 , 2
	ret
	ldi r24 , 0x0B
	sbrc r27 , 3
	ret
	ldi r24 , 0x01
	sbrc r27 , 4
	ret
	ldi r24 , 0x02
	sbrc r27 , 5
	ret
	ldi r24 , 0x03
	sbrc r27 , 6
	ret
	ldi r24 , 0x0A
	sbrc r27 , 7
	ret
	clr r24
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