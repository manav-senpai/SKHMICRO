%macro scall 4
    mov eax, %1
    mov ebx, %2
    mov ecx, %3
    mov edx, %4
    int 80h
%endmacro

section .data
    arr dd -18888888h, 18888888h, 22222222h, 11111111h, -33333333h
    n equ 5
    pmsg db 10d, 13d, "The Count of Positive No: ", 10d, 13d
    plen equ $-pmsg
    nmsg db 10d, 13d, "The Count of Negative No: ", 10d, 13d
    nlen equ $-nmsg
    nwline db 10d, 13d

section .bss
    pcnt resq 1
    ncnt resq 1
    char5_answer resb 8

section .text
    global _start
_start:
    mov esi, arr
    mov edi, n
    mov ebx, 0
    mov ecx, 0

up:
    mov eax, [esi]
    cmp eax, 00000000h
    js negative

positive:
    inc ebx
    jmp next

negative:
    inc ecx

next:
    add esi, 4
    dec edi
    jnz up

    mov [pcnt], ebx
    mov [ncnt], ecx

    scall 4, 1, pmsg, plen
    mov eax, [pcnt]
    call display

    scall 4, 1, nmsg, nlen
    mov eax, [ncnt]
    call display

    scall 4, 1, nwline, 1

    mov eax, 1
    xor ebx, ebx
    int 80h

display:
    mov esi, char5_answer + 7
    mov ecx, 8
    mov ebx, 10
cnt:
    xor edx, edx
    div ebx
    add dl, 30h
    mov [esi], dl
    dec esi
    dec ecx
    jnz cnt

    scall 4, 1, char5_answer + 1, 8
    ret

