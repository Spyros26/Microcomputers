;This program waits from the user 20 character from the keyboard and then prints
;them, as following:
;	prints 0 ... 9 as they are
;	prints a to z in uppercases 
;	avoids all other characters.
;eg input: jhgf.!111
;  output: JHGF111	

;This program is the fourth exercise of the fifth set from 2019.

INCLUDE MACROS.ASM
    .8086
    .MODEL SMALL
    .STACK 256    
;------DATA SEGMENT------------
.DATA
    TABLE DB 16 DUP(?)

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
     MOV DI,0  
     MOV CX,0 
LOOP_READ:   
     READ_WITHOUT_PRINT        
     CMP AL,13                  ;if ENTER quit
     JE QUIT                    
     CMP AL,'0'                 ;accept if 0 - 9 or A - Z
     JL LOOP_READ
     CMP AL,'9'
     JNA ACCEPTED
     CMP AL,'A'
     JL LOOP_READ
     CMP AL,'Z' 
     JG LOOP_READ
ACCEPTED:     
     MOV [TABLE + DI],AL 
     PRINT AL
     INC DI
     INC CL
     CMP CL,16                  ;if 16 characters are given start printing
     JZ CONVERT
     JMP LOOP_READ    
      
CONVERT: 
     NEW_LINE
     MOV DI,0
PRINT_NUM:                      ;print the numbers
     MOV AL,[TABLE + DI]  
        
     CMP AL,'0'                 
     JL NEXT                     
     CMP AL,'9'                
     JG NEXT
                               
     PRINT AL
     JMP NEXT 
     
PRINT_CHAR:                     ;print the letters 
     PRINT 45                   ;print -
     MOV DI,0                   ;update DI and counter to 0
     MOV CH,0 
PRINT_CHAR_LOOP:
     MOV AL,[TABLE + DI]
     CMP AL,'A'                
     JL NEXT2                   
     CMP AL,'Z'                
     JG NEXT2
     ADD AL,32                  ;make it lower-case   
     PRINT AL 
     JMP NEXT2
     
NEXT:          
     INC DI 
     INC CH   
     CMP CH,CL
     JG PRINT_CHAR              ;when done with numbers go to letters  
     
     JMP PRINT_NUM
     
     
NEXT2:          
     INC DI 
     INC CH   
     CMP CH,CL
     JG START  
     
     JMP PRINT_CHAR_LOOP       
     
    
           
     JMP START
QUIT:
    EXIT     
MAIN ENDP
