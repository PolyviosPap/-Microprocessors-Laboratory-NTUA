DATA SEGMENT
    NUM1D DB 4 DUP(00)  ;Array to store the decimal digits of the 1st number.
    NUM2D DB 4 DUP(00)	;Array to store the decimal digits of the 2nd number.
    SIGN DB 1 DUP(00)	;Array sto store the sign of the operation.
    NUM1 DW 1 DUP(0000)	;In NUM1 we store the 1st number (binary).	
    NUM2 DW 1 DUP(0000) ;In NUM2 we store the 2nd number (binary).   
DATA ENDS

STACK SEGMENT
    DW 128 DUP(0)
STACK ENDS

N_LINE MACRO FAR        ;Macro N_LINE is used to change line.
    MOV DL,0DH          ;Ascii Code 13 / 0DH (carriage return) return cursor at the beginning of the line.       
    MOV AH,02H          ;
    INT 21H             ;INT 21H / AH=02H - Write character to standard output.
    MOV DL,0AH          ;Ascii Code 10 / 0AH (newl) move cursor one line down (at the same position).
    MOV AH,02H          
    INT 21H              
    ENDM


READ MACRO FAR 
    MOV AH,08H
    INT 21H
ENDM

PRINT MACRO FAR
    MOV AH,02H
    INT 21H
ENDM

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK
    
PRINT_BIN_DEC PROC        	;Print bin number stored in AX to dec format.
                            
        MOV CX,0      		
L1:
        MOV DX,0      		;Keep div with 10 till quotient == 0.
        MOV BX,10     		
        DIV BX
        PUSH DX
        INC CX
        CMP AX,0
        JNE L1
L2:
        POP DX
        ADD DL,30H			;Convert to ascii and print.
        MOV AH,2			
        INT 21H
        LOOP L2
        RET
PRINT_BIN_DEC ENDP

PRINT_BIN_HEX PROC			;Print number stored in AX in hex format.
    PUSH CX
    MOV CX,04H
L3:							
    ROL AX,04H
    MOV BX,AX
    AND BL,0FH
    MOV DL,BL
    CMP DL,00H				;We want to print 4C and not 004C so we check if MSBs are 0.
    JNE L3_2				;Dont print if the MSBs of the number is 0.
    CMP CX,01H
    JE L3_2					;When you find a digit != 0 then print.
    LOOP L3
L3_1:    
    ROL AX,04H				;Next Hex digit,we rotate left 4 times.
    MOV BX,AX
    AND BL,0FH
    MOV DL,BL
L3_2:
    CALL ASCII_HEX
    LOOP L3_1
    POP CX
    RET
    
ASCII_HEX:
    PUSH AX    
    CMP DL,09H
    JG  A_F
0_9:
    ADD DL,30H
    PRINT
    POP AX
    RET
A_F:
    ADD DL,37H
    PRINT
    POP AX
    RET    
    
PRINT_BIN_HEX ENDP





START:                      ;Initialize all registers and memory (continuous).
    MOV AX,00H              
    MOV BX,00H
    MOV CX,00H
    MOV DX,00H
    MOV SIGN[0],00H
    MOV NUM1[0],0000H
    MOV NUM2[0],0000H
    MOV DI,00H
    MOV CX,04H
INIT:
    MOV NUM1D[DI],00H
    MOV NUM2D[DI],00H
    INC DI
    LOOP INIT
    MOV BL,00H
    MOV DI,00H
INPUT_NUM1:
    CMP DI,04H
    JE INPUT_SIGN
    READ
    CMP AL,2BH              ;If + is pressed save sign and read num2.
    JE SAVE_SIGN
    CMP AL,2DH              ;If - is pressed save sign and read num2.
    JE SAVE_SIGN
    CMP AL,54H              ;If T is pressed then terminate.
    JE TERMINATE                
    CMP AL,30H              ;If dec digit is pressed save it.
    JL  INPUT_NUM1
    CMP AL,39H
    JG INPUT_NUM1
    MOV DL,AL
    PRINT
    SUB AL,30H              ;Strip the ascii code from the number.
    INC DI
    INC BL
    PUSH AX                 ;Push digit to stack.
    JMP INPUT_NUM1
    
