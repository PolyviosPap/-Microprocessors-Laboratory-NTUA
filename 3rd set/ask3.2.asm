.include "m16def.inc"
.DEF A  = R21
.DEF B  = R22
.DEF C  = R23
.DEF D  = R24
.DEF E  = R25
.DEF DN = R18
.DEF EN = R19

START:
	CLR R26
	OUT DDRC,R26		;Setting input at PORTC.
	SER R27
	OUT DDRA,R27 		;Setting output at PORTA.
	
INPUT:
	IN R9,PINC 			;Reading input from PORTC.
	MOV A,R9			;Reading A.
	ANDI A,0x01			;A will be at the LSB of the input.
	
	LSR R9				;Left shift logical so B is at the LSB of the register R9.
	MOV B,R9			;Reading B.
	ANDI B,0x01			;;A will be at the LSB of the R9.
	
	LSR R9				;C.
	MOV C,R9
	ANDI C,0x01
	
	LSR R9				;D.
	MOV D,R9
	ANDI D,0x01
	
	MOV DN,D 			
	COM DN
	ANDI DN,0x01		;DN = D'.
	
	LSR R9				;E.
	MOV E,R9
	ANDI E,0x01
	
	MOV EN,E			;EN.
	COM EN
	ANDI EN,0x01		;EN = E'.
	
F0:
	MOV R10,A
	MOV R11,C
	AND R10,B			;R10 = AB.
	AND R11,B			;R11 = BC.
	MOV R12,C
	MOV R13,E
	AND R12,D			;R12 = CD.
	AND R13,D			;R13 = DE.
	
	OR R11,R10			;R11 = AB + BC.
	OR R11,R12			;R11 = AB + BC + CD.
	OR R11,R13			;R11 = AB + BC + CD + DE.
	COM R11				;R11 = F0.
	MOV R20,R11
	ANDI R20,0x01
F1:
	AND R10,R12			;R10 = ABCD.
	MOV R13,DN
	AND R13,EN			;R13 = D'E'.
	OR R10,R13			;R10 = ABCD + D'E' = F1.
	
F2:
	MOV R12,R20			;R12 = F0.
	OR R12,R10			;R12 = F0 + F1 = F2.

	MOV R14,R12			;R14 = F0.
	LSL R14				;Left shift logical so F0 is at the 2nd LSB of R14.
	OR R14,R10			;F1 at the LSB of R14.
						
	LSL R14				;Left shift logical of R14 so F0 at 3rd LSB and F1 at 2nd LSB.
	OR R14,R20			;F2 at LSB of R14.
	OUT PORTA,R14		;Output result.
END: