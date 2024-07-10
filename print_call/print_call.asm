global _start

section .data

  newline_char: db 10             ; End of Line ('\n')
  codes: db "0123456789ABCDEF"    ; Caracteres hexadecimais

section .text

  print_newline:                  ; Função para escreve nova linha

    mov rax, 1                    ; Chamada de sistema: write
    mov rdi, 1                    ; Descritor de arquivo: stdout 
    mov rsi, newline_char         ; Caractere '\n' (buffer) 
    mov rdx, 1                    ; Quantidade de bytes
    syscall
    ret                           ; Retorna ao endereço armazenado na pilha
                                  ; ou seja, do registrador 'rip'

  print_hex:                      ; Função que recebe uma cadeia de bytes em 'rdi'

    mov rax, rdi                  ; Salva o argumento em 'rax'
    mov rdi, 1                    ; Define o descritor de arquivo: stdout
    mov rdx, 1                    ; Define a quantidade de bytes escritos
    mov rcx, 64                   ; Contador para controle do loop (64 bits - reg)

  .iterate:

    push rax                      ; Salva o valor inicial de rax (ou seja, o argumento recebido)
    sub rcx, 4                    ; Decrementa a variável de controle em 4 unidades
    shr rax, cl                   ; Usa os 8 LSBs de rcx para aplicar um deslocamento
    and rax, 0xf                  ; Aplica uma máscara para identificar o caractere contido nos 4 LSBs
    lea rsi, [codes + rax]        ; Identifica o símbolo hexadecimal contido em 'codes'
    
    mov rax, 1                    ; Chamada de sistema: write
    push rcx                      ; Salva o valor de rcx, pois, será sobrescrito pela Chamada
    syscall                       ; Executa a chamada de sistema

    pop rcx                       ; Recupera o valor de rcx
    pop rax                       ; Recupera o valor original (recebido) de rax

    test rcx, rcx                 ; Testa a condição de parada (rcx == 0)
    jnz .iterate                  ; Caso não satisfaça a condição, continua o loop

    ret                           ; Retorna para o endereço armazenado na pilha - registrador 'rip'

  _start:

    mov rdi, 0x8899AABBCCDDEEFF
    
    call print_hex                ; Armazena na pilha o valor de 'rip' e pula incondicionalmente
                                  ; Passa como argumento 'rdi' (primeiro argumento)

    call print_newline            ; Rotina que não recebe argumentos

    mov rax, 60                   ; Chamada de sistema: exit
    xor rdi, rdi                  ; Atribui o código de saída zero (0)
    syscall

