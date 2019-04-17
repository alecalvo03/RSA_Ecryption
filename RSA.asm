%include "io64.inc"

section	.data
    bignum1 dq 4,0,0,0;0xFFFFFFFFFFAFFFFF, 0xFFFFFBFFFFFFFFFF, 0, 0
    bignum2 dq 6,3,0,0;0xFFFFFFFFFFFFFFCF, 0xFFFDFFFFFFFFFFFF, 0, 0
    mul1    dq 0, 0
    mul2    dq 0, 0
    mul3    dq 0, 0
    mul4    dq 0, 0

    divD    dq 0, 0, 0, 0
    divN    dq 0, 0, 0, 0
    divQ    dq 0, 0, 0, 0
    divR    dq 0, 0, 0, 0
    divM    dq 0
    divA    dq 0, 0, 0, 0
    
    

section .text
	global main

main:
    mov rbp, rsp; for correct debugging

    call bigdiv
    
    mov rax, qword[bignum2]
    mov rbx, qword[bignum2+8]
    mov rcx, qword[bignum2+16]
    mov rdx, qword[bignum2+24]

bigadd:                                 ;bignum2 = bignum2 + bignum1
    mov rax, qword [bignum1]
    add qword [bignum2], rax
    mov rax, qword [bignum1+8]
    adc qword [bignum2+8], rax
    mov rax, qword [bignum1+16]
    adc qword [bignum2+16], rax
    mov rax, qword [bignum1+24]
    adc qword [bignum2+24], rax
    ret

bigsub:                                 ;bignum2 = bignum2 - bignum1
    mov rax, qword [bignum1]
    sub qword [bignum2], rax
    mov rax, qword [bignum1+8]
    sbb qword [bignum2+8], rax
    mov rax, qword [bignum1+16]
    sbb qword [bignum2+16], rax
    mov rax, qword [bignum1+24]
    sbb qword [bignum2+24], rax
    ret

bigmul:                                  ;bignum2 = bignum2 * bignum1

    mov rax, qword [bignum1]		; move bignum1[0] to rax
    mul qword [bignum2]				; rdx:rax = bignum1[0]*bignum2[0]
    mov qword [mul1], rax			; move rax to mul1[0]
    mov qword [mul1+8], rdx			; move rdx to mul1[1]
    mov rax, qword [bignum1]		; move bignum1[0] to rax
    mul qword [bignum2+8]			; rdx:rax = bignum1[0]*bignum2[1]
    mov qword [mul2], rax			; move rax to mul2[0]
    mov qword [mul2+8], rdx			; move rdx to mul2[1]
    mov rax, qword [bignum1+8]		; move bignum1[1] to rax
    mul qword [bignum2]				; rdx:rax = bignum1[1]*bignum2[0]
    mov qword [mul3], rax			; move rax to mul3[0]
    mov qword [mul3+8], rdx			; move rdx to mul3[1]
    mov rax, qword [bignum1+8]		; move bignum1[1] to rax
    mul qword [bignum2+8]			; rdx:rax = bignum1[1]*bignum2[1]
    mov qword [mul4], rax			; move rax to mul4[0]
    mov qword [mul4+8], rdx			; move rdx to mul4[1]
	;mov rax, qword[mul1]			; move mul1[0] to rax
	;mov qword[bignum2], rax			; move rax to bignum2[0]

    mov rax, qword[mul1+8]
    mov qword[bignum1],rax
    mov qword[bignum1+8], 0
    mov rax, qword[mul2]
    mov qword[bignum2], rax
    mov qword[bignum2+8], 0
    call bigadd
    mov rax, qword[mul3]
    mov qword[bignum1], rax
    call bigadd

    mov rdx, qword[bignum2]
    mov qword[mul2], rdx
    mov rdx, qword[bignum2+8]

    mov rax, qword[mul2+8]
    mov qword[bignum1],rax
    mov qword[bignum1+8], 0
    mov rax, qword[mul3+8]
    mov qword[bignum2], rax
    mov qword[bignum2+8], 0
    call bigadd
    mov rax, qword[mul4]
    mov qword[bignum1], rax
    mov qword[bignum1+8], 0
    call bigadd
    mov qword[bignum1], rdx			; add remainder
    mov qword[bignum1+8], 0
    call bigadd

    mov rdx, qword[bignum2]
    mov qword[mul3], rdx
    mov rdx, qword[bignum2+8]

    mov rax, qword[mul4+8]
    add rax, rdx

    mov qword[bignum2+24], rax
    mov rax, qword[mul3]
    mov qword[bignum2+16], rax
    mov rax, qword[mul2]
    mov qword[bignum2+8], rax
    mov rax, qword[mul1]
    mov qword[bignum2], rax

    ret
    
bigmul2:
    
    

getmagnitude:
    mov rax, 24
    mov rbx, qword[divD+rax]
    cmp qword[divD+rax], 0
    jne donemagnitude
    mov rax, 16
    cmp qword[divD+rax], 0
    jne donemagnitude
    mov rax, 8
    cmp qword[divD+rax], 0
    jne donemagnitude
    mov rax, 0
donemagnitude:
    mov qword[divM], rax
    ret
    

;;Progress
bigdiv:                                         ;bignum2 = bignum2 / bignum1
    mov rax, qword[bignum1]
    mov qword[divD], rax
    mov rax, qword[bignum1+8]
    mov qword[divD+8], rax
    mov rax, qword[bignum1+16]
    mov qword[divD+16], rax
    mov rax, qword[bignum1+24]
    mov qword[divD+24], rax
    
    mov rax, qword[bignum2]
    mov qword[divN], rax
    mov rax, qword[bignum2+8]
    mov qword[divN+8], rax
    mov rax, qword[bignum2+16]
    mov qword[divN+16], rax
    mov rax, qword[bignum2+24]
    mov qword[divN+24], rax
    
    mov qword[divA], 0
    mov qword[divA+8], 0
    mov qword[divA+16], 0
    mov qword[divA+24], 0
    
    mov qword[divR], 0
    mov qword[divR+8], 0
    mov qword[divR+16], 0
    mov qword[divR+24], 0
    
    mov qword[divQ], 0
    mov qword[divQ+8], 0
    mov qword[divQ+16], 0
    mov qword[divQ+24], 0
    
    call getmagnitude

    mov rcx, qword[divM]
    
    ;Divs each digit and concatenates modulus on rdx
    xor rdx, rdx
    mov rax, qword[divN+24]
    div qword[divD+rcx]
    mov qword[divQ+24], rax
    cmp rcx, 24
    jz divdone
    
    mov rax, qword[divN+16]
    div qword[divD+rcx]
    mov qword[divQ+16], rax
    cmp rcx, 16
    jz divdone
    
    mov rax, qword[divN+8]
    div qword[divD+rcx]
    mov qword[divQ+8], rax
    cmp rcx, 8
    jz divdone
    
    mov rax, qword[divN]
    div qword[divA+rcx]
    mov qword[divQ], rax
    
    ;stores divD in bignum2
    mov rax, qword[divD]
    mov qword[bignum2], rax
    mov rax, qword[divD+8]
    mov qword[bignum2+8], rax
    mov rax, qword[divD+16]
    mov qword[bignum2+16], rax
    mov rax, qword[divD+24]
    mov qword[bignum2+24], rax
    
    mov qword[bignum1+24], 0
    mov qword[bignum1+16], 0
    mov qword[bignum1+8], 0
    
divdone:

    mov rbx, 24 ;initial condition
    
shiftdivQ: ;Shift divQ and stores in bignum1
    mov rax, qword[divQ+rbx]
    sub rbx, rcx
    mov qword[bignum1+rbx], rax
    cmp rbx, rcx
    jge shiftdivQ
    
    ;Stores divQ shifted
    mov rax, qword[bignum1]
    mov qword[divQ], rax
    mov rax, qword[bignum1+8]
    mov qword[divQ+8], rax
    mov rax, qword[bignum1+16]
    mov qword[divQ+16], rax
    mov rax, qword[bignum1+24]
    mov qword[divQ+24], rax
    
    PRINT_HEX 8, bignum1+24
    PRINT_HEX 8, bignum1+16
    PRINT_HEX 8, bignum1+8
    PRINT_HEX 8, bignum1
    
    NEWLINE
    
    PRINT_HEX 8, bignum2+24
    PRINT_HEX 8, bignum2+16
    PRINT_HEX 8, bignum2+8
    PRINT_HEX 8, bignum2
    
    call bigmul
    
    NEWLINE
    PRINT_HEX 8, bignum2+24
    PRINT_HEX 8, bignum2+16
    PRINT_HEX 8, bignum2+8
    PRINT_HEX 8, bignum2
    
    ret
    
bigdiv2:
    
    