section .data
    msg6 db "No of occurrence of character", 0xA
    len6 equ $ - msg6
    msg db "No of spaces are", 0xA
    len db $ - msg
    msg1 db "No of enters are", 0xA
    len1 equ $ - msg1
    new db "", 0xA
    new_len equ $ - new
    buffer db "Hello world! How are you?", 0  ; Test string to count spaces, newlines, and character occurrences
    scount db 0
    ncount db 0
    chacount db 0

section .bss
    cnt resb 2
    cnt2 resb 2
    cnt3 resb 2
    cha resb 2

%macro scall 4
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    syscall
%endmacro

section .text
    global _start
    _start:
        ; Count spaces
        mov rsi, buffer
        mov byte [cnt], 0
    count_spaces:
        mov al, byte [rsi]
        cmp al, 0
        je done_spaces
        cmp al, 20h
        jne next_char
        inc byte [scount]
    next_char:
        inc rsi
        jmp count_spaces
    done_spaces:
        add byte [scount], 30h
        scall 1, 1, scount, 2
        scall 1, 1, new, new_len

        ; Count newlines (enters)
        mov rsi, buffer
        mov byte [cnt2], 0
    count_newlines:
        mov al, byte [rsi]
        cmp al, 0
        je done_newlines
        cmp al, 0Dh
        jne next_char2
        inc byte [ncount]
    next_char2:
        inc rsi
        jmp count_newlines
    done_newlines:
        add byte [ncount], 30h
        scall 1, 1, ncount, 2
        scall 1, 1, new, new_len

        ; Count occurrences of character (e.g., 'o')
        mov bl, 'o'  ; Character to search for
        mov rsi, buffer
        mov byte [cnt3], 0
    count_occurrences:
        mov al, byte [rsi]
        cmp al, 0
        je done_occurrences
        cmp al, bl
        jne next_char3
        inc byte [chacount]
    next_char3:
        inc rsi
        jmp count_occurrences
    done_occurrences:
        add byte [chacount], 30h
        scall 1, 1, msg6, len6
        scall 1, 1, chacount, 1
        scall 1, 1, new, new_len

        ; Exit program
        mov rax, 60
        xor rdi, rdi
        syscall

