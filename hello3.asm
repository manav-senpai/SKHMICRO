%macro scall 4
mov eax,%1        ; Syscall number in eax
mov ebx,%2        ; First argument in ebx
mov ecx,%3        ; Second argument in ecx
mov edx,%4        ; Third argument in edx
int 0x80          ; Interrupt to make syscall
%endmacro

section .data
menu db 10d,13d," MENU"
db 10d,"1. Hex to BCD"
db 10d,"2. BCD to Hex"
db 10d,"3. Exit"
db 10d,"Enter your choice: "
menulen equ $-menu
m1 db 10d,13d,"Enter Hex Number: "
l1 equ $-m1
m2 db 10d,13d,"Enter BCD Number: "
l2 equ $-m2
m3 db 10d,13d,"Equivalent BCD Number: "
l3 equ $-m3
m4 db 10d,13d,"Equivalent Hex Number: "
l4 equ $-m4

section .bss
choice resb 1
num resb 16
answer resb 16
factor resb 16

section .text
global _start
_start:
    scall 4,1,menu,menulen
    scall 3,0,choice,2
    cmp byte [choice],'3'
    jae exit
    cmp byte [choice],'1'
    je hex2bcd
    cmp byte [choice],'2'
    je bcd2hex

;**********Hex to BCD Conversion*************************
hex2bcd:
    scall 4,1,m1,l1
    scall 3,0,num,17
    call asciihextohex
    mov eax,ebx
    mov ebx,10
    mov edi,num+15
loop3:
    mov edx,0
    div ebx
    add dl,30h
    mov [edi],dl
    dec edi
    cmp eax,0
    jne loop3
    scall 4,1,m3,l3
    scall 4,1,num,16
    jmp _start

;**********BCD to Hex Conversion*************************
bcd2hex:
    scall 4,1,m2,l2
    scall 3,0,num,17
    mov ecx,16
    mov esi,num+15
    mov ebx,0
    mov dword [factor],1
loop4:
    mov eax,0
    mov al,[esi]
    sub al,30h
    mul dword [factor]
    add ebx,eax
    mov eax,10
    mul dword [factor]
    mov dword [factor],eax
    dec esi
    loop loop4
    scall 4,1,m4,l4
    mov eax,ebx
    call display
    jmp _start

exit:
    mov eax,1          ; Exit syscall number for 32-bit
    mov ebx,0          ; Exit code 0
    int 0x80           ; Make syscall

;*********************PROCEDURES*************************
asciihextohex:
    mov esi,num
    mov ecx,16
    mov ebx,0
    mov eax,0
loop1:
    rol ebx,04
    mov al,[esi]
    cmp al,39h
    jbe skip1
    sub al,07h
skip1:
    sub al,30h
    add ebx,eax
    inc esi
    dec ecx
    jnz loop1
    ret

display:
    mov esi,answer+15
    mov ecx,16
loop2:
    mov edx,0
    mov ebx,16
    div ebx
    cmp dl,09h
    jbe skip2
    add dl,07h
skip2:
    add dl,30h
    mov [esi],dl
    dec esi
    dec ecx
    jnz loop2
    scall 4,1,answer,16
    ret

