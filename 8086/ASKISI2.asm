;This program stores numbers 254,253,...,0,1,255 in continuous memory places starting at
;memory TABLE.
;Then it finds and prints the average of the even numbers between 0 and 255 and
;the maximum and minumum of numbers 0 ... 255 in hex.


INCLUDE MACROS.ASM 
    .8086
    .MODEL SMALL
    .STACK 256
;------DATA SEGMENT------------ 
    .DATA                          
    HEADER DB "Exercise 2$"
    STORING DB "Storing...$"
    SPACE DB " $" 
    TABLE DB 256 DUP(?) 
    MIN db ?
    MAX db ?

;------CODE SEGMENT------------
    .CODE 
    ;----MAIN------------------
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
        
    PRINT_STRING HEADER 
    NEW_LINE
        
    MOV AL,254				;first number to be stored
    MOV DI,0   				;initialize index
STORE_ARRAY:            
    MOV [TABLE + DI],AL     ;store numbers in TABLE[256]   
    DEC AL				    ;next number to be stored
    INC DI				    ;i++
    CMP AL,0 				;when 1 is stored exit the loop		
    JNE STORE_ARRAY
    MOV [TABLE + DI],AL     ;store 0
    INC DI
    MOV AL,255
    MOV [TABLE + DI],AL     ;store 255 
    
	MOV DI,0
    MOV AH,0     
CONTINUE_ADD: 
    MOV AL,[TABLE + DI] 	;load number
    ADD DX,AX 				;add number
    ADD DI,2				;load only even numbers  
    CMP DI,256
    JL CONTINUE_ADD       	;if di gets = 256 exit
    
    MOV AX,DX
    MOV BH,0
    MOV BL,128
    DIV BL				    ;divide sum with 128 to find average
    
    MOV AH,0   				     
    CALL PRINT_HEX
    NEW_LINE   
    
    MOV DI,0xFFFF
    MOV MIN,0xFF
    MOV MAX,0
FIND_MIN_MAX: 
    INC DI
    MOV AL,[TABLE + DI]
    CMP MIN,AL				
    JNA SKIP
    MOV MIN,AL				;if current number < MIN --> MIN = current number
     
SKIP:
    CMP MAX,AL
    JA CM
    MOV MAX,AL				;if current number > MAX --> MAX = current number
CM: CMP DI,256    
    JNE FIND_MIN_MAX 
 
MIN_MAX_FOUND:              ;when MIN and MAX are found print them
    MOV AH,0
    MOV AL,MIN
    CALL PRINT_HEX
    PRINT_STRING SPACE 
    MOV AH,0
    MOV AL,MAX
    CALL PRINT_HEX 
    NEW_LINE   
          
ENDP
EXIT  

;prints hex number in AX
PRINT_HEX PROC NEAR 
;FIRST DIGIT
    MOV BH,AL 
    AND BH,0F0H                 ;isolate first digit's bits (35-->30)
    ROR BH,4                    ;rotate 4 times right (30-->3)
    
    CMP BH,9                    
    JG ADDR1
    ADD BH,30H                  ;if digit < 9 make ASCII by adding 30H (33H)
    JMP ADDR2
ADDR1:
    ADD BH,37H                  ;if digit > 9 make ASCII by adding 37H
ADDR2:
    PRINT BH                    ;print first digit (3: ASCII 33)
;SECOND DIGIT   
    MOV BH,AL                   
    AND BH,0FH                  ;isolate second digit's bits (35-->50)
    CMP BH,9
    JG ADDR3
    ADD BH,30H                  ;if digit < 9 make ASCII by adding 30H (35H)
    JMP ADDR4
ADDR3:
    ADD BH,37H                  ;if digit > 9 make ASCII by adding 37H
ADDR4:
    PRINT BH                    ;print second digit (5: ASCII 35)
    RET   
ENDP PRINT_HEX	

