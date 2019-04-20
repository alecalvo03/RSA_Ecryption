%include "io64.inc"


extern exit


section	.data
    bignum1     dq      2, 2, 2, 2, 0, 0, 0, 0;0xFFFFFFFFFFAFFFFF, 0xFFFFFBFFFFFFFFFF, 0, 0
    bignum2     dq      4, 3, 7, 8, 0, 0, 0, 0;0xFFFFFFFFFFFFFFCF, 0xFFFDFFFFFFFFFFFF, 0, 0
    mulr        dq      3, 5, 1, 0, 0, 0, 0, 0 ;000000000000000
    
    test1       dq      0xed7fb5a6961790f1, 0x2, 0, 0, 0, 0, 0, 0
    test2       dq      3, 1, 0, 0, 0, 0, 0, 0
    test3       dq      0, 0, 0, 0, 0, 0, 0, 0
    
    expmod      dq      0
    
    size        dq      56
    
    
section .bss
    clBignum    resq    1
    
    addD        resq    1
    addS        resq    1
    
    subD        resq    1
    subS        resq    1
    
    mulD        resq    1
    mul1        resq    1
    mul2        resq    1
    mulTem      resq    8
    
    magV        resq    1
    
    copyD       resq    1
    copyS       resq    1

    divD        resq    1           ;Denominator pointer
    divN        resq    1           ;Numerator pinter
    divQ        resq    8           ;Quotient vector
    divR        resq    8           ;Residue vector
    divQpiv     resq    8           ;Vector to pivot Q for shifting
    divQc       resq    8           ;Quotient count vector
    divM        resq    1           ;Magnitude
    divNN       resq    8           ;Changing Numerator vector
    divNeg      resq    1           ;Flag if residue is negative
    divNo       resq    1
    divQD       resq    8
    divAbs1     resq    8
    divAbs2     resq    8
    
    expmodX     resq    1
    expmodK     resq    1
    expmodN     resq    1
    expmodR     resq    8
    expmodTR    resq    8


section .text
	global CMAIN

CMAIN:
    mov rbp, rsp; for correct debugging
    
    mov qword[expmodX], bignum1
    mov qword[expmodK], bignum2
    mov qword[expmodN], mulr
    call bigexpmod
    
    PRINT_HEX 8, expmodR+56
    NEWLINE
    PRINT_HEX 8, expmodR+48
    NEWLINE
    PRINT_HEX 8, expmodR+40
    NEWLINE
    PRINT_HEX 8, expmodR+32
    NEWLINE
    PRINT_HEX 8, expmodR+24
    NEWLINE
    PRINT_HEX 8, expmodR+16
    NEWLINE
    PRINT_HEX 8, expmodR+8
    NEWLINE
    PRINT_HEX 8, expmodR
    NEWLINE
    
    mov qword[mulD], test3
    mov qword[mul1], test1
    mov qword[mul2], test1
    call bigmul
    
    mov qword[copyD], test1
    mov qword[copyS], test3
    call copyvector
    
    PRINT_HEX 8, test1+24
    PRINT_HEX 8, test1+16
    PRINT_HEX 8, test1+8
    PRINT_HEX 8, test1
    NEWLINE
    
    mov qword[divN], test1
    mov qword[divD], test2
    call bigdiv
    
    PRINT_HEX 8, divQc+24
    PRINT_HEX 8, divQc+16
    PRINT_HEX 8, divQc+8
    PRINT_HEX 8, divQc
    NEWLINE
    
    PRINT_HEX 8, divR+24
    PRINT_HEX 8, divR+16
    PRINT_HEX 8, divR+8
    PRINT_HEX 8, divR
    NEWLINE
    
    
    mov qword[expmodX], bignum1
    mov qword[expmodK], bignum2
    mov qword[expmodN], mulr
    call bigexpmod
    
    PRINT_HEX 8, expmodR+56
    NEWLINE
    PRINT_HEX 8, expmodR+48
    NEWLINE
    PRINT_HEX 8, expmodR+40
    NEWLINE
    PRINT_HEX 8, expmodR+32
    NEWLINE
    PRINT_HEX 8, expmodR+24
    NEWLINE
    PRINT_HEX 8, expmodR+16
    NEWLINE
    PRINT_HEX 8, expmodR+8
    NEWLINE
    PRINT_HEX 8, expmodR
    NEWLINE
    
    call exit
    
clearbignum:
    push rcx
    push r10
    xor rcx, rcx
    mov r10, [clBignum]             ;stores pointer
    
clearbignumloop:
    mov qword[r10+rcx], 0
    cmp rcx, qword[size]
    jz clearbignumret
    add rcx, 8
    jmp clearbignumloop
    
clearbignumret:
    pop r10
    pop rcx
    ret
    

bigadd:                                 ;bignum2 = bignum2 + bignum1
    push rcx
    push rbx
    push r10
    push r11
    clc
    xor rcx, rcx
    xor rbx, rbx
    mov r10, [addD]                 ;stores destination pointer
    mov r11, [addS]                 ;stores source pointer
    
    
bigaddloop:
    cmp rbx, 0
    jz notcarryadd
    xor rbx, rbx
    stc
    
notcarryadd:
    mov rax, qword[r11+rcx]
    adc qword[r10+rcx], rax
    adc rbx, 0
    cmp rcx, qword[size]
    jz bigaddret
    add rcx, 8
    jmp bigaddloop
    
bigaddret:

    pop r11
    pop r10
    pop rbx
    pop rcx
    ret
    
    
    
bigsub:                                 ;subD = subD - subS
    push rcx
    push rbx
    push r10
    push r11
    clc
    xor rcx, rcx
    xor rbx, rbx
    mov r10, [subD]                 ;stores destination pointer
    mov r11, [subS]                 ;stores source pointer
    
    
bigsubloop:
    cmp rbx, 0
    jz notcarrysub
    xor rbx, rbx
    stc
    
notcarrysub:
    mov rax, qword[r11+rcx]
    sbb qword[r10+rcx], rax
    sbb rbx, 0
    cmp rcx, qword[size]
    jz bigsubret
    add rcx, 8
    jmp bigsubloop
    
bigsubret:
    pop r11
    pop r10
    pop rbx
    pop rcx
    ret



bigmul:
    push rcx
    push rbx
    push r10
    push r11
    push r12
    push r13
    mov r10, [mulD]                ;stores destination pointer
    mov r11, [mul1]                 ;stores source 1 pointer
    mov r12, [mul2]                 ;stores source 2 pointer
    xor rcx, rcx ;rcx = 0

    mov qword[clBignum], r10
    call clearbignum
    
    mov qword[clBignum], mulTem
    call clearbignum
    
    xor rcx, rcx
    xor rbx, rbx
    
bigmulloop:

    mov rax, qword[r11+rcx]
    mul qword[r12+rbx]
    
    mov qword[clBignum], mulTem
    call clearbignum
    mov r13, mulTem               ;Stores pointer to temporary vector
    
    push rcx
    add rcx, rbx
    
    mov qword[r13+rcx], rax
    
    ;Check is rcx+rbx is less that the size
    cmp rcx, qword[size]
    jz bigmullimit
    
    mov qword[r13+rcx+8], rdx
    
bigmullimit:
    mov qword[addD], r10
    mov qword[addS], r13
    call bigadd

    ;Check is rcx+rbx is less that the size
    cmp rcx, qword[size]
    pop rcx
    je bigmullimit2
    add rbx, 8
    jmp bigmulloop
    
bigmullimit2:
    cmp rcx, qword[size]
    je bigmulret
    add rcx, 8
    xor rbx, rbx
    jmp bigmulloop
    
    
    
bigmulret:
    pop r13
    pop r12
    pop r11
    pop r10
    pop rbx
    pop rcx
    ret
  
  
copyvector:
    push rcx
    push r10
    push r11
    mov r10, [copyD]
    mov r11, [copyS]
    mov rcx, qword[size]
    
copyloop:
    mov rax, qword[r11+rcx]
    mov qword[r10+rcx], rax
    cmp rcx, 0
    je copyret
    sub rcx, 8
    jmp copyloop
    
copyret:
    pop r11
    pop r10
    pop rcx
    ret
    
  

getmagnitude:
    push r10
    mov r10, [magV]
    mov rax, qword[size]
    
magnitudeloop:
    cmp qword[r10+rax], 0
    jne donemagnitude
    sub rax, 8
    jmp magnitudeloop
    
donemagnitude:
    mov qword[divM], rax
    pop r10
    ret
    

;;Progress
bigdiv:                                         ;bignum2 = bignum2 / bignum1, bignum1 = bignum2 % bignum1
    push rcx
    push rbx
    push r10
    push r11
    
    mov r10, [divD]
    mov r11, [divN]
    
    mov qword[copyD], divNN             ;Saves original numerator
    mov qword[copyS], r11
    call copyvector
    
    mov qword[divNeg], 0
    
    mov qword[clBignum], divQc
    call clearbignum
    
    mov qword[clBignum], divQ
    call clearbignum
    
    mov qword[clBignum], divR
    call clearbignum
    
    mov qword[magV], r10
    call getmagnitude
    
divloop:
    mov rcx, qword[divM]
    mov rbx, qword[size]
    xor rdx, rdx
    
    ;Divs each digit and concatenates modulus on rdx
divloop1:
    mov rax, qword[divNN+rbx]
    div qword[r10+rcx]
    mov qword[divQ+rbx], rax
    cmp rcx, rbx
    jz divdone
    sub rbx, 8
    jmp divloop1
    
divdone:

    mov rbx, qword[divM] ;initial condition
    cmp qword[divM], 0
    jz shifteddivQ
    
    mov qword[clBignum], divQpiv
    call clearbignum
    
shiftdivQ: ;Shift divQ and stores in bignum1
    mov rax, qword[divQ+rbx]
    push rbx
    sub rbx, qword[divM]
    mov qword[divQpiv+rbx], rax
    pop rbx
    add rbx, 8
    cmp rbx, qword[size]
    jle shiftdivQ
    
    mov qword[copyD], divQ
    mov qword[copyS], divQpiv
    call copyvector
    
shifteddivQ:    
    cmp qword[divNeg], 1
    
    jz negative
    mov qword[addD], divQc
    mov qword[addS], divQ
    call bigadd ;Adds Q and previous Q (Qc)
    jmp notnegative
    
negative:
    mov qword[subD], divQc
    mov qword[subS], divQ
    call bigsub ;Substracts Q and previous Q (Qc)
    
notnegative:

    mov qword[mulD], divQD
    mov qword[mul1], divQc
    mov qword[mul2], r10
    call bigmul

    mov qword[copyD], divR
    mov qword[copyS], r11
    call copyvector

    mov qword[subD], divR
    mov qword[subS], divQD
    call bigsub

    mov qword[divNeg], 0
    
    mov qword[clBignum], divAbs1
    call clearbignum
    
    ;abs(bignum2)
    mov rcx, qword[size]
    cmp qword[divR+rcx],0
    jge absolut
    
    mov qword[clBignum], divAbs2
    call clearbignum
    
    mov qword[divAbs2], 1
    
    mov qword[subD], divAbs1
    mov qword[subS], divAbs2
    call bigsub                     ;divAbs1 = -1

    mov qword[divNeg], 1
    
absolut: 
    mov qword[addD], divR
    mov qword[addS], divAbs1
    call bigadd
    
    mov rcx, 0
    
