section .data
rmodemsg db 10,"Processor is in Real Mode"
rmsg_len equ $-rmodemsg
pmodemsg db 10,"Processor is in Protected Mode"
pmsg_len equ $-pmodemsg
gdtmsg db 10,"GDT Contents are::"
gdtmsg_len equ $-gdtmsg
ldtmsg db 10,"LDT Contents are::"
ldtmsg_len equ $-ldtmsg
idtmsg db 10,"IDT Contents are::"
idtmsg_len equ $-idtmsg
trmsg db 10,"Task Register Contents are::"
trmsg_len equ $-trmsg
mswmsg db 10,"Machine Status Word::"
mswmsg_len equ $-mswmsg
colmsg db ":"
nwline db 10

section .bss
gdt resd 1
resw 1
ldt resw 1
idt resd 1
resw 1
tr resw 1
cr0_data resd 1
dispbuff resb 04

%macro display 2
mov rax,1      ;syscall number for sys_write
mov rdi,1      ;file descriptor (stdout/screen)
mov rsi,%1     ;msg
mov rdx,%2     ;msg_len
syscall        ;make syscall
%endmacro

section .text
global _start
_start:
    smsw eax         ;Store the MSW (bits 0 through 15 of control register CR0) into eax.
    mov [cr0_data], eax
    bt eax, 0        ;Checking PE (Protected Mode Enable) bit (LSB)
    ;If PE bit is 1, it's Protected Mode; if 0, it's Real Mode.
    jc prmode

    display rmodemsg, rmsg_len
    jmp nxt1

prmode:
    display pmodemsg, pmsg_len

nxt1:
    sgdt [gdt]       ; Store GDT (Global Descriptor Table) contents
    sldt [ldt]       ; Store LDT (Local Descriptor Table) contents
    sidt [idt]       ; Store IDT (Interrupt Descriptor Table) contents
    str [tr]         ; Store Task Register contents

    ; Display GDT Data
    display gdtmsg, gdtmsg_len
    mov bx, [gdt + 4]
    call display16_proc
    mov bx, [gdt + 2]
    call display16_proc
    display colmsg, 1
    mov bx, [gdt]
    call display16_proc

    ; Display LDT Data
    display ldtmsg, ldtmsg_len
    mov bx, [ldt]
    call display16_proc

    ; Display IDT Data
    display idtmsg, idtmsg_len
    mov bx, [idt + 4]
    call display16_proc
    mov bx, [idt + 2]
    call display16_proc
    display colmsg, 1
    mov bx, [idt]
    call display16_proc

    ; Display Task Register Data
    display trmsg, trmsg_len
    mov bx, [tr]
    call display16_proc

    ; Display Machine Status Word (MSW) Data
    display mswmsg, mswmsg_len
    mov bx, [cr0_data + 2]
    call display16_proc
    mov bx, [cr0_data]
    call display16_proc

    display nwline, 1
    mov rax, 60     ; Exit system call
    mov rdi, 0      ; Exit status 0
    syscall

;************************************************************
display16_proc:
    mov rdi, dispbuff       ; Point rdi to buffer
    mov rcx, 4              ; Load number of digits to display
dispup1:
    rol bx, 4              ; Rotate number left by 4 bits
    mov dl, bl             ; Move lower byte in dl
    and dl, 0fh            ; Mask upper digit of byte in dl
    add dl, 30h            ; Convert to ASCII
    cmp dl, 39h            ; Compare with 39h
    jbe dispskip1
    add dl, 07h            ; If greater, add 07h to adjust ASCII
dispskip1:
    mov [rdi], dl          ; Store ASCII code in buffer
    inc rdi                ; Point to next byte
    loop dispup1           ; Repeat for all digits
    display dispbuff, 4     ; Display the final result
    ret

