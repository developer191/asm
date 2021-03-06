FORMAT MZ

macro linear reg,trg,seg
	{
	xor reg,reg
	mov reg,seg
	shl reg,4
	add reg,trg
	}



SEGMENT T32 USE32

rt2:

retf


SEGMENT MAIN16 USE16
ORG 0h

m0 db "DMMI server not installed. Run entry.exe with /r",0xd,0xa," $"
m1 db "Hello from real mode thread",0xd,0xa,"$";
mut1 db 0

rt1:


sti
push cs
pop ds
mov dx,m1
mov ax,0x0900
int 0x21


; unlock mut
push cs
pop es
mov di,mut1
mov ax,0x0503
int 0xF0

retf



main:


mov ax,0x35F0
int 0x21
cmp bx,0
jnz .bp
mov bx,es
cmp bx,0
jnz .bp
jmp .f

.bp:
mov ax,0
int 0xF0
cmp ax,0xFACE
jz .y

.f:
push cs
pop ds
mov ax,0x0900
mov dx,m0
int 0x21

mov ax,0x4c00
int 0x21


.y:
; dl = num of cpus

; enter unreal
mov ax,0x0900
int 0xF0

; init mut
push cs
pop es
mov di,mut1
mov ax,0x0500
int 0xF0

; lock mut 
push cs
pop es
mov di,mut1
mov ax,0x0502
int 0xF0

; lock mut 
push cs
pop es
mov di,mut1
mov ax,0x0502
int 0xF0

; run a thread
push cs
pop es
mov dx,rt1
mov ax,0x0100
mov ebx,1
int 0xF0

; run a thread
push cs
pop es
mov dx,rt1
mov ax,0x0100
mov ebx,2
int 0xF0

; run a p thread
push cs
pop es
mov ax,0x0101
mov ebx,3
linear edx,rt2,T32
int 0xF0

; wait mut
push cs
pop es
mov di,mut1
mov ax,0x0504
int 0xF0

mov ax,0x4c00
int 0x21

entry MAIN16:main