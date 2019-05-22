%include "io64.inc"
%include '/home/alejandro/Documents/GitHub/RSA_Ecryption/bignum.asm'

extern exit

section .data

    test4       dq      0xc510a1244649856d, 0xc33044955f582bd4, 0, 0, 0, 0, 0, 0
    test5       dq      0xcec3a860ead50151, 0xa4802ab77b56bffb, 0, 0, 0, 0, 0, 0
    
    numE        dq      0x6fa8067737a0bdf9, 0x215f0c3cd5167ccc, 0x5ccc5f7b2e2ed728, 0, 0, 0, 0, 0
    numL        dq      0x05a6173cfb5b1dc0, 0x643195f051f90560, 0xa7fb8794a3762537, 0x7d6ca4a3cc900621, 0, 0, 0, 0

    text1       db      "Seleccione la funcion a realizar:",10
    len1        equ     $ - text1
    text2       db      "1 - Encriptar",10
    len2        equ     $ - text2
    text3       db      "2 - Desencriptar",10
    len3        equ     $ - text3
    text4       db      "3 - Generar llaves",10
    len4        equ     $ - text4

    noseltext   db      "Seleccione un número válido",10
    lennosel    equ     $ - noseltext
    
    encrypttext db      "Mensaje encriptado exitosamente",10
    encryptlen  equ     $ - encrypttext
    decrypttext db      "Mensaje desencriptado exitosamente",10
    decryptlen  equ     $ - decrypttext
    keytext     db      "Llaves generadas exitosamente",10
    keytextlen  equ     $ - keytext
    
    keyEfile    db      '/home/alejandro/Documents/GitHub/RSA_Ecryption/files/keyE.bin', 0
    keyDfile    db      '/home/alejandro/Documents/GitHub/RSA_Ecryption/files/keyD.bin', 0
    keyNfile    db      '/home/alejandro/Documents/GitHub/RSA_Ecryption/files/keyN.bin', 0
    
    msgfile     db      '/home/alejandro/Documents/GitHub/RSA_Ecryption/files/msg.txt', 0
    outfile     db      '/home/alejandro/Documents/GitHub/RSA_Ecryption/files/out.txt', 0
    
    file1       db      '/home/alejandro/Documents/GitHub/RSA_Ecryption/files/prime1.bin', 0
    
section .bss

    keysP       resq    1
    keysQ       resq    1
    keysN       resq    8
    lenkeyN     equ     $ - keysN
    keysE       resq    8
    lenkeyE     equ     $ - keysE
    keysL       resq    8
    keysD       resq    8
    lenkeyD     equ     $ - keysD
    keys1       resq    8
    
    primeP      resq    8
    primeQ      resq    8
    
    cryptX      resq    1
    cryptK      resq    1
    cryptN      resq    1
    cryptR      resq    8
    
    dada        resq    1
    
    mensaje     resb    32
    lenmensaje  equ     $ - mensaje
    bigmsg      resq    8
    
    select      resb    1
    lensel      equ     $ - select
    
    fd1         resq    1
    fd2         resq    1

section .text

global CMAIN
CMAIN:
    mov rbp, rsp; for correct debugging

selection:
    
    ;Print select operation message
    
    mov     rsi, text1
    mov     rdx, len1
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    mov     rsi, text2
    mov     rdx, len2
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    mov     rsi, text3
    mov     rdx, len3
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    mov     rsi, text4
    mov     rdx, len4
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    ;Read answer
    mov     rsi, select
    mov     rdx, lensel
    mov     rdi, 0              ;stdin
    mov     rax, 0              ;Read
    syscall

    cmp qword[select], "1"      ;if user input = 1
    je sel1
    
    cmp qword[select], "2"      ;if user input = 2
    je sel2
    
    cmp qword[select], "3"      ;if user input = 3
    je sel3

    jmp ninguno                 ;else/default

sel1:
    
    mov rax, 1
    
    ; Opens keyEfile file
    mov rdi, keyEfile
    mov rsi, 64 + 0     ;O_CREAT + O_RDONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Reads keyEfile to buffer
    mov rdi, [fd1] ; write in file descriptor
    mov rsi, keysE
    mov rdx, lenkeyE
    mov rax, 0
    syscall 
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    mov qword[expmodK], keysE       ;Sets key to encrypt
    
    call crypt
    
    ;Print success message
    mov     rsi, encrypttext
    mov     rdx, encryptlen
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    jmp end

sel2:

    mov rax, 2
    
    ; Opens keyDfile file
    mov rdi, keyDfile
    mov rsi, 64 + 0     ;O_CREAT + O_RDONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Reads keyDfile to buffer
    mov rdi, [fd1] ; write in file descriptor
    mov rsi, keysD
    mov rdx, lenkeyD
    mov rax, 0
    syscall 
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    mov qword[expmodK], keysD       ;Sets key to decrypt
    
    call crypt
    
    ;Print success message
    mov     rsi, decrypttext
    mov     rdx, decryptlen
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    jmp end

sel3:
    
    mov rax, 3
    mov qword[keysP], test4
    mov qword[keysQ], test5
    call makekeys
    
    ;Print success message
    mov     rsi, keytext
    mov     rdx, keytextlen
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    jmp end

ninguno:

    mov rax, 0
    mov     rsi, noseltext
    mov     rdx, lennosel
    mov     rdi, 1              ;stdout
    mov     rax, 1              ;Write
    syscall
    
    jmp end

end:
    
    call exit



crypt:

    ; Opens msg file
    mov rdi, msgfile
    mov rsi, 64 + 0     ;O_CREAT + O_RDONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Reads msg to buffer
    mov rdi, [fd1] ; write in file descriptor
    mov rsi, mensaje
    mov rdx, lenmensaje
    mov rax, 0
    syscall 
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall

    
    ; Opens keyNfile file
    mov rdi, keyNfile
    mov rsi, 64 + 0     ;O_CREAT + O_RDONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Reads keyNfile to buffer
    mov rdi, [fd1] ; write in file descriptor
    mov rsi, keysN
    mov rdx, lenkeyN
    mov rax, 0
    syscall 
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    ;Clear 256bit message
    mov qword[size], 56
    mov qword[clBignum], bigmsg
    call clearbignum
    
    mov qword[size], 24
    mov qword[copyD], bigmsg
    mov qword[copyS], mensaje
    call copyvector
    
    mov qword[size], 56
    
    mov qword[expmodX], bigmsg
    ;expmodK is set on selection
    mov qword[expmodN], keysN
    call bigexpmod

    mov qword[size], 24
    
    ; Opens outfile
    mov rdi, outfile
    mov rsi, 64 + 1     ;O_CREAT + O_WDONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Writes to outfile
    mov rdi, [fd1]
    mov rsi, expmodR
    mov rdx, 32
    mov rax, 1
    syscall
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    ret 

    
makekeys:
    push r10
    push r12
    
    mov r10, [keysP]
    mov r12, [keysQ]
    
    mov qword[clBignum], keys1
    call clearbignum
    mov qword[keys1], 1
    
    mov qword[mulD], keysN
    mov qword[mul1], r10
    mov qword[mul2], r12
    call bigmul
    
    
    ; Opens keyNfile
    mov rdi, keyNfile
    mov rsi, 64 + 1     ;O_CREAT + O_WRONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Writes to keyNfile
    mov rdi, [fd1]
    mov rsi, keysN
    mov rdx, 32
    mov rax, 1
    syscall
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    mov qword[subD], r10
    mov qword[subS], keys1
    call bigsub
    
    mov qword[subD], r12
    mov qword[subS], keys1
    call bigsub
    
    mov qword[mulD], keysL
    mov qword[mul1], r10
    mov qword[mul2], r12
    call bigmul
    
    mov qword[coprimeA], keysL
    call coprime
    
    mov qword[copyD], keysE
    mov qword[copyS], coprimeR
    call copyvector
    
    
    ; Opens keyEfile
    mov rdi, keyEfile
    mov rsi, 64 + 1     ;O_CREAT + O_WRONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Writes to keyNfile
    mov rdi, [fd1]
    mov rsi, keysE
    mov rdx, 32
    mov rax, 1
    syscall
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall
    
    mov qword[modinvE], keysE
    mov qword[modinvL], keysL
    call modinv
    
    mov qword[copyD], keysD
    mov qword[copyS], modinvR
    call copyvector
    
    ; Opens keyDfile
    mov rdi, keyDfile
    mov rsi, 64 + 1     ;O_CREAT + O_WRONLY
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [fd1], rax      ; guarda el fd
    
    ; Writes to keyNfile
    mov rdi, [fd1]
    mov rsi, keysD
    mov rdx, 32
    mov rax, 1
    syscall
    
    mov rdi, [fd1]
    mov rax, 3         ;sys_close
    syscall

    pop r12
    pop r10
    ret
    