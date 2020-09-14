INCLUDE MACROS.ASM
    .8086
    .MODEL SMALL
    .STACK 256
    
.DATA 
    HEADER DB "START (Y,N):$"
    WRONG DB "ERROR$"
    ZERO DB "0.0$"
    LOWS DB "0.$" 
    
.CODE

MAIN PROC FAR
        MOV AX,@DATA
        MOV DS,AX
        
BEGIN:
    PRINT_STRING HEADER        ;receive 1st hex
    ;FIRST HEX DIGIT
    CALL HEX_KEYB
    CMP AL,'N'
    JE QUIT
    MOV BH,AL
    
    ;SECOND HEX DIGIT          ;receive 2nd hex
    CALL HEX_KEYB
    CMP AL,'N'
    JE QUIT
    ROL AL,4
    MOV BL,AL
    
    ;THIRD HEX DIGIT
    CALL HEX_KEYB		;receive 3rd hex
    CMP AL,'N'
    JE QUIT
    ADD BL,AL
    
    NEW_LINE
    MOV AX,BX			;the input hexs are in AX
    CMP AX,0                    
    JNE CONT
    PRINT_STRING ZERO
    NEW_LINE
    JMP BEGIN
    
    
CONT:
    MOV DX,10D                  ;check in what part of the diagram the 
    MUL DX			;numbers match
    CMP AX,20475D
    JBE PARTA
    CMP AX,36855D
    JBE PARTB
    CMP AX,40950D
    JB PARTC
    JMP FALSE
    
     
PARTA:				;for temps between 0-500
    MOV DX,5000D
    MUL DX
    MOV CX,20475D
    MOV BX,CX
    SHR BX,1
    ADD AX,BX
    DIV CX
    JMP CONV
         
PARTB:				;for temps between 500-700
    SUB AX,20475D
    MOV DX,2000D
    MUL DX
    MOV CX,16380D
    MOV BX,CX
    SHR BX,1
    ADD AX,BX
    DIV CX
    ADD AX,5000D
    JMP CONV
    
PARTC:				;for temps between 700-999.9
    SUB AX,36855D
    MOV DX,3000D
    MUL DX
    MOV CX,4095D
    MOV BX,CX
    SHR BX,1
    ADD AX,BX
    DIV CX
    ADD AX,7000D
    JMP CONV
    
CONV:				;if number is below 1.0 continue or
    MOV CX,0			;or else jump to DIGIT
    CMP AX,10D
    JGE DIGIT
    PRINT_STRING LOWS
    MOV DX,0
    MOV BX,10D
    DIV BX
    PUSH DX
    POP DX
    PRINT_DEC
    NEW_LINE
    JMP BEGIN
DIGIT:				;push the right digits for print
    MOV DX,0
    MOV BX,10D
    DIV BX
    PUSH DX
    INC CX
    CMP AX,0
    JNE DIGIT
    DEC CX
TIGID:				;pop the digits and print them with MACRO 
    POP DX			;print_dec
    PRINT_DEC
    LOOP TIGID
    PRINT "."
    POP DX
    PRINT_DEC
    NEW_LINE
    JMP BEGIN 
    
    
FALSE:				;print error for temp>999.9
    PRINT_STRING WRONG
    NEW_LINE    
    JMP BEGIN
    
QUIT:
    EXIT
MAIN ENDP
    
    
    
    
;---------PROCS----------

HEX_KEYB PROC NEAR
    
    PUSH DX
    
TRYAGAIN:
    ;check the number
    READ
    CMP AL,30H
    JL TRYAGAIN
    CMP AL,39H
    JG STEP1
    SUB AL,30H
    JMP STEP2
    
STEP1: 
    ;check for right char
    CMP AL,'N'
    JE STEP2
    CMP AL,'A'
    JL TRYAGAIN
    CMP AL,'F'
    JG TRYAGAIN
    SUB AL,37H
    
STEP2:
    POP DX
    RET
    
HEX_KEYB ENDP


PRINT_DEC MACRO
    ADD DL,30H
    MOV AH,2
    INT 21H
ENDM



