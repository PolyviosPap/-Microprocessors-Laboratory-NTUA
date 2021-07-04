READ MACRO
	MOV AH,8
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
	MS1 DB "Give 3 dec digits: ", '$'
	MS2 DB 0AH,0DH,'$'
	MS3 DB "Hex: ", '$'
	VR1 DB 100D
	VR2 DB 10D
	
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK
	
IS_NUMBER PROC NEAR
	ADD AL,30H
	PRINT AL
RET
	
IS_LETTER PROC NEAR
	ADD AL,37H
	PRINT AL
RET

MAIN PROC FAR
	MOV AX,DATA
    MOV DS,AX

START:

	PRINT_STR MS1;			;Print start message.
	
READ_D1:	
	READ					;Read 1st digit.
	CMP AL,51H				;Check if it is 'Q'
	JE THE_END				;or 'q' and if so, terminate
	CMP AL,71H				;the program.
	JE THE_END
	CMP AL,30H				;Now check if it is valid, 
	JL READ_D1				;if not ignore it and 
	CMP AL,39H				;repeat.
	JG READ_D1
	AND AH,00H
	PUSH AX					;Save it as ASCII.

READ_D2:	
	READ					;Read 2nd digit.
	CMP AL,51H				;Same logic.
	JE THE_END
	CMP AL,71H
	JE THE_END
	CMP AL,30H
	JL READ_D2
	CMP AL,39H
	JG READ_D2
	AND AH,00H
	PUSH AX					;Save the 2nd one.
	
READ_D3:	
	READ					;Read 3rd digit.
	CMP AL,51H				;Same logic.
	JE THE_END
	CMP AL,71H
	JE THE_END
	CMP AL,30H
	JL READ_D3
	CMP AL,39H
	JG READ_D3
	AND AH,00H
	PUSH AX					;Save the 3rd,
	
READ_TILL_ENTER:			;Read the last key.
	READ
	CMP AL,0DH				;If it is 'ENTER'
	JE PRINT_DEC			;print the dec num.
	CMP AL,51H				;Check if you have to
	JE THE_END				;terminate the program.
	CMP AL,71H
	JE THE_END
	CMP AL,30H				;And now check if it is valid.
	JL READ_TILL_ENTER		;If not, read again.
	CMP AL,39H
	JG READ_TILL_ENTER
	POP BX					;The (now) 2nd digit.
	POP CX					;The (now) 1st digit.
	POP DX					;We don't need that anymore.
	AND AH,00H
	PUSH CX					;Save the 1st,
	PUSH BX					;etc.
	PUSH AX
	JMP READ_TILL_ENTER		;Repeat.
	
PRINT_DEC:
	POP CX					;3rd digit.
	POP BX					;2nd digit.
	POP AX					;1st digit.
	PUSH BX
	PUSH CX
	PRINT AL				;Print the 1st digit.
	AND AH,00H
	AND AL,0FH				;Convert it into hex,
	MUL VR1					;multiply it by 100
	MOV BX,AX				;and store it into BX.
	
	POP CX					;3rd didit.
	POP AX					;2nd digit.
	PRINT AL				;Same logic.
	AND AH,00H
	AND AL,0FH
	MUL VR2					;Multiply it by 10
	ADD BX,AX				;and add it to BX.
	
	MOV AX,CX				;3rd digit.
	PRINT AL				;Same logic.
	AND AH,00H
	AND AL,0FH
	ADD BX,AX
	
	PRINT_STR MS2 			;Change line.
    PRINT_STR MS3 			;Print second message.
	
	MOV AX,BX				;BX holds the number.
	MOV AL,AH				;Move the 1st hex digit to AL.
	CMP AL,09H				;Check if it's a number or
	JLE L1					;a letter.
	CALL IS_LETTER
	JMP L2
L1:
	CALL IS_NUMBER
L2:
	MOV AX,BX				;Same logic.
	AND AL,11110000b
	ROR AL,4
	CMP AL,09H
	JLE L3
	CALL IS_LETTER
	JMP L4
L3:
	CALL IS_NUMBER
L4:
	MOV AX,BX
	AND AL,00001111b
	CMP AL,09H
	JLE L5
	CALL IS_LETTER
	JMP L6
L5:
	CALL IS_NUMBER
L6:
	PRINT_STR MS2 			;Change line.
	JMP START
	
THE_END:					;Terminate the program.
	MOV AH, 0
	INT 21H
	
MAIN ENDP

CODE ENDS
    END MAIN