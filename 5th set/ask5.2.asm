.include "m16def.inc"

; --- Arxh tmhmatos dedomenwn.
.DSEG
_tmp_: .byte 2
; --- Telos tmhmatos dedomenwn.

.CSEG
.org 0x00
	rjmp reset

reset:
	ldi r24 , low(RAMEND)				;Arxikopoihsh ths stack.
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	
	ldi r24 , 0xF0						;Diamorfwsi PORTC gia to
	out DDRC , r24						;keypad.
	ser r24
	out DDRD , r24						;PORTD eksodos (lcd).
	
	rcall lcd_init						;Arxikopoihsh lcd othonhs.
	ldi r24 , 20
	rcall scan_keypad_rising_edge		;Arxikopoihsh keypad.
reset2:	
	;rcall lcd_init						;Arxikopoihsh lcd othonhs.
	clr r29
	clr r30
	clr r31
	
first_key:
	rcall read_key						;Diabase to 1o plhktro.
	push r26
	push r24
	push r25
	rcall lcd_init						;Arxikopoihsh lcd othonhs.
	pop r25
	pop r24
	pop r26
	push r24
	push r25
	rcall print_key						;Typwse to.
	rcall no_key						;Perimene mexri na afethei.
	
second_key:	
	rcall read_key						;Diabase to 2o, idia logikh.
	push r24
	push r25
	rcall print_key
	rcall no_key
	
convert:
	ldi 	r24 , 0x0c					;Apenergopoihsh kersora.
	rcall 	lcd_command
	
	pop r25								;Pop to 2o psifio.
	pop r24
	rcall ascii_to_hex					;Metetrepse to se hex.
	mov r28 , r24						;Metefere to ston r28.
	
	pop r25								;Pop to 1o psifio.
	pop r24
	rcall ascii_to_hex
	lsl r24								;4 left shifts.
	lsl r24
	lsl r24
	lsl r24
	add r28 , r24						;Prosthesi ston r28.
	
;O r28 exei ton arithmo se hex morfi.

	ldi r24, '='						;Typwse to '='.
	rcall lcd_data
	
	sbrc r28 , 7						;An to MSB einai 1, exoume arnitiko
	rjmp negative						;artithmo, alliws thetiko.
	rjmp positive

positive:
	ldi r24 , '+'						;Typwse to '+'.
	rcall lcd_data
	rjmp ekatontades
	
negative:
	ldi r24 , '-'
	rcall lcd_data
	subi r28 , 0x01						;Antistrofi toy symplhrwmatos ws
	com r28								;pros 2.
	
;r29 -> 100ades.
;r30 -> 10ades.
;r31 -> 1ades.
ekatontades:
	cpi r28 , 0x64						;Sygkrisi me to 100.
	brlo dekades						;An einai mikrotero tou 100, fyge,
	ldi r29 , 0x01						;alliws exoume 1 100ada.
	subi r28 , 0x64						;Afairese 100.
dekades:
	cpi r28 , 0x0A						;Sygkrisi me to 10.
	brlo monades
	inc r30
	subi r28 , 0x0A
	jmp dekades
monades:
	mov r31 , r28						;Exoun meinei mono 1ades, metefere
										;tis ston r31.
	mov r24 , r29						;Metefere tis 100ades ston r24.
	;rcall num_to_ascii					;Metetrepse tis se ascii.
	subi r24 , -48
	rcall lcd_data						;Typwse ton.
	
	mov r24 , r30						;Typwse tis 10ades.
	subi r24 , -48
	;rcall num_to_ascii
	rcall lcd_data
	
	mov r24 , r31						;Typwse tis 1ades.
	subi r24 , -48
	;rcall num_to_ascii
	rcall lcd_data
	rjmp reset2

read_key:
	ldi r24 , 20 						;Block mexri na paththei kati.
	rcall scan_keypad_rising_edge
	clr	r20
	or r20 , r24 
	or r20 , r25
	cpi r20 , 0
	breq read_key
	ret
	
print_key:
	rcall keypad_to_ascii				;Metetrepse to se ascii
	rcall lcd_data						;kai typwse ton.
	ret
	
no_key:
	ldi r24 , 20 						;Block mexri na mhn einai pathmeno
	rcall scan_keypad_rising_edge		;kati.
	clr r20
	or r20 , r24
	or r20 , r25
	cpi r20 , 0 
	brne no_key
	ret
	
;--------------------------------------------------------------------------;	

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
	
num_to_ascii:
	clr r28								;r28 = 0x00.
check_0:
	ldi r24 , '0'						;Axika these ton 0.
	cpse r24 , r28						;Elegxe an einai isos me 0.
	rjmp check_1						;An oxi, synexise.
	ret									;Alliws epistrofi.
	inc r28
check_1:
	ldi r24 , '1'						;Twra these ton 1 klp.
	cpse r24 , r28
	rjmp check_2
	ret
	inc r28
check_2:
	ldi r24 , '2'
	cpse r24 , r28
	rjmp check_3
	ret
	inc r28
check_3:
	ldi r24 , '3'
	cpse r24 , r28
	rjmp check_4
	ret
	inc r28
check_4:
	ldi r24 , '4'
	cpse r24 , r28
	rjmp check_5
	ret
	inc r28
check_5:
	ldi r24 , '5'
	cpse r24 , r28
	rjmp check_6
	ret
	inc r28
check_6:
	ldi r24 , '6'
	cpse r24 , r28
	rjmp check_7
	ret
	inc r28
check_7:
	ldi r24 , '7'
	cpse r24 , r28
	rjmp check_8
	ret
	inc r28
check_8:
	ldi r24 , '8'
	cpse r24 , r28
	rjmp check_9
	ret
check_9:
	ldi r24 , '9'
	ret
	
write_2_nibbles:
	push r24
	in r25 , PIND
	andi r25 , 0x0f
	andi r24 , 0xf0
	add r24 , r25
	out PORTD , r24
	sbi PORTD , PD3
	cbi PORTD , PD3
	pop r24
	swap r24
	andi r24 , 0xf0
	add r24 , r25
	out PORTD , r24
	sbi PORTD , PD3
	cbi PORTD , PD3
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