INPUT_SIGN:
    READ
    CMP AL,2BH              ;If + is pressed save sign and read num2.
    JE SAVE_SIGN
    CMP AL,2DH              ;If - is pressed save sign and read num2.
    JE SAVE_SIGN
    CMP AL,54H              ;If T is pressed then terminate.
    JE TERMINATE
    JMP INPUT_SIGN

SAVE_SIGN:
    MOV DL,AL
    PRINT
    MOV SIGN[0],AL          ;Save sign of the operation.
    
    MOV CL,BL
    CMP BL,00H              ;If no digit was inputed dont save anything.
    JE INPUT_NUM2
    MOV DI,00H
SAVE_NUM1:
    POP AX                  ;Pop digit saved in stack from least to most significant. 
    MOV NUM1D[DI],AL        ;Save digit in memory.
    INC DI
    LOOP SAVE_NUM1
    
    
    MOV DI,00H
    MOV BL,00H
INPUT_NUM2:
    CMP DI,04H
    JE  INPUT_EQUAL
    READ
    CMP AL,3DH              ;If = is pressed then calculate.
    JE  PRINT_EQUAL
    CMP AL,54H              ;If T is pressed then terminate.
    JE TERMINATE                
    CMP AL,30H              ;If dec digit is pressed save it.
    JL  INPUT_NUM2
    CMP AL,39H
    JG INPUT_NUM2
    MOV DL,AL
    PRINT
    SUB AL,30H              ;Strip the ascii code from the number.
    INC DI
    INC BL
    PUSH AX                 ;Push digit to stack.
    JMP INPUT_NUM2
    
INPUT_EQUAL:
    READ
    CMP AL,3DH              ;If = is pressed then calculate.
    JE PRINT_EQUAL
    CMP AL,54H              ;If T is pressed then terminate.
    JE TERMINATE
    JMP INPUT_EQUAL
    
PRINT_EQUAL:
    MOV DL,AL
    PRINT
    
    MOV CL,BL
    CMP BL,00H
    JE CALCULATE            ;If no digit was inputed dont save anything.
    MOV DI,00H
SAVE_NUM2:
    POP AX                  ;Pop digit saved in stack from least to most significant.
    MOV NUM2D[DI],AL        ;Save digit in memory
    INC DI
    LOOP SAVE_NUM2

CALCULATE: 
    MOV DI,00H
    MOV AX,01H
    MOV BX,0AH
DEC_BIN:                    ;Iterate arrays NUM1D,NUM2D and calculate the numbers in binary format. 
    MOV DL,NUM1D[DI]        ;Numbers saved in NUM1,NUM2.
    PUSH AX
    MUL DX
    ADD NUM1[0],AX
    POP AX
    MOV DL,NUM2D[DI]
    PUSH AX
    MUL DX
    ADD NUM2[0],AX
    POP AX
    MUL BX
    INC DI
    CMP DI,04H
    JE CALCULATE_2
    JMP DEC_BIN

CALCULATE_2:
    CMP SIGN[0],2DH         ;If SIGN was - then we have to make NUM2 negative and add.
    JNE CALCULATE_3         
    MOV AX,NUM1[0]
    NOT NUM2[0]				;Complement of 2 of the 2nd number.
    INC NUM2[0]   
CALCULATE_3:
    MOV AX,NUM1[0]          ;Calculate the result of the operation.
    ADD AX,NUM2[0]     
    MOV CX,AX
    AND AX,8000H
    CMP AX,8000H			;If result of the operation is negative then
							;take its complement of 2 else do nothing.
    JNE CALCULATE_4
    NOT CX					;Complement of 2 of the result.
    INC CX
    MOV DL,2DH				;If we are here result is negative so print - .		
    PRINT
    MOV AX,CX
    CALL PRINT_BIN_HEX
    MOV DL,3DH				;Print = equal.  
    PRINT
    MOV DL,2DH				;If we are here result is negative so print - .
    PRINT
    JMP CALCULATE_5
CALCULATE_4:
    MOV AX,CX
    CALL PRINT_BIN_HEX		
    MOV DL,3DH				;Print = equal.  
    PRINT
CALCULATE_5:    
    MOV AX,CX   		
    CALL PRINT_BIN_DEC
    N_LINE					;Change line.
END:
    JMP START

TERMINATE:
    MOV AH,4CH
    INT 21H                ;INT 21H / AH=4C "Exit",termnite with return code.

CODE ENDS
    END START