;This program prints the hexadecimal, decimal, octal and binary format of the
;hexadecimal number given by the user.



INCLUDE MACROS.ASM
    .8086
    .MODEL SMALL
    .STACK 256    
;------DATA SEGMENT------------
.DATA
    EQUAL DB "=$"

;------CODE SEGMENT------------    	   
.CODE
;----MAIN------------------
MAIN PROC FAR
	MOV AX,@DATA
	MOV DS,AX
	JMP START1 
START:
     NEW_LINE
START1:	
     ;FIRST HEX DIGIT	
     CALL HEX_KEYB
     CMP AL,'Q'         
     JE QUIT           	;if input is 'Q' quit 
     ROL AL,4  			;multiply x16 and 
     MOV DL,AL   		;put input in DL register 

     
     ;SECOND HEX DIGIT
     CALL HEX_KEYB 
     CMP AL,'Q'
     JE QUIT
     ADD DL,AL 			;add units in DL and now DL has the right hex number
     PUSH DX 			;save DL for use in procs
        
     NEW_LINE 
     CALL PRINT_HEX
     PRINT_STRING EQUAL 
     POP DX             ;restore DL for use in "PRINT_DEC"
     PUSH DX            ;save DL for use in proc "PRINT_OCT"
     CALL PRINT_DEC
     PRINT_STRING EQUAL
     POP DX 			;restore DL for use in "PRINT_OCT"
     PUSH DX			;save DL for use in proc "PRINT_BIN" 
     CALL PRINT_OCT
     PRINT_STRING EQUAL 
     POP DX 			;restore DL for use in "PRINT_BIN"
     CALL PRINT_BIN

     JMP START
QUIT:
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
    CMP AL,'Q'			;if ASCIIcode = 'Q' accept it
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

PRINT_DEC PROC NEAR
;input: number in DL 
;output: print the decimal number
    MOV AH,0
    MOV AL,DL 			    ;AX = 00000000xxxxxxxx(8 bit number to be printed)
    MOV BL,10 	
    MOV CX,1 			    ;decades counter
LOOP_10: 
    DIV BL			         ;divide number with 10
    PUSH AX             	;save units     
    CMP AL,0 			    ;if quotient zero I have splitted 
    JE PRINT_DIGITS_10       ;the whole number into dec digits     
    INC CX			        ;increase number of decades
    MOV AH,0   
    JMP LOOP_10			    ;if quotient is not zero I have to divide again
PRINT_DIGITS_10:
    POP DX			         ;pop dec digit to be printed
    MOV DL,DH
    MOV DH,0			    ;DX = 00000000xxxxxxxx (ASCII of number to be printed)
    ADD DX,30H			    ;make ASCII code
    MOV AH,2
    INT 21H			        ;print
    LOOP PRINT_DIGITS_10	;Loop for all digits        
    RET
ENDP PRINT_DEC          

PRINT_OCT PROC NEAR
;input: number in DL 
;output: print the octal number
    MOV AH,0
    MOV AL,DL 
    MOV BL,8 
    MOV CX,1 
LOOP_8: 
    DIV BL
    PUSH AX                  
    CMP AL,0 
    JE GOOUT_8              
    INC CX
    MOV AH,0   
    JMP LOOP_8
GOOUT_8: 
    MOV DH,AL
    PUSH DX   
    
    POP DX
PRINT_DIGITS_8:
    POP DX
    MOV DL,DH
    MOV DH,0
    ADD DX,30H
    MOV AH,2
    INT 21H
    LOOP PRINT_DIGITS_8       
    RET
ENDP PRINT_OCT       

PRINT_BIN PROC NEAR
;input: number in DL 
;output: print the binary number
    MOV AH,0
    MOV AL,DL 
    MOV BL,2 
    MOV CX,1 
LOOP_2: 
    DIV BL
    PUSH AX                  
    CMP AL,0 
    JE GOOUT_2              
    INC CX
    MOV AH,0   
    JMP LOOP_2
GOOUT_2: 
    MOV DH,AL
    PUSH DX   
    
    POP DX
PRINT_DIGITS_2:
    POP DX
    MOV DL,DH
    MOV DH,0
    ADD DX,30H
    MOV AH,2
    INT 21H
    LOOP PRINT_DIGITS_2       
    RET
ENDP PRINT_BIN 