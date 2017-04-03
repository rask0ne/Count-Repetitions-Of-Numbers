MAX_NUM_SIZE_STRING equ 6 
MAX_NUMBER_INT equ 32767
BASE equ 10 
ARRAY_SIZE equ 10


.model small
.stack 100h
.data           

inputNumbersString db "Enter numbers ",10,13,'$' 
endline db 10,13,'$'
numberERROR db "ERROR: enter number!",10,13,'$'
overflowERROR db "ERROR: overflow!",10,13,'$' 

count dw 0   
flag dw 0
array dw ARRAY_SIZE dup(?)
number db 0
resultString db ARRAY_SIZE dup(0)
             db ARRAY_SIZE dup(0)
           
                 
              
resultArray dw ARRAY_SIZE dup(0)
            dw ARRAY_SIZE dup(0)
                    
                 
stringOccurs db " occurs $" 
stringTimes db " time(s) $"
num dw 0

.code
print MACRO outputString
    mov ah, 09h  
    lea dx, outputString
    int 21h     
endm   

scan MACRO inputString 
    mov inputString [0], MAX_NUM_SIZE_STRING 
    lea dx, inputString 
    mov ah, 0Ah
    int 21h
    
    push bx
    xor bx, bx 
    mov bl, inputString [1]
    add bl, 2
    mov inputString [bx], '$'  
    pop bx 
endm 

start:
    mov ax, @data
    mov ds,ax
    
     
print [inputNumbersString]                   
                
    mov cx,ARRAY_SIZE
    xor si,si
           
INPUT_NUMS:    
    scan [number]
    print [endline]
    mov number,0    
    lea bx, array[si]
    lea di, number
    call STRING_TO_INT   
    add si, 2
loop INPUT_NUMS

    print [endline]  
    mov cx,count 
   
    xor si,si   
    
PRINT_RESULT:
    mov si,cx
    add si,cx
    sub si,2
    lea bx, resultArray[si]
    lea di, resultString
    call INT_TO_STRING
    print [resultString]
    print [stringOccurs]
  
    add si,ARRAY_SIZE
    add si,ARRAY_SIZE
    lea bx, resultArray[si]
    lea di, resultString
    call INT_TO_STRING
    print [resultString]
    print [stringTimes]
    print [endline]   
loop PRINT_RESULT 


EXIT:      
    mov ah, 4ch
    int 21h


STRING_TO_INT PROC
    push cx  
    push bx 
    xor ax, ax
    xor bx, bx
    xor cx, cx 
    
    mov bx, di
    add bx, 2
    cmp [bx], '-'
    jne MINUS_CHECK
    mov flag, 1
    inc bx
    
MINUS_CHECK:
    cmp [bx], '$'
    je MINUS    
    cmp [bx], '0'
    jl SHOW_SYMBOLS_ERROR 
    cmp [bx], '9'
    jg SHOW_SYMBOLS_ERROR
    inc bx
    jmp MINUS_CHECK

MINUS: 
   
    mov cl, 1[di] 
    sub cx, flag
    add di, 2
    add di, flag
    mov bl, BASE
    xor dx, dx   
     
    push si 
    
STRING_TO_INT_LOOP:
    mul bx
    jo SHOW_OVERFLOW_ERROR 
    mov dl, [di]
    sub dl, 30h
    add ax, dx  
    inc di
    cmp ax, MAX_NUMBER_INT
    ja SHOW_OVERFLOW_ERROR
    loop STRING_TO_INT_LOOP

    cmp flag, 0
    je SAVE_RESULT_TO_ARRAY
    not ax
    inc ax
    
SAVE_RESULT_TO_ARRAY:
    pop si    
    pop bx
    pop cx
    mov [bx], ax 
    mov flag, 0
    call WRITE_TO_ARRAY
    ret
    
SHOW_SYMBOLS_ERROR: 
    pop bx    
    pop cx
    mov flag, 0
    print [numberERROR]
    jmp exit
      
SHOW_OVERFLOW_ERROR: 
    pop bx
    pop cx         
    mov flag, 0
    print [overflowERROR]
    jmp EXIT   
STRING_TO_INT endp
  
WRITE_TO_ARRAY PROC
    push ax
    push cx
    
    xor si,si
    mov cx,count
    cmp cx,0
    jne ARRAY_LOOP  
    inc cx
ARRAY_LOOP:
    mov si,cx
    add si,cx
    sub si,2    
    cmp ax,resultArray[si]
    je WRITE_NUMBER
loop ARRAY_LOOP

    mov si,count
    add si,count
    mov resultArray[si],ax
    add si,ARRAY_SIZE
    add si,ARRAY_SIZE
    inc resultArray[si]
    inc count
    pop cx
    pop ax
    ret
        
WRITE_NUMBER:
    add si,ARRAY_SIZE
    add si,ARRAY_SIZE
    inc resultArray[si]
    pop cx
    pop ax
    ret

WRITE_TO_ARRAY endp
            
INT_TO_STRING PROC  
    push cx
    mov ax, [bx]
    mov bx, 10
    xor cx, cx 
    
    cmp ax, MAX_NUMBER_INT
    jbe DIVIDE
    dec ax
    not ax
    mov [di], '-'
    inc di
    
DIVIDE:
    xor dx, dx
    div bx       
    push dx
    inc cx
    cmp ax, 0
    jne DIVIDE

SAVE_STRING:
    pop dx
    add dl, 30h
    mov [di], dl
    inc di
    loop SAVE_STRING
    
    mov [di], '$'    
    pop cx
    ret
INT_TO_STRING endp                    

end start