READ MACRO
	MOV AH,8                ;Read from stdin.
	INT 21H
ENDM

PRINT MACRO CHAR   			;Print a char.
    MOV DL,CHAR
    MOV AH,2
    INT 21H
ENDM

PRINT_STR MACRO STRING		;Print string.
	MOV DX,OFFSET STRING
	MOV AH,9
	INT 21H
ENDM

DATA SEGMENT
	MS1 DB "Give 4 octal digits:", '$'
	MS2 DB 0AH,0DH,'$'
	MS3 DB "Decimal:", '$'
	VR1 DB 64D
	VR2 DB 08D
	VR3 DB 1D
	VR4 DB 125
	DOT DB '.'
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

PRINT_DEC PROC NEAR   		;Print hex to dec
        MOV CX,0      		;format.
L1:
        MOV DX,0      		;Keep div with 10,
        MOV BX,10     		;till quotient == 0.
        DIV BX
        PUSH DX
        INC CX
        CMP AX,0
        JNE L1
L2:
        POP DX
        ADD DL,30H			;Convert to ascii
        MOV AH,2			;and print.
        INT 21H
        LOOP L2
        RET
PRINT_DEC ENDP

MAIN PROC FAR
	MOV AX,DATA
    MOV DS,AX

START:
	
	PRINT_STR MS1;			;Print start message.

READ_D1:	
	READ					;Read 1st digit.
	CMP AL,43H				;Check if it is 'C'
	JE THE_END				;or 'c' and if so, terminate
	CMP AL,63H				;the program.
	JE THE_END
	CMP AL,30H				;Now check if it is valid, 
	JL READ_D1				;if not ignore it and 
	CMP AL,37H				;repeat.
	JG READ_D1
	PRINT AL 				;Print it.
	AND AL,0FH				;Convert it to hex.
	MUL VR1					;Multiply it with 8^2=64.
	MOV BX,AX				;Transfer it to BL.
	
READ_D2:	
	READ					;Read 2nd digit.
	CMP AL,43H				;Same logic.
	JE THE_END
	CMP AL,63H
	JE THE_END
	CMP AL,30H
	JL READ_D2
	CMP AL,37H
	JG READ_D2
	PRINT AL
	AND AL,0FH
	MUL VR2					;Multiply it with 8.
	ADD BX,AX				;Add it to BL.
	
READ_D3:	
	READ					;Read 3rd digit.
	CMP AL,43H				;Same logic.
	JE THE_END
	CMP AL,63H
	JE THE_END
	CMP AL,30H
	JL READ_D3
	CMP AL,37H
	JG READ_D3
	PRINT AL
	AND AL,0FH
	MUL VR3
	ADD BX,AX				;Add it to BL.
	
	PRINT DOT				
	
READ_D4:	
	READ					;Read 4th digit.
	CMP AL,43H				;Same logic.
	JE THE_END
	CMP AL,63H
	JE THE_END
	CMP AL,30H
	JL READ_D3
	CMP AL,37H
	JG READ_D3
	PRINT AL				;Print the final digit.
	
	AND AX,0FH
	MOV CX,AX				;CX = AX.
	
	MUL VR4					;AX = 125*Digit4
	PUSH AX	

	
	PRINT_STR MS2 			;Change line.
    PRINT_STR MS3 			;Print second message.
	MOV AX,BX				;About to convert and
	CALL PRINT_DEC			;print the first 3 digits.
	PRINT DOT
	POP AX					
	CALL PRINT_DEC			;Print the Digit4*125.
	
	PRINT_STR MS2 			;Change line.
	JMP START				;Repeat.
	
THE_END:					;Terminate the program.
	MOV AH, 0
	INT 21H
	
MAIN ENDP

CODE ENDS
    END MAIN