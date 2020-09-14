;The user gives as input from the keyboard two 2-digit hexadecimal numbers.
;The program prints them and after that, their sum and sub in 
;decimal format.



INCLUDE MACROS.ASM
    .8086
    .MODEL SMALL
    .STACK 256    
;------DATA SEGMENT------------ 
.DATA
    SPACE DB " $"
    x_EQUALS DB "x=$" 
    y_EQUALS DB "y=$" 
    SUMMSG DB "x+y=$"
    SUBMSG DB "x-y=$"
    MINUSSUBMSG DB "x-y=-$"

;------CODE SEGMENT------------	   
.CODE
;----MAIN------------------
MAIN PROC FAR
	MOV AX,@DATA
	MOV DS,AX 
START:		
;FIRST NUMBER
	CALL HEX_KEYB 
	ROL AL,4  			        ;multiply x16 and 
    MOV DL,AL   		        ;put input in DL register		
	CALL HEX_KEYB
	ADD DL,AL
	PRINT_STRING SPACE				    ;DL has the first number    
;SECOND NUMBER	
	CALL HEX_KEYB 
	ROL AL,4  			        ;multiply x16 and 
    MOV CL,AL   		        ;put input in CL register		
	CALL HEX_KEYB
	ADD CL,AL				    ;CL has the second number
	NEW_LINE
;PRINT FIRST
    PRINT_STRING x_EQUALS
    CALL PRINT_HEX
    PRINT_STRING SPACE
;PRINT SECOND            
    PRINT_STRING y_EQUALS
    MOV BL,DL
    MOV DL,CL
    CALL PRINT_HEX
    
    NEW_LINE 
    PUSH DX                      ;push the 2 numbers for later use
    PUSH BX
;ADD-SUB
    ADD DL,BL                    ;add them
    CMP DL,BL                    ;compare them with the original numbers 
    JGE NEXT                     ;to see if the sum exceeds 255 or not
    MOV DH,1
    JMP GO
NEXT:
    CMP DL,CL
    JGE GO
    MOV DH,1
GO: 
    MOV AX,DX        			;print the sum from AX		
    PRINT_STRING SUMMSG
    CALL PRINT_DEC 
    PRINT_STRING SPACE 
    POP BX                      ;pop the original numbers for the difference
    POP DX					
    CMP BL,DL                   ;check if sum is below zero
    JZ CONT
    JNA MINUS 
CONT:                           ;continue to the right block
    SUB BL,DL
    MOV DL,BL
    MOV AX,DX 
    PRINT_STRING SUBMSG
    CALL PRINT_DEC
    JMP END					
    
MINUS:							 
    SUB DL,BL
    MOV AX,DX					
    PRINT_STRING MINUSSUBMSG
    CALL PRINT_DEC
    JMP END
    
  

END:        
	EXIT
MAIN ENDP

;----------PROCS----------------

HEX_KEYB PROC NEAR
;returns in AL resister the ASCII code of the pressed key.
;Accepts only 0...9 and A...F (Hex digits) and character T.  
    PUSH DX
IGNORE:
	;check for valid number
    READ
    CMP AL,30H			;if ASCIIcode < 30 ('0') don't accept it
    JL IGNORE
    CMP AL,39H			;if ASCIIcode < 39 ('9') chech for valid character
    JG ADDR1
    SUB AL,30H			;if 30 < ASCIIcode < 39 subtract 30 to make hex number
    JMP ADDR2
ADDR1: 
	;check for valid character       
    CMP AL,'T'			;if ASCIIcode = 'T' accept it
    JE ADDR2
    CMP AL,'A'			;if ASCIIcode < 'A' don't accept it
    JL IGNORE
    CMP AL,'F'			;if ASCIIcode > 'F' don't accept it
    JG IGNORE
    SUB AL,37H			;if 'A' < ASCIIcode < 'F' subtract 37 to make hex number
ADDR2:
    POP DX
    RET
HEX_KEYB ENDP     

PRINT_DEC PROC NEAR
;input: number in AX 
;output: print the decimal number
    MOV CX,0
LOOP_10:
    MOV DX,0
    MOV BX,10D 
    DIV BX			;divide number with 10
    PUSH DX
    INC CX             	;save units     
    CMP AX,0 			;if quotient zero I have splitted 
    JNE LOOP_10  	;the whole number into dec digits     

PRINT_DIGITS_10:
    POP DX			;pop dec digit to be printed
    PRINTER			;print
    LOOP PRINT_DIGITS_10	;Loop for all digits        
    RET
ENDP PRINT_DEC

PRINT_HEX PROC NEAR
;input: number in DL 
;output: print the hexadecimal number
;FIRST DIGIT
    MOV BH,DL 
    AND BH,0F0H                 ;isolate first digit's bits (35-->30)
    ROR BH,4                    ;rotate 4 times right (30-->3)
    
    CMP BH,9                    
    JG ADDRH1
    ADD BH,30H                  ;if digit < 9 make ASCII by adding 30H (33H)
    JMP ADDRH2
ADDRH1:
    ADD BH,37H                  ;if digit > 9 make ASCII by adding 37H
ADDRH2:
    PRINT BH                    ;print first digit (3: ASCII 33)
;SECOND DIGIT   
    MOV BH,DL                   
    AND BH,0FH                  ;isolate second digit's bits (35-->50)
    CMP BH,9
    JG ADDRH3
    ADD BH,30H                  ;if digit < 9 make ASCII by adding 30H (35H)
    JMP ADDRH4
ADDRH3:
    ADD BH,37H                  ;if digit > 9 make ASCII by adding 37H
ADDRH4:
    PRINT BH                    ;print second digit (5: ASCII 35)
    RET   
ENDP PRINT_HEX

PRINTER MACRO                  ;MACRO for printing a decimal
    ADD DL,30H
    MOV AH,2
    INT 21H
ENDM