.include "m16def.inc"

.DSEG
	_tmp_:.byte 2

.CSEG
.org 0x00

reset:
	ldi r24, low(RAMEND)						;Init stack.
	out SPL, r24
	ldi r24, high(RAMEND)
	out SPH, r24

	ser r24
	out DDRB, r24								;A,B,D are outputs.
	out DDRA, r24
	out DDRD, r24
	ldi r24, 0xF0								;4 MSB are outputs
	out DDRC, r24								;in portC
	rcall scan_keypad_rising_edge				;call to initialise pointer _tmp_

main:
	rcall read_key								;waits until single key is pressed
	movw r20,r24						
	rcall wait_key								;waits for all keys to be unpressed
	rcall read_key								;read second key
	cpi r25, 0x40								;check 
	brne not_valid
	cpi r21, 0x10
	brne not_valid
	rjmp valid

not_valid:
	ldi		r21,	0x08						;Set counter to 8 (on + off time = 0.5s. 0.5 * 8 = 4s)
not_valid2:			
	ser		r20
	out 	PORTA,	r20							;Turn on all Port B LEDs
	ldi		r24,	low(250)
	ldi		r25,	high(250)
	rcall	wait_msec							;Delay 0.25s
	clr		r20
	out		PORTA,	r20 						;Turn off all Port B LEDs
	ldi		r24,	low(250)
	ldi		r25,	high(250)
	rcall	wait_msec							;Delay 0.25s
	dec		r21
	cpi		r21,	0
	brne	not_valid2 								;Loop if timer > 0
	rjmp	main								;Repeat entire procedure

valid:
	ser		r20									;Turn all Port B LEDs on
	out		PORTA,	r20
	ldi		r24,	low(4000)
	ldi		r25,	high(4000)					;Delay 4s
	rcall	wait_msec
	clr		r20									;Turn off all Port B LEDs
	out		PORTA,	r20
	rjmp	main								;Repeat entire procedure

read_key:
	ldi r24,20									;20ms xronos spinithirismou
	rcall scan_keypad_rising_edge				
	clr r20										;r20 OR me r24,r25 ,an estw 1 bit exei patithei o r20 != 0
	or r20,r24
	or r20,r25
	cpi r20,0									;an den exei patithei kati (r20=0) loop mexri na patithei
	breq read_key
	ret

wait_key:
	ldi r24,20									;20ms
	rcall scan_keypad_rising_edge
	clr r20										;Check if any key is pressed
	or r20,r24
	or r20,r25
	cpi r20,0
	brne wait_key								;an einai patimeno, looparei edw mesa mexri na ksepatithoun ola kai to apotelesma to "petame", giati tha to paroume sto epomeno scan_keypad
	ret

;Assembly drivers for 4x4 keypad.	
keypad_to_ascii: 
	movw r26 ,r24 
	ldi r24 ,'*'
	sbrc r26 ,0
	ret
	ldi r24 ,'0'
	sbrc r26 ,1
	ret
	ldi r24 ,'#'
	sbrc r26 ,2
	ret
	ldi r24 ,'D'
	sbrc r26 ,3 
	ret 
	ldi r24 ,'7'
	sbrc r26 ,4
	ret
	ldi r24 ,'8'
	sbrc r26 ,5
	ret
	ldi r24 ,'9'
	sbrc r26 ,6
	ret
	ldi r24 ,'C'
	sbrc r26 ,7
	ret
	ldi r24 ,'4'
	sbrc r27 ,0 
	ret
	ldi r24 ,'5'
	sbrc r27 ,1
	ret
	ldi r24 ,'6'
	sbrc r27 ,2
	ret
	ldi r24 ,'B'
	sbrc r27 ,3
	ret
	ldi r24 ,'1'
	sbrc r27 ,4
	ret
	ldi r24 ,'2'
	sbrc r27 ,5
	ret
	ldi r24 ,'3'
	sbrc r27 ,6
	ret
	ldi r24 ,'A'
	sbrc r27 ,7
	ret
	clr r24
	ret


scan_keypad_rising_edge:
	mov r22,r24					
	rcall scan_keypad 			
	push r24 					
	push r25
	mov r24,r22					
	ldi r25 ,0					
	rcall wait_msec
	rcall scan_keypad 			
	pop r23						
	pop r22
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_)
	ldi r27 ,high(_tmp_)
	ld r23 ,X+
	ld r22 ,X
	st  X,r24
	st -X,r25
	com r22 
	and r24 ,r22
	and r25 ,r23
	ret
 
scan_row:
	ldi r25 ,0x08
back_:
	lsl r25
	dec r24
	brne back_
	out PORTC,r25
	nop
	nop 		
	in r24 ,PINC
	andi r24 ,0x0f
	ret

scan_keypad:
	ldi r24 ,0x01
	rcall scan_row
	swap r24 	
	mov r27 ,r24
	ldi r24 ,0x02
	rcall scan_row
	add r27 ,r24 
	ldi r24 ,0x03
	rcall scan_row
	swap r24 	
	mov r26 ,r24
	ldi r24,0x04
	rcall scan_row
	add r26 ,r24 
	movw r24 ,r26 

	clr r20
	out PORTC, r20

	ret

wait_usec:
	sbiw r24 ,1 
	nop 			
	nop 	
	nop 			
	nop 			
	brne wait_usec 	
	ret 			

wait_msec:		
	push r24 	
	push r25 	

	ldi r24 ,low(998)	
	ldi r25 ,high(998)
	rcall wait_usec 
	      		
	pop r25 		
	pop r24	 	
	sbiw r24 , 1 
	brne wait_msec 	
	ret 
