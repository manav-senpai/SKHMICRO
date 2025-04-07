%macro scall 4
    ; Macro for read/write system call
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    syscall
%endmacro

; --------------- DATA SECTION -----------------------
section .data
    title: db "------ Factorial Program ------", 0x0A
           db "Enter Number: ", 0x0A
    title_len: equ $ - title
    factMsg: db "Factorial is: ", 0x0A
    factMsg_len: equ $ - factMsg
    cnt: db 00H
    cnt2: db 02H
    num_cnt: db 00H

; --------------- BSS SECTION -------------------------
section .bss
    number: resb 2
    factorial: resb 10  ; Make space for the result (up to 10 bytes)

; --------------- TEXT SECTION -------------------------
section .text
    global _start

_start:
    ; Display title message
    scall 1, 1, title, title_len
    
    ; Prompt user for input
    scall 1, 1, title + 18, 14  ; "Enter Number: "
    
    ; Read the input from user
    scall 0, 0, number, 2
    
    ; Convert the ASCII input to hexadecimal
    mov rsi, number
    call AtoH
    
    ; Store the converted value in num_cnt
    mov byte [num_cnt], bl
    dec byte [num_cnt] ; Decrement count for stack operations

    ; Initialize RAX register with the number to calculate factorial
    mov rax, 0
    mov al, bl

TOP:
    ; Push the value of RAX to stack
    push rax
    dec rax
    cmp rax, 1
    jnbe FACTLOOP
    
    ; Continue to top of loop
    jmp TOP

FACTLOOP:
    ; Pop value from stack to calculate factorial
    pop rbx
    mul bx
    dec byte [num_cnt]
    jnz FACTLOOP

    ; Store the result of factorial in BX
    mov bx, ax

    ; Convert the result from HEX to ASCII
    mov rdi, factorial
    call HtoA_value

    ; Print the message and the factorial
    scall 1, 1, factMsg, factMsg_len
    scall 1, 1, factorial, 10  ; Print 10 bytes (enough for the result)

    ; Exit the program
    mov rax, 60
    mov rdi, 0
    syscall

; ---------------------- ASCII to HEX Conversion ----------------------
AtoH:
    ; Convert ASCII to HEX (stored in BL)
    mov byte [cnt], 2
    mov bx, 0
hup:
    rol bl, 4
    mov al, byte [rsi]
    cmp al, 39H
    jbe HNEXT
    sub al, 7
HNEXT:
    sub al, 30H
    add bl, al
    inc rsi
    dec byte [cnt]
    jnz hup
    ret

; ---------------------- HEX to ASCII Conversion ----------------------
HtoA_value:
    ; Convert HEX value in EBX to ASCII
    mov byte [cnt2], 10   ; Up to 10 digits for the factorial result
aup1:
    rol ebx, 4
    mov cl, bl
    and cl, 0FH
    cmp cl, 9
    jbe ANEXT1
    add cl, 7
ANEXT1:
    add cl, 30H
    mov byte [rdi], cl
    inc rdi
    dec byte [cnt2]
    jnz aup1
    ret

