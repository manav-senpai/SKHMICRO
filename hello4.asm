%macro display 2
    mov eax, 4            ; syscall number for sys_write in 32-bit mode
    mov ebx, 1            ; file descriptor 1 (stdout)
    mov ecx, %1           ; pointer to message
    mov edx, %2           ; message length
    int 0x80              ; invoke syscall
%endmacro

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
gdt resd 1      ; 4 bytes for the GDT
ldt resw 1      ; 2 bytes for the LDT
idt resd 1      ; 4 bytes for the IDT
tr resw 1       ; 2 bytes for Task Register
cr0_data resd 1 ; 4 bytes for Control Register 0
dispbuff resb 04 ; 4 bytes buffer for display

section .text
global _start

_start:
    smsw eax              ; Store the MSW (bits 0-15 of control register CR0) into eax
    mov [cr0_data], eax   ; Save it in memory
    bt eax, 0             ; Check the PE (Protected Mode Enable) bit (LSB)
    jc prmode             ; If PE = 1, jump to prmode

    ; Real mode
    display rmodemsg, rmsg_len
    jmp nxt1

prmode:
    display pmodemsg, pmsg_len

nxt1:
    ; sgdt, sldt, sidt, str are used to load the system descriptors and registers.
    ; They require memory addresses. Use resd (4 bytes) for the GDT, IDT, etc.
    
    sgdt [gdt]            ; Store GDT in memory
    sldt [ldt]            ; Store LDT in memory
    sidt [idt]            ; Store IDT in memory
    str [tr]              ; Store Task Register in memory

    ; Display GDT contents
    display gdtmsg, gdtmsg_len
    mov eax, [gdt+4]      ; Use eax to read 32-bit data from GDT
    call display16_proc
    mov eax, [gdt+2]      ; Use eax to read 32-bit data from GDT
    call display16_proc
    display colmsg, 1
    mov eax, [gdt]        ; Use eax to read 32-bit data from GDT
    call display16_proc

    ; Display LDT contents
    display ldtmsg, ldtmsg_len
    mov ax, [ldt]         ; Use ax for 16-bit data from LDT
    call display16_proc

    ; Display IDT contents
    display idtmsg, idtmsg_len
    mov eax, [idt+4]      ; Use eax to read 32-bit data from IDT
    call display16_proc
    mov eax, [idt+2]      ; Use eax to read 32-bit data from IDT
    call display16_proc
    display colmsg, 1
    mov eax, [idt]        ; Use eax to read 32-bit data from IDT
    call display16_proc

    ; Display Task Register contents
    display trmsg, trmsg_len
    mov ax, [tr]          ; Use ax for 16-bit data from Task Register
    call display16_proc

    ; Display Machine Status Word data
    display mswmsg, mswmsg_len
    mov ax, [cr0_data+2]  ; Use ax to read 16-bit data from MSW
    call display16_proc
    mov eax, [cr0_data]   ; Use eax to read 32-bit data from MSW
    call display16_proc
    display nwline, 1

    ; Exit the program
    mov eax, 1            ; syscall number for exit
    mov ebx, 0            ; exit code 0
    int 0x80              ; invoke syscall

; Display procedure for 16-bit values
display16_proc:
    mov rdi, dispbuff     ; Point rdi to the buffer
    mov rcx, 4            ; Load number of digits to display (4 hex digits)
dispup1:
    rol eax, 4            ; Rotate eax left by 4 bits
    mov dl, al            ; Move lower byte into dl
    and dl, 0fh           ; Mask upper nibble
    add dl, 30h           ; Convert to ASCII
    cmp dl, 39h           ; If it's <= 9, continue
    jbe dispskip1
    add dl, 7             ; If it's > 9, adjust for hex letters
dispskip1:
    mov [rdi], dl         ; Store ASCII character in buffer
    inc rdi               ; Move to next byte
    loop dispup1          ; Repeat for all 4 digits
    display dispbuff, 4    ; Display the buffer contents
    ret