xorloop:
    mov rax, qword[divAbs1+rcx]
    xor qword[divR+rcx], rax
    add rcx, 8
    cmp rcx, qword[size]
    jle xorloop
    
    ;Residue is new Numerator
    mov qword[copyD], divNN
    mov qword[copyS], divR
    call copyvector

    mov rcx, qword[size]
cmploop:
    mov rax, qword[r10+rcx]
    cmp rax, qword[divR+rcx]
    jg enddiv
    jl divloop
    sub rcx, 8
    cmp rcx, qword[size]
    jle cmploop    
    
    jmp divloop
    
enddiv:
    cmp qword[divNeg], 0
    jz divret
    
    mov qword[copyD], divAbs1
    mov qword[copyS], r10
    call copyvector
    
    mov qword[subD], divAbs1
    mov qword[subS], divR
    call bigsub
    
    mov qword[copyD], divR
    mov qword[copyS], divAbs1
    call copyvector
    
    ;Sub 1 to Qc
    mov qword[clBignum], divAbs2
    call clearbignum
    
    mov qword[divAbs2], 1
    
    mov qword[subD], divQc
    mov qword[subS], divAbs2
    call bigsub

divret:
    pop r11
    pop r10
    pop rbx
    pop rcx
    
    ret
    
bigexpmod:
    push rcx
    push rbx
    push r10
    push r11
    push r12
    
    mov r10, [expmodX]
    mov r11, [expmodK]
    mov r12, [expmodN]

    mov rcx, 63                     ;register size
    mov rbx, qword[size]

    mov qword[clBignum], expmodR
    call clearbignum
    
    mov qword[expmodR], 1           ;R = 1

expmodloop:

    
    ;R=R*R%N
    mov qword[mulD], expmodTR
    mov qword[mul1], expmodR
    mov qword[mul2], expmodR
    call bigmul ;TR=R*R
    
    mov qword[copyD], expmodR
    mov qword[copyS], expmodTR
    call copyvector
    
    ;PRINT_HEX 8, expmodR+24
    ;PRINT_HEX 8, expmodR+16
    ;PRINT_HEX 8, expmodR+8
    ;PRINT_HEX 8, expmodR
    ;NEWLINE
    
    mov qword[divN], expmodR
    mov qword[divD], r12
    call bigdiv ; R=R%N
    
    mov qword[copyD], expmodR
    mov qword[copyS], divR
    call copyvector
    
    ;PRINT_HEX 8, expmodR+24
    ;PRINT_HEX 8, expmodR+16
    ;PRINT_HEX 8, expmodR+8
    ;PRINT_HEX 8, expmodR
    ;NEWLINE

    ;Check if is 1 in bits of K
    mov rax, 1
    shl rax, cl
    and rax, qword[r11+rbx]
    cmp rax, 0
    jz expmod0
    
    ;R=R*X%N
   
    mov qword[mulD], expmodTR
    mov qword[mul1], expmodR
    mov qword[mul2], r10
    call bigmul ;R=R*X
    
    mov qword[copyD], expmodR
    mov qword[copyS], expmodTR
    call copyvector

    mov qword[divN], expmodR
    mov qword[divD], r12
    call bigdiv ; R=R%N
    
    mov qword[copyD], expmodR
    mov qword[copyS], divR
    call copyvector
    
    PRINT_HEX 8, expmodR+24
    PRINT_HEX 8, expmodR+16
    PRINT_HEX 8, expmodR+8
    PRINT_HEX 8, expmodR
    NEWLINE
    
expmod0:

    PRINT_HEX 8, expmodR+24
    PRINT_HEX 8, expmodR+16
    PRINT_HEX 8, expmodR+8
    PRINT_HEX 8, expmodR
    NEWLINE

    cmp rcx, 0
    jz expmodregdone
    dec rcx
    jmp expmodloop
    
expmodregdone:
    cmp rbx, 0
    jz expmodend
    sub rbx, 8
    mov rcx, 63
    jmp expmodloop
    
expmodend:
    pop r12
    pop r11
    pop r10
    pop rbx
    pop rcx
    ret

    