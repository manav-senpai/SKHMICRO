section .data
fname1: db 'abc.txt',0
fname2: db 'def.txt',0
fname3: db 'efg.txt',0
menu: db "------ MENU ------",0x0A
db "1.TYPE",0x0A
db "2.COPY",0x0A
db "3.DELETE",0x0A
db "4.Exit",0x0A
menulen: equ $-menu
choice: db "Enter Your Choice",0x0A
ch_len: equ $-choice
msg: db "file1 opened successfully",0x0A
len: equ $-msg
msg1: db "file1 closed successfully",0x0A
len1: equ $-msg1
msg2: db "error in opening file",0x0A
len2: equ $-msg2
msg3: db "Content copied in destination file",0x0A
len3: equ $-msg3
msg4: db "file2 opened successfully",0x0A
len4: equ $-msg4
msg5: db "file2 closed successfully",0x0A
len5: equ $-msg5
msg6: db "file3 deleted successfully",0x0A
len6: equ $-msg6
new: db "",0x0A
new_len: equ $-new

section .bss
cho: resb 2
fd1: resb 17
fd2: resb 17
buffer1: resb 200
buffer2: resb 200
buf_len1: resb 17
buf_len2: resb 17

%macro scall 4
mov rax,%1
mov rdi,%2
mov rsi,%3
mov rdx,%4
syscall
%endmacro

section .text
global _start
_start:
scall 1,1,menu,menulen
scall 1,1,choice,ch_len
scall 0,1,cho,2
cmp byte[cho],31h
je case1
cmp byte[cho],32h
je case2
cmp byte[cho],33h
je case3
cmp byte[cho],34h
je case4
jmp _start

case1:
call type
jmp _start

case2:
call copy
jmp _start

case3:
call delete
jmp _start

case4:
jmp exit

type:
mov rax,2
mov rdi,fname1
mov rsi,2
mov rdx,0777
syscall
mov qword[fd1],rax
BT rax,63
jc next
scall 1,1,msg,len
jmp next2
next:
scall 1,1,msg2,len2
next2:
scall 0,[fd1],buffer1,200
mov qword[buf_len1],rax
dec qword[buf_len1]
scall 1,1,buffer1,200
mov rax,3
mov rdi,[fd1]
syscall
scall 1,1,msg1,len1
ret

copy:
mov rax,2
mov rdi,fname1
mov rsi,2
mov rdx,0777
syscall
mov qword[fd1],rax
BT rax,63
jc next3
scall 1,1,msg,len
jmp next4
next3:
scall 1,1,msg2,len2
next4:
scall 0,[fd1],buffer1,200
mov qword[buf_len1],rax
dec qword[buf_len1]
mov rax,2
mov rdi,fname2
mov rsi,2
mov rdx,0777
syscall
mov qword[fd2],rax
BT rax,63
jc next5
scall 1,1,msg4,len4
jmp next6
next5:
scall 1,1,msg,len
next6:
scall 1,[fd2],buffer1,200
scall 1,1,msg3,len3
mov rax,3
mov rdi,[fd1]
syscall
scall 1,1,msg1,len1
mov rax,3
mov rdi,[fd2]
syscall
scall 1,1,msg5,len5
ret

delete:
mov rax,87
mov rdi,fname3
syscall
scall 1,1,msg6,len6
ret

exit:
mov rax,60
mov rdi,0
syscall

