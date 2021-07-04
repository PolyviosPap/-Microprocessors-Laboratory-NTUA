DATA SEGMENT
    A DB 16 DUP(?)      ;Array A of 16 elements,on which we will store the 16 ascii chars.
    MIN DB 3 DUP(?)      ;Array MIN of 2 elements,on which we will store the values of the two min numbers and a flag to show direction.
ends

;MIN[00H] has the 1st minimum.
;MIN[01H] has the 2nd minimim.
;MIN[02H] has the input order(00H if MIN[00] was inputed first and 01H for the opposite).

N_LINE MACRO            ;Macro N_LINE is used to change line.
    MOV DL,0DH          ;Ascii Code 13 / 0DH (carriage return) return cursor at the beginning of the line.       
    MOV AH,02H          ;
    INT 21H             ;INT 21H / AH=02H - Write character to standard output.
    MOV DL,0AH          ;Ascii Code 10 / 0AH (newl) move cursor one line down (at the same position).
    MOV AH,02H          
    INT 21H              
    ENDM

HYPHEN MACRO            ;Macro HYPHEN is used to print - to standard output.
    MOV DL,2DH          ;Ascii code for - .
    MOV AH,02H
    INT 21H
    ENDM

INIT_DI_CX MACRO
    MOV DI,00H          ;Initializing DI and CX so we can LOOP.
    MOV CX,10H 
    ENDM
    


CODE SEGMENT
start:
    

    INIT_DI_CX
    MOV MIN[00H],3AH
    MOV MIN[01H],3AH
    MOV MIN[02H],01H
INIT_A:
    MOV A[DI],00H       ;Initializimg Array A to null so our program is continuous.
    INC DI
    LOOP INIT_A         ;Loop UNTIL CX=0.    
    
    INIT_DI_CX
        
INPUT:                  ;Input until 16 chars(upper,lower,number or space) or until enter is pressed.
    MOV AH,08H
    INT 21H             ;INT 21H / AH=02H - Read character from standard input,no echo.

STAR:                   ;Check if given char is star.
    CMP AL,2AH
    JE TERMINATE                      
WHITESPACE:             ;Check if given char is whitespace.
    CMP AL,20H          
    JE VALID_CHAR       
ENTER:                  ;Check if given char is enter.
    CMP AL,0DH
    JE  OUTPUT
NUMBER:                 ;Check if given char is number.
    CMP AL,30H
    JL INPUT
    CMP AL,39H
    JG UPPERCASE
    CMP AL,MIN[00H]     ;Check if input current number is one of the two minimum.
    JL  SAVE_MIN1
    CMP AL,MIN[01H]
    JL  SAVE_MIN2
    JMP VALID_CHAR
SAVE_MIN1:
    MOV DL,MIN[00H]
    MOV MIN[00H],AL
    MOV MIN[01H],DL
    MOV MIN[02H],01H
    JMP VALID_CHAR
SAVE_MIN2:
    MOV MIN[01H],AL
    MOV MIN[02H],00H
    JMP VALID_CHAR  
UPPERCASE:              ;Check if given char is uppercase letter.
    CMP AL,41H
    JL INPUT
    CMP AL,5AH
    JG LOWERCASE
    JMP VALID_CHAR
LOWERCASE:              ;Check if given char is lowercase letter.
    CMP AL,61H
    JL INPUT
    CMP AL,7AH
    JG INPUT
    JMP VALID_CHAR
VALID_CHAR:             ;If a valid char was given save it to array A.
    MOV A[DI],AL
    INC DI
    INC BL
    LOOP INPUT

OUTPUT:
    INIT_DI_CX
        
OUTPUT_1ST_LINE:        ;Here we display the 1st line that is all the input characters in line.
    MOV DL,A[DI]
    MOV AH,02H
    INT 21H              
    INC DI
    LOOP OUTPUT_1ST_LINE
    N_LINE             
                        
OUTPUT_2ND_LINE:        ;Here we display the 2nd line that is uppercase-lowercase-numbers.
    INIT_DI_CX

PRINT_UPPER:            ;Check every input character and if it is uppercase A-Z and print it.
    MOV AL,A[DI]
    CMP AL,41H
    JL ITERATE_UPPER
    CMP AL,5AH
    JG ITERATE_UPPER
    MOV DH,00H
    MOV DL,A[DI]
    MOV AH,02H
    INT 21H
ITERATE_UPPER:
    INC DI
    LOOP PRINT_UPPER
    HYPHEN
    INIT_DI_CX    

PRINT_LOWER:            ;Check every input character and if it is lowercase a-z and print it.
    MOV AL,A[DI]
    CMP AL,61H
    JL ITERATE_LOWER    
    CMP AL,7AH
    JG ITERATE_LOWER
    MOV DH,00H
    MOV DL,A[DI]
    MOV AH,02H
    INT 21H
ITERATE_LOWER:
    INC DI
    LOOP PRINT_LOWER
    HYPHEN              ;Print hyphen.
    INIT_DI_CX    

PRINT_NUMBERS:          ;Check every input character and if it is number 0-9 and print it.
    MOV AL,A[DI]
    CMP AL,30H
    JL ITERATE_NUMBERS
    CMP AL,39H
    JG ITERATE_NUMBERS
    MOV DH,00H
    MOV DL,A[DI]
    MOV AH,02H
    INT 21H
ITERATE_NUMBERS:
    INC DI
    LOOP PRINT_NUMBERS

    N_LINE        
OUTPUT_3RD_LINE:        ;Here we display the 3rd line the two min numbers that inputed.
    XOR CX,CX
    MOV CL,MIN[02H]
    MOV DI,CX
    CMP MIN[DI],3AH
    JE NEXT
    MOV DL,MIN[DI]
    MOV AH,02H
    INT 21H
NEXT:    
    XOR DI,01H
    CMP MIN[DI],3AH
    JE RESTART
    MOV DL,MIN[DI]
    MOV AH,02H
    INT 21H

RESTART:
    N_LINE
    JMP START           ;Continuous operation.

TERMINATE:
    MOV AH,4CH
    INT 21H             ;INT 21H / AH=4C "Exit",termnite with return code.
           
end start