.include "m16def.inc"

.def min_dek = r16
.def min_mon = r17
.def sec_dek = r18
.def sec_mon = r19

;min_dek|min_mon MIN : sec_dek|sec_mon SEC

.org 0x00

reset:
	ldi r24, low(RAMEND)
	out SPL, r24
	ldi r24, high(RAMEND)
	out SPH, r24
	
	ser r24							;D output. (LCD)
	out DDRD, r24

	clr r24							;A input.
	out DDRA, r24

start:								;Thetoume tin wra stin 00:00.
	clr min_dek
	clr min_mon
	clr sec_dek
	clr sec_mon
	rcall show_time					;Emfanise tin wra.
	
label1:
	rcall lcd_init
	in r20 , PINA					;Eisodos ston r20.
	
label2:
	sbrc r20 , 0					;An exei patithei to PA0
	rcall start						;midenise to xronometro.
	
	sbrc r20 , 7
	rcall inc_sec_mon
	rcall show_time
	
	ldi r24, low(995)				;Perimene gia 1 sec.				
	ldi r25, high(995)													
	rcall wait_msec														
	
	jmp label1
	
inc_sec_mon:
	inc sec_mon						;Ayksise tis monades twn sec
	cpi sec_mon , 10				;kai des an exoyn ftasei to 10.
	breq inc_sec_dek				;An nai, ayksise kai tis dekades,
	ret								;Alliws epistrofi.
	
inc_sec_dek:
	clr sec_mon						;Midenise tis monades twn sec,
	inc sec_dek						;ayksise tis dekades klp.
	cpi sec_dek , 6
	breq inc_min_mon
	ret
	
inc_min_mon:
	clr sec_dek
	inc min_mon
	cpi min_mon , 10
	breq inc_min_dek
	ret
	
inc_min_dek:
	clr min_mon
	inc min_dek
	cpi min_dek , 6
	breq clr_min_dek
	ret
	
clr_min_dek:
	clr min_dek
	ret
	
show_time:
	mov r24, min_dek 				;Oloi oi arithmoi exoun sta 4MSB tous
	ori r24, 0b00110000 			;ta bits 0011 (LLHH) kai sta 4 LSB tin
	rcall lcd_data					;dyadiki timh pou theloume na typwsoume.
	
	mov r24, min_mon
	ori r24, 0b00110000
	rcall lcd_data

	ldi r24, 0b00100000
	rcall lcd_data

	ldi r24, 'M'
	rcall lcd_data

	ldi r24, 'I'
	rcall lcd_data

	ldi r24, 'N'
	rcall lcd_data

	ldi r24, ':'
	rcall lcd_data

	mov r24, sec_dek
	ori r24, 0b00110000
	rcall lcd_data
	
	mov r24, sec_mon
	ori r24, 0b00110000
	rcall lcd_data	

	ldi r24, 0b00100000
	rcall lcd_data

	ldi r24, 'S'
	rcall lcd_data

	ldi r24, 'E'
	rcall lcd_data

	ldi r24, 'C'
	rcall lcd_data

	ret 
;--------------------------------------------------------------------------;
	
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