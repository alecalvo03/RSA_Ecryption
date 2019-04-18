%include "io64.inc"

section	.data
    bignum1 dq 2, 2, 0, 0;0xFFFFFFFFFFAFFFFF, 0xFFFFFBFFFFFFFFFF, 0, 0
    bignum2 dq 4, 6, 0x7568d, 0;0xFFFFFFFFFFFFFFCF, 0xFFFDFFFFFFFFFFFF, 0, 0
    mul1    dq 0xFFFFFFFFFFAFFFFF, 0xFFFFFBFFFFFFFFFF, 0xFFF3FFFFFFFFFFFF, 0xFFFFF1FFFFFFFFFF
    mul2    dq 0xFFFFFF4FFFFFFFFF, 0xFFFFFFFFFF6FFFFF, 0xFFFFFFFFFF2FFFFF, 0xFFF7FFFFFFFFFFFF
    mulr    dq 0, 0, 0, 0

    divD    dq 0, 0, 0, 0
    divN    dq 0, 0, 0, 0
    divQ    dq 0, 0, 0, 0
    divQc   dq 0, 0, 0, 0
    divM    dq 0
    divNo   dq 0, 0, 0, 0
    divNeg  dq 0
    
    


section .text
	global CMAIN

CMAIN:
    mov rbp, rsp; for correct debugging
    

    call bigdiv
    
    PRINT_HEX 8, bignum2+24
    PRINT_HEX 8, bignum2+16
    PRINT_HEX 8, bignum2+8
    PRINT_HEX 8, bignum2
    NEWLINE

    PRINT_HEX 8, bignum1+24
    PRINT_HEX 8, bignum1+16
    PRINT_HEX 8, bignum1+8
    PRINT_HEX 8, bignum1
    NEWLINE
    
    PRINT_HEX 8, divNeg
    NEWLINE

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

bigmul:
    mov qword[mulr], 0
    mov qword[mulr+8], 0
    mov qword[mulr+16], 0
    mov qword[mulr+24], 0

    mov rax, qword[bignum1]		                 ; move mul1[0] to rax
    mul qword[bignum2]				; rdx:rax = mlu1[0]*mul2[0]
    
    mov qword[mulr], rax			        ; move rax to mul3[0]
    mov qword[mulr+8], rdx		        ; move rdx to mul3[1]
    
    mov rax, qword [bignum1]		        ; move mul1[0] to rax
    mul qword [bignum2+8]		                ; rdx:rax = mul1[0]*mul2[1]
    
    add qword[mulr+8], rax
    adc qword[mulr+16], rdx
    adc qword[mulr+24], 0
    
    mov rax, qword [bignum1]		        ; move mul1[0] to rax
    mul qword [bignum2+16]				; rdx:rax = mul1[0]*mul2[2]
    
    add qword[mulr+16], rax
    adc qword[mulr+24], rdx
    
    mov rax, qword [bignum1]		        ; move mul1[0] to rax
    mul qword [bignum2+24]			        ; rdx:rax = mul1[0]*mul2[3]
    
    add qword[mulr+24], rax
    

    mov rax, qword [bignum1+8]		        ; move mul1[1] to rax
    mul qword [bignum2]		                ; rdx:rax = mul1[1]*mul2[0]
    
    add qword[mulr+8], rax
    adc qword[mulr+16], rdx
    adc qword[mulr+24], 0
    
    mov rax, qword [bignum1+8]		        ; move mul1[1] to rax
    mul qword [bignum2+8]				; rdx:rax = mul1[1]*mul2[1]
    
    add qword[mulr+16], rax
    adc qword[mulr+24], rdx
    
    mov rax, qword [bignum1+8]		        ; move mul1[1] to rax
    mul qword [bignum2+16]			        ; rdx:rax = mul1[1]*mul2[2]
    
    add qword[mulr+24], rax
    

    mov rax, qword [bignum1+16]		        ; move mul1[2] to rax
    mul qword [bignum2]				; rdx:rax = mul1[2]*mul2[0]
    
    add qword[mulr+16], rax
    adc qword[mulr+24], rdx
    
    mov rax, qword [bignum1+16]		        ; move mul1[2] to rax
    mul qword [bignum2+8]			        ; rdx:rax = mul1[2]*mul2[1]
    
    add qword[mulr+24], rax
    

    mov rax, qword [bignum1+24]		        ; move mul1[3] to rax
    mul qword [bignum2]			        ; rdx:rax = mul1[3]*mul2[0]
    
    add qword[mulr+24], rax
    
    
    mov rax, qword[mulr]
    mov qword[bignum2], rax
    mov rax, qword[mulr+8]
    mov qword[bignum2+8], rax
    mov rax, qword[mulr+16]
    mov qword[bignum2+16], rax
    mov rax, qword[mulr+24]
    mov qword[bignum2+24], rax
    
    ret

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
    mov qword[divNo], rax
    mov rax, qword[bignum2+8]
    mov qword[divN+8], rax
    mov qword[divNo+8], rax
    mov rax, qword[bignum2+16]
    mov qword[divN+16], rax
    mov qword[divNo+16], rax
    mov rax, qword[bignum2+24]
    mov qword[divN+24], rax
    mov qword[divNo+24], rax
    
    mov qword[divQc], 0
    mov qword[divQc+8], 0
    mov qword[divQc+16], 0
    mov qword[divQc+24], 0
    
    mov qword[divQ], 0
    mov qword[divQ+8], 0
    mov qword[divQ+16], 0
    mov qword[divQ+24], 0
    
    call getmagnitude
    
divloop:

    mov rcx, qword[divM]
    
    PRINT_HEX 8, divD+24
    PRINT_HEX 8, divD+16
    PRINT_HEX 8, divD+8
    PRINT_HEX 8, divD
    NEWLINE
    
    PRINT_HEX 8, divN+24
    PRINT_HEX 8, divN+16
    PRINT_HEX 8, divN+8
    PRINT_HEX 8, divN
    NEWLINE
    
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
    div qword[divD+rcx]
    mov qword[divQ], rax
    
divdone:

    mov rbx, 24 ;initial condition
    cmp rcx, 0
    jz shifteddivQ
    
    mov qword[bignum1+24], 0
    mov qword[bignum1+16], 0
    mov qword[bignum1+8], 0
    mov qword[bignum1], 0
    
shiftdivQ: ;Shift divQ and stores in bignum1
    mov rax, qword[divQ+rbx]
    sub rbx, rcx
    mov qword[bignum1+rbx], rax
    cmp rbx, rcx
    jge shiftdivQ
    
    mov rax, qword[bignum1]
    mov qword[divQ], rax
    mov rax, qword[bignum1+8]
    mov qword[divQ+8], rax
    mov rax, qword[bignum1+16]
    mov qword[divQ+16], rax
    mov rax, qword[bignum1+24]
    mov qword[divQ+24], rax
    
shifteddivQ:
    
    ;Stores divQ shifted
    mov rax, qword[divQ]
    mov qword[bignum1], rax
    mov rax, qword[divQ+8]
    mov qword[bignum1+8], rax
    mov rax, qword[divQ+16]
    mov qword[bignum1+16], rax
    mov rax, qword[divQ+24]
    mov qword[bignum1+24], rax
    
    PRINT_HEX 8, divQ+24
    PRINT_HEX 8, divQ+16
    PRINT_HEX 8, divQ+8
    PRINT_HEX 8, divQ
    NEWLINE
    
    mov rax, qword[divQc]
    mov qword[bignum2], rax
    mov rax, qword[divQc+8]
    mov qword[bignum2+8], rax
    mov rax, qword[divQc+16]
    mov qword[bignum2+16], rax
    mov rax, qword[divQc+24]
    mov qword[bignum2+24], rax
    cmp qword[divNeg], 1
    jz negative
    call bigadd ;Adds Q and previous Q (Qc)
    jmp notnegative
negative:
    call bigsub ;Substracts Q and previous Q (Qc)
notnegative:

    PRINT_HEX 8, bignum2+24
    PRINT_HEX 8, bignum2+16
    PRINT_HEX 8, bignum2+8
    PRINT_HEX 8, bignum2
    NEWLINE
    
    ;Stores result in Qc
    mov rax, qword[bignum2]
    mov qword[divQc], rax
    mov rax, qword[bignum2+8]
    mov qword[divQc+8], rax
    mov rax, qword[bignum2+16]
    mov qword[divQc+16], rax
    mov rax, qword[bignum2+24]
    mov qword[divQc+24], rax
    
    ;stores divD in bignum2
    mov rax, qword[divD]
    mov qword[bignum1], rax
    mov rax, qword[divD+8]
    mov qword[bignum1+8], rax
    mov rax, qword[divD+16]
    mov qword[bignum1+16], rax
    mov rax, qword[divD+24]
    mov qword[bignum1+24], rax
    
    PRINT_HEX 8, bignum1+24
    PRINT_HEX 8, bignum1+16
    PRINT_HEX 8, bignum1+8
    PRINT_HEX 8, bignum1
    NEWLINE
    
    call bigmul
    
    PRINT_HEX 8, bignum2+24
    PRINT_HEX 8, bignum2+16
    PRINT_HEX 8, bignum2+8
    PRINT_HEX 8, bignum2
    NEWLINE
    
    mov rax, qword[bignum2]
    mov qword[bignum1], rax
    mov rax, qword[bignum2+8]
    mov qword[bignum1+8], rax
    mov rax, qword[bignum2+16]
    mov qword[bignum1+16], rax
    mov rax, qword[bignum2+24]
    mov qword[bignum1+24], rax
    
    mov rax, qword[divNo]
    mov qword[bignum2], rax
    mov rax, qword[divNo+8]
    mov qword[bignum2+8], rax
    mov rax, qword[divNo+16]
    mov qword[bignum2+16], rax
    mov rax, qword[divNo+24]
    mov qword[bignum2+24], rax
    call bigsub
    
    PRINT_HEX 8, bignum2+24
    PRINT_HEX 8, bignum2+16
    PRINT_HEX 8, bignum2+8
    PRINT_HEX 8, bignum2
    NEWLINE
    
    ;Stores new N
    ;mov rax, qword[bignum2]
    ;mov qword[divN], rax
    ;mov rax, qword[bignum2+8]
    ;mov qword[divN+8], rax
    ;mov rax, qword[bignum2+16]
    ;mov qword[divN+16], rax
    ;mov rax, qword[bignum2+24]
    ;mov qword[divN+24], rax
    
    mov qword[bignum1+24], 0
    mov qword[bignum1+16], 0
    mov qword[bignum1+8], 0
    mov qword[bignum1], 0
    mov qword[divNeg], 0
    
    ;abs(bignum2)
    cmp qword[bignum2+24],0
    jge absolut
    mov qword[divNeg], 1
    mov qword[bignum1+24], -1
    mov qword[bignum1+16], -1
    mov qword[bignum1+8], -1
    mov qword[bignum1], -1
    
absolut: 

    call bigadd
    
    mov rax, qword[bignum1]
    xor qword[bignum2], rax
    mov rax, qword[bignum1+8]
    xor qword[bignum2+8], rax
    mov rax, qword[bignum1+16]
    xor qword[bignum2+16], rax
    mov rax, qword[bignum1+24]
    xor qword[bignum2+24], rax
    
    PRINT_HEX 8, bignum2+24
    PRINT_HEX 8, bignum2+16
    PRINT_HEX 8, bignum2+8
    PRINT_HEX 8, bignum2
    NEWLINE
    
    ;Stores new N
    mov rax, qword[bignum2]
    mov qword[divN], rax
    mov rax, qword[bignum2+8]
    mov qword[divN+8], rax
    mov rax, qword[bignum2+16]
    mov qword[divN+16], rax
    mov rax, qword[bignum2+24]
    mov qword[divN+24], rax
       
    ;compares R and D
    mov rax, qword[divD+24]
    cmp qword[bignum2+24], rax
    jl enddiv
    mov rax, qword[divD+16]
    cmp qword[bignum2+16], rax
    jl enddiv
    mov rax, qword[divD+8]
    cmp qword[bignum2+8], rax
    jl enddiv
    mov rax, qword[divD]
    cmp qword[bignum2], rax
    jl enddiv
    jmp divloop
    
enddiv:

    
    cmp qword[divNeg], 0
    jz divret
    
    mov rax, qword[bignum2]
    mov qword[bignum1], rax
    mov rax, qword[bignum2+8]
    mov qword[bignum1+8], rax
    mov rax, qword[bignum2+16]
    mov qword[bignum1+16], rax
    mov rax, qword[bignum2+24]
    mov qword[bignum1+24], rax
    
    mov rax, qword[divD]
    mov qword[bignum2], rax
    mov rax, qword[divD+8]
    mov qword[bignum2+8], rax
    mov rax, qword[divD+16]
    mov qword[bignum2+16], rax
    mov rax, qword[divD+24]
    mov qword[bignum2+24], rax
    
    call bigsub
    
    ;Add 1 to Qc
    mov rax, 1
    sub qword[divQc], rax
    mov rax, 0
    sbb qword[divQc+8], rax
    sbb qword[divQc+16], rax
    sbb qword[divQc+24], rax
    
    

    
divret:

    mov rax, qword[bignum2]
    mov qword[bignum1], rax
    mov rax, qword[bignum2+8]
    mov qword[bignum1+8], rax
    mov rax, qword[bignum2+16]
    mov qword[bignum1+16], rax
    mov rax, qword[bignum2+24]
    mov qword[bignum1+24], rax
    
    mov rax, qword[divQc]
    mov qword[bignum2], rax
    mov rax, qword[divQc+8]
    mov qword[bignum2+8], rax
    mov rax, qword[divQc+16]
    mov qword[bignum2+16], rax
    mov rax, qword[divQc+24]
    mov qword[bignum2+24], rax
    
    ret
    
bigdiv2:
    
    