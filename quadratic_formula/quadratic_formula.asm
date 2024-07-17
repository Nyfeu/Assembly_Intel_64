
; Sinalizando o ponto de entrada do programa

global _start

; Importando funções de outros arquivos

extern sqrt
extern print_string
extern print_newline
extern print_int
extern read_word
extern parse_int
extern exit

section .bss

    input_buffer: resb 21 ; 21 bytes (20 dígitos + null_terminator)

section .data

    a_str: db "Digite o valor de coef. a: ", 0
    b_str: db "Digite o valor do coef. b: ", 0
    c_str: db "Digite o valor do coef. c: ", 0

    error_str: db "Houve um erro durante a execução do programa!", 0
    no_real_roots_str: db "Não existem raízes reais!", 0

    first_str: db "Primeira raiz (x_1) é: ", 0
    second_str: db "Segunda raiz (x_2) é: ", 0

section .text

    _start:

        ; Leitura dos coeficientes
        call read_coefs

        ; Cálculo do discriminante
        call calculate_discriminant

        ; Verifica se o discriminante é negativo
        test r8, r8
        js no_real_roots

        ; Cálculo das raízes
        call calculate_roots

        jmp _end

    read_coefs:

    ; Função para leitura dos coeficientes

        ; Leitura do coeficiente 'a'
        mov rdi, a_str
        call input
        mov r12, rax         ; Salva 'a' em r12

        ; Verifica se 'a' é zero
        test r12, r12
        jz no_real_roots

        ; Leitura do coeficiente 'b'
        mov rdi, b_str
        call input
        mov r13, rax         ; Salva 'b' em r13

        ; Leitura do coeficiente 'c'
        mov rdi, c_str
        call input
        mov r14, rax         ; Salva 'c' em r14

        ret

    calculate_discriminant:

    ; Função para cálculo do discriminante

        xor rdx, rdx        ; Limpando rdx

        mov rax, r13
        imul rax, rax
        mov r8, rax         ; r8 = b^2

        xor rdx, rdx        ; Limpando rdx
        mov rax, r12
        imul rax, r14
        mov r9, rax         ; r9 = a * c

        sal r9, 2           ; 4 * a * c

        sub r8, r9          ; r8 = b^2 - 4 * a * c

        ret

    calculate_roots:

    ; Função para cálculo das raízes

        mov rdi, r8
        call sqrt

        mov r8, rax         ; r8 = sqrt(discriminant)

        mov r15, r13
        neg r15             ; r15 = -b

        ; Cálculo da primeira raiz

        mov rdi, r15
        sub rdi, r8         ; r9 = -b - sqrt(discriminant)
        mov r9, rdi

        mov rax, r9
        cqo                 ; Estende o sinal de r15 para rdx

        idiv r12            ; rax = r15 / a

        mov r9, rax

        sar r9, 1           ; r9 = r9 / 2 (preserva o sinal)

        mov rdi, first_str
        call print_string

        mov rdi, r9
        call print_int
        call print_newline

        test r8, r8
        jz _end

        ; Cálculo da segunda raiz

        add r15, r8         ; r15 = -b - sqrt(discriminant)

        mov rax, r15
        cqo                 ; Estende o sinal de r15 para rdx
        idiv r12            ; rax = r15 / a
        mov r10, rax

        sar r10, 1           ; r9 = r9 / 2 (preserva o sinal)

        mov rdi, second_str
        call print_string

        mov rdi, r10
        call print_int
        call print_newline

        ret

    no_real_roots:

        ; Função para tratar caso sem raízes reais

        mov rdi, no_real_roots_str
        call print_string
        call print_newline
        jmp _end

    _end:

        mov rdi, 0
        call exit

    input:

        ; Função de entrada e conversão

        ; Recebe:  string -> rdi
        ; Devolve: value  -> rax

        call print_string

        mov rdi, input_buffer
        mov rsi, 21
        call read_word

        cmp rax, 0
        je .error

        mov rdi, input_buffer
        call parse_int

        ret

        .error:

        ; Função de tratamento de erro na leitura

            mov rdi, error_str
            call print_string
            call print_newline

            mov rdi, 1
            call exit


