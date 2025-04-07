section .data
    global msg6, len6, scount, ncount, chacount, new, new_len
    fname: db 'abc.txt', 0
    msg: db "file opened successfully", 0x0A
    len: equ $ - msg
    msg1: db "file closed successfully", 0x0A
    len1: equ $ - msg1
    msg2: db "error in opening file", 0x0A
    len2: equ $ - msg2
    msg3: db "No of spaces are", 0x0A
    len3: equ $ - msg3
    msg4: db "No of enters are", 0x0A
    len4: equ $ - msg4
    msg5: db "enter the character", 0x0A
    len5: equ $ - msg5
    msg6: db "No of occurrence of character", 0x0A
    len6: equ $ - msg6
    new: db "", 0x0A
    new_len: equ $ - new
    scount: db 0
    ncount: db 0
    ccount: db 0
    chacount: db 0

section .bss
    global cnt, cnt2, cnt3, buffer
    fd: resq 1
    buffer: resb 200
    buf_len: resq 1
    cnt: resq 1
    cnt2: resq 1
    cnt3: resq 1
    cha: resb 2

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
    extern spaces, enters, occ

    mov rax, 2
    mov rdi, fname
    mov rsi, 0
    mov rdx, 0
    syscall
    mov [fd], rax

    test rax, rax
    js error_opening_file

    scall 1, 1, msg, len
    jmp next2

error_opening_file:
    scall 1, 1, msg2, len2
    jmp exit

next2:
    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 200
    mov rax, 0
    syscall
    mov [buf_len], rax

    mov [cnt], rax
    mov [cnt2], rax
    mov [cnt3], rax

    scall 1, 1, msg3, len3
    call spaces

    scall 1, 1, msg4, len4
    call enters

    scall 1, 1, msg5, len5
    scall 0, 1, cha, 2

    mov bl, byte [cha]
    call occ

    jmp exit

spaces:
    mov rbx, 0
    mov rcx, [cnt]
    mov rsi, buffer

count_spaces:
    test rcx, rcx
    jz done_spaces
    mov al, [rsi]
    cmp al, ' '
    jz increment_space_count
    inc rsi
    dec rcx
    jmp count_spaces

increment_space_count:
    inc rbx
    inc rsi
    dec rcx
    jmp count_spaces

done_spaces:
    mov byte [scount], rbx
    scall 1, 1, scount, 1
    ret

enters:
    mov rbx, 0
    mov rcx, [cnt2]
    mov rsi, buffer

count_enters:
    test rcx, rcx
    jz done_enters
    mov al, [rsi]
    cmp al, 0x0A
    jz increment_enter_count
    inc rsi
    dec rcx
    jmp count_enters

increment_enter_count:
    inc rbx
    inc rsi
    dec rcx
    jmp count_enters

done_enters:
    mov byte [ncount], rbx
    scall 1, 1, ncount, 1
    ret

occ:
    mov rbx, 0
    mov rcx, [cnt3]
    mov rsi, buffer

count_occurrences:
    test rcx, rcx
    jz done_occurrences
    mov al, [rsi]
    cmp al, bl
    jz increment_char_count
    inc rsi
    dec rcx
    jmp count_occurrences

increment_char_count:
    inc rbx
    inc rsi
    dec rcx
    jmp count_occurrences

done_occurrences:
    mov byte [chacount], rbx
    scall 1, 1, msg6, len6
    scall 1, 1, chacount, 1
    ret

exit:
    mov rax, 60
    mov rdi, 0
    syscall

