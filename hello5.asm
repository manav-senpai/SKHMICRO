section .data
sourceBlock db 12h, 45h, 87h, 24h, 97h
count equ 05
msg db "ALP for non-overlapped block transfer using string instructions: ", 10
msg_len equ $ - msg
msgSource db 10, "The source block contains the elements: ", 10
msgSource_len equ $ - msgSource
msgDest db 10, 10, "The destination block contains the elements: ", 10
msgDest_len equ $ - msgDest
bef db 10, "Before Block Transfer: ", 10
beflen equ $ - bef
aft db 10, 10, "After Block Transfer: ", 10
aftlen equ $ - aft

section .bss
destBlock resb 5
result resb 4

%macro write 2
    mov rax, 1        ; sys_write system call
    mov rdi, 1        ; File descriptor 1 (stdout)
    mov rsi, %1       ; Message to print
    mov rdx, %2       ; Message length
    syscall           ; Make system call
%endmacro

section .text
global _start

_start:
    write msg, msg_len
    write bef, beflen
    write msgSource, msgSource_len
    mov rsi, sourceBlock
    call dispBlock

    write msgDest, msgDest_len
    mov rsi, destBlock
    call dispBlock

    ; Perform the block transfer (move sourceBlock to destBlock)
    mov rsi, sourceBlock
    mov rdi, destBlock
    mov rcx, count
    cld
    rep movsb

    write aft, aftlen
    write msgSource, msgSource_len
    mov rsi, sourceBlock
    call dispBlock

    write msgDest, msgDest_len
    mov rsi, destBlock
    call dispBlock

    ; Exit the program
    mov rax, 60       ; Exit system call
    mov rdi, 0        ; Exit status 0
    syscall

;--------------------------------------------------------------
; Function to display a block of data
dispBlock:
    mov rbp, count    ; Load count (5) into rbp
next:
    mov al, [rsi]     ; Move byte from source into al
    push rsi          ; Save rsi before calling disp
    call disp         ; Call disp to convert the number to ASCII
    pop rsi           ; Restore rsi after disp
    inc rsi           ; Move to the next byte in sourceBlock
    dec rbp           ; Decrement count
    jnz next          ; Loop until count reaches 0
    ret

;--------------------------------------------------------------
; Function to convert the byte into ASCII and print it
disp:
    mov bl, al        ; Store the byte in bl
    mov rdi, result   ; Point rdi to the result buffer
    mov cx, 02        ; Set the number of rotations (2 hex digits)
up1:
    rol bl, 04        ; Rotate the number left by 4 bits
    mov al, bl        ; Move the rotated byte to al
    and al, 0fh       ; Mask out the upper nibble
    cmp al, 09h       ; Check if it's less than 10 (0-9)
    jg add_37         ; If greater than 9, add 37 to get 'A' to 'F'
    add al, 30h       ; Convert to ASCII '0'-'9'
    jmp skip1
add_37:
    add al, 37h       ; Convert to ASCII 'A'-'F'
skip1:
    mov [rdi], al     ; Store the ASCII character in result
    inc rdi           ; Move to the next byte in result
    dec cx            ; Decrement the count of digits to display
    jnz up1           ; Repeat for the second hex digit
    write result, 4   ; Write the result buffer to stdout
    ret

