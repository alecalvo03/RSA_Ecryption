%include "io64.inc"
%include '/home/alejandro/Documents/GitHub/RSA_Ecryption/bignum.asm'

section .data

    test4       dq      0xc510a1244649856d, 0xc33044955f582bd4, 0, 0, 0, 0, 0, 0
    test5       dq      0xcec3a860ead50151, 0xa4802ab77b56bffb, 0, 0, 0, 0, 0, 0
    
    
section .bss

    keysP       resq    1
    keysQ       resq    1
    keysN       resq    8
    keysE       resq    8
    keysL       resq    8
    keysD       resq    8
    keys1       resq    8
    
    cryptX      resq    1
    cryptK      resq    1
    cryptN      resq    1
    cryptR      resq    8
    
    mensaje     resb    31
    lenmensaje  equ     $-mensaje
    
    

section .text

global CMAIN
CMAIN:
    mov rbp, rsp; for correct debugging

    mov qword[keysP], test4
    mov qword[keysQ], test5
    call makekeys
    
    mov     edx, lenmensaje
    mov     ecx, mensaje
    mov     ebx, 0
    mov     eax, 3      
    int     80H
    
    PRINT_HEX 8, keysE+24
    NEWLINE
    PRINT_HEX 8, keysE+16
    NEWLINE
    PRINT_HEX 8, keysE+8
    NEWLINE
    PRINT_HEX 8, keysE
    NEWLINE
    
    PRINT_HEX 8, keysN+24
    NEWLINE
    PRINT_HEX 8, keysN+16
    NEWLINE
    PRINT_HEX 8, keysN+8
    NEWLINE
    PRINT_HEX 8, keysN
    NEWLINE
    
    mov qword[expmodX], mensaje
    mov qword[expmodK], keysE
    mov qword[expmodN], keysN
    call bigexpmod
    
    PRINT_HEX 8, expmodR+24
    PRINT_HEX 8, expmodR+16
    PRINT_HEX 8, expmodR+8
    PRINT_HEX 8, expmodR
    NEWLINE
    
    mov qword[copyD], test4
    mov qword[copyS], expmodR
    call copyvector
    
    mov qword[expmodX], test4
    mov qword[expmodK], keysD
    mov qword[expmodN], keysN
    call bigexpmod
    
    PRINT_HEX 8, expmodR+24
    PRINT_HEX 8, expmodR+16
    PRINT_HEX 8, expmodR+8
    PRINT_HEX 8, expmodR
    NEWLINE
    
    PRINT_HEX 8, mensaje+24
    PRINT_HEX 8, mensaje+16
    PRINT_HEX 8, mensaje+8
    PRINT_HEX 8, mensaje
    NEWLINE
    
    ret
    
    mov     edx, lenmensaje  
    mov     ecx, expmodR 
    mov     ebx, 1
    mov     eax, 4
    int     80H 
    
    ;NEWLINE
    
    PRINT_HEX 8, mensaje+24
    PRINT_HEX 8, mensaje+16
    PRINT_HEX 8, mensaje+8
    PRINT_HEX 8, mensaje
    NEWLINE
    
    ret 

    
    mov qword[keysP], test4
    mov qword[keysQ], test5
    call makekeys
    
    PRINT_HEX 8, keysN+24
    PRINT_HEX 8, keysN+16
    PRINT_HEX 8, keysN+8
    PRINT_HEX 8, keysN
    NEWLINE
    
    PRINT_HEX 8, keysL+24
    PRINT_HEX 8, keysL+16
    PRINT_HEX 8, keysL+8
    PRINT_HEX 8, keysL
    NEWLINE
    
    PRINT_HEX 8, keysE+24
    PRINT_HEX 8, keysE+16
    PRINT_HEX 8, keysE+8
    PRINT_HEX 8, keysE
    NEWLINE
    
    PRINT_HEX 8, keysD+24
    PRINT_HEX 8, keysD+16
    PRINT_HEX 8, keysD+8
    PRINT_HEX 8, keysD
    NEWLINE
    
    xor rax, rax
    
makekeys:
    push r10
    push r11
    
    mov r10, [keysP]
    mov r11, [keysQ]
    
    mov qword[clBignum], keys1
    call clearbignum
    mov qword[keys1], 1
    
    mov qword[mulD], keysN
    mov qword[mul1], r10
    mov qword[mul2], r11
    call bigmul
    
    mov qword[subD], r10
    mov qword[subS], keys1
    call bigsub
    
    mov qword[subD], r11
    mov qword[subS], keys1
    call bigsub
    
    mov qword[mulD], keysL
    mov qword[mul1], r10
    mov qword[mul2], r11
    call bigmul
    
    mov qword[coprimeA], keysL
    call coprime
    
    mov qword[copyD], keysE
    mov qword[copyS], coprimeR
    call copyvector
    
    mov qword[modinvE], keysE
    mov qword[modinvL], keysL
    call modinv
    
    mov qword[copyD], keysD
    mov qword[copyS], modinvR
    call copyvector

    pop r11
    pop r10
    ret
    
encrypt:
    push r10
    push r11
    push r12
    
    mov r10, [cryptX]
    mov r11, [cryptK]
    mov r12, [cryptN]
    
    mov qword[expmodX], r10
    mov qword[expmodK], r11
    mov qword[expmodN], r12
    call bigexpmod
    
    mov qword[copyD], cryptR
    mov qword[copyS], expmodR
    call copyvector
    
    pop r12
    pop r11
    pop r10
    ret
    