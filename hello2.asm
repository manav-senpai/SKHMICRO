section .data
m2 db 10,10, 'Enter the string: ' ; prompt message
m2_len equ $-m2 ; length of prompt message
m3 db 'Length of the string is: ' ; output message
m3_len equ $-m3 ; length of output message

section .bss
srcstr resb 20 ; reserve 20 bytes for input string
count resb 1 ; reserve a byte to store the string length
dispbuff resb 2 ; buffer to display a number

%macro disp 2  ; Macro for displaying messages
    mov eax, 4 ; 4 = sys_write
    mov ebx, 1 ; file descriptor: 1 = stdout
    mov ecx, %1 ; parameter: address of string
    mov edx, %2 ; parameter: length of string
    int 0x80 ; call kernel
%endmacro

%macro acceptstr 1 ; Macro to read a string
    mov eax, 3 ; 3 = sys_read
    mov ebx, 0 ; file descriptor: 0 = stdin
    mov ecx, %1 ; parameter: buffer to store input
    mov edx, 20 ; limit to 20 characters
    int 0x80 ; call kernel
%endmacro

section .text
global _start

_start:
    ; Display prompt message
    disp m2, m2_len
    ; Accept user input
    acceptstr srcstr

    ; Calculate string length
    mov al, [srcstr] ; load the first byte of input string
    dec al ; decrement al to correct the input
    mov [count], al ; store the length of the input string in 'count'

    ; Display "Length of the string is: "
    disp m3, m3_len

    ; Move the length into a register for display
    mov bl, [count] ; load the string length into bl

    ; Call the display function to print the length
    call display

    ; Exit the program
    mov eax, 1 ; 1 = sys_exit
    xor ebx, ebx ; return code 0
    int 0x80 ; call kernel to exit

display:
    ; Display length in decimal
    mov cl, 2 ; max number of digits
    mov edi, dispbuff ; address to store output string
d1:
    rol bl, 4 ; rotate left by 4 bits (divide by 16)
    mov al, bl ; copy to al
    and al, 0Fh ; mask to get the lower 4 bits
    cmp al, 09 ; check if value <= 9
    jbe d2
    add al, 07 ; adjust ASCII if value > 9
d2:
    add al, 30h ; convert to ASCII (0-9)
    mov [edi], al ; store the character
    inc edi ; move to next byte in buffer
    dec cl ; decrease character count
    jnz d1 ; repeat until all digits are processed

    ; Display the result string
    disp dispbuff, 2
    ret ; return to the caller


