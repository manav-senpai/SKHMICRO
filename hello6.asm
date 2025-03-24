section .data
msg0 db 10, "1.nonoverlap with string", 10
     db "2.nonoverlap without string", 10
     db "3.overlap with string", 10
     db "4.overlap without string", 10
     db "5.exit", 10
     db "Enter your choice ->", 10
len0 equ $ - msg0

msg1 db 10, "Source block contents are ", 10
len1 equ $ - msg1

msg2 db 10, "Destination block contents are ", 10
len2 equ $ - msg2

array db 01h, 02h, 03h, 04h, 05h, 00h, 00h, 00h, 00h, 00h
array2 times 5 db 0
space db 20h
cnt equ 5

section .bss
dispbuff resb 4
var resb 1

%macro display 2
    mov eax, 4        ; sys_write system call
    mov ebx, 1        ; File descriptor 1 (stdout)
    mov ecx, %1       ; Message to print
    mov edx, %2       ; Message length
    int 80h           ; Make system call
%endmacro

section .text
global _start

_start:
    display msg0, len0
    mov eax, 3        ; sys_read system call
    mov ebx, 0        ; File descriptor 0 (stdin)
    mov ecx, var      ; Pointer to var
    mov edx, 2        ; Read 2 bytes
    int 80h           ; Make system call
    cmp byte [var], '5'
    je exit

    display msg1, len1
    mov ecx, cnt
    mov esi, array
bk:
    push ecx
    mov bl, [esi]
    call display1_proc
    display space, 1
    inc esi
    pop ecx
    loop bk

    display msg2, len2
    cmp byte [var], '1'
    je case1
    cmp byte [var], '2'
    je case2
    cmp byte [var], '3'
    je case3
    cmp byte [var], '4'
    je case4

case1:
    mov esi, array
    mov edi, array2
    mov ecx, cnt
    cld
    rep movsb
    mov esi, array2
    mov ecx, 5
    jmp end

case2:
    mov esi, array
    mov edi, array2
    mov ecx, cnt
nover:
    mov bl, [esi]
    mov [edi], bl
    inc esi
    inc edi
    loop nover
    mov esi, array2
    mov ecx, 5
    jmp end

case3:
    mov esi, array + 5
    mov edi, array + 7
    mov ecx, cnt
    inc ecx
    std
    rep movsb
    mov esi, array
    mov ecx, 7
    jmp end

case4:
    mov esi, array + 5
    mov edi, array + 7
    mov ecx, cnt
    inc ecx
overl:
    mov bl, [esi]
    mov [edi], bl
    dec esi
    dec edi
    loop overl
    mov esi, array
    mov ecx, 7
    jmp end

end:
x1:
    push ecx
    mov bl, [esi]
    call display1_proc
    display space, 1
    inc esi
    pop ecx
    loop x1
    jmp _start

exit:
    mov eax, 1        ; sys_exit system call
    mov ebx, 0        ; Exit status 0
    int 80h           ; Make system call

display1_proc:
    mov ecx, 4        ; Number of bytes to convert
    mov edi, dispbuff ; Pointer to buffer
d1:
    rol bx, 4         ; Rotate left by 4 bits
    mov al, bl        ; Move lower byte into al
    and al, 0fh       ; Mask upper 4 bits
    cmp al, 09h       ; Compare to 9
    jbe dskip
    add al, 07h       ; If greater than 9, add 7 to get 'A'-'F'
dskip:
    add al, 30h       ; Convert to ASCII (0-9, A-F)
    mov [edi], al     ; Store in buffer
    inc edi           ; Move to next byte in buffer
    loop d1
    display dispbuff, 4 ; Display the buffer (hex)
    ret

