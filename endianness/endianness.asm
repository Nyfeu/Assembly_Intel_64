global _start

section .data

  newline_char: db 10          ; End of Line ('\n')
  codes: db "0123456789ABCDEF" ; Caracteres hexadecimais

  demo1: dq 0x1122334455667788
  demo2: db 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88 

section .text

  _start:

    mov rdi, [demo1]           ; Carrega o endereço de 'demo1' 
    call print_hex             ; Escreve o valor hexa de 64 bits
    call print_newline         ; Escreve o caractere especial '\n'

    mov rdi, [demo2]
    call print_hex
    call print_newline

    call _exit                 ; Finaliza a execução do programa

  print_newline:               ; Função para escreve nova linha

    mov rax, 1                 ; Chamada de sistema: write
    mov rdi, 1                 ; Descritor de arquivo: stdout 
    mov rsi, newline_char      ; Caractere '\n' (buffer) 
    mov rdx, 1                 ; Quantidade de bytes
    syscall
    ret                        ; Retorna ao endereço armazenado na pilha
                               ; ou seja, do registrador 'rip'

  print_hex:                   ; Função que recebe uma cadeia de bytes em 'rdi'

    mov rax, rdi               ; Salva o argumento em 'rax'
    mov rdi, 1                 ; Define o descritor de arquivo: stdout
    mov rdx, 1                 ; Define a quantidade de bytes escritos
    mov rcx, 64                ; Contador para controle do loop (64 bits - reg)

  .iterate:

    push rax                   ; Salva o valor inicial de rax (argumento recebido)
    sub rcx, 4                 ; Decrementa a variável de controle em 4 unidades
    shr rax, cl                ; Usa os 8 LSBs de rcx para aplicar um deslocamento
    and rax, 0xf               ; Aplica uma máscara, identificanado os 4 LSBs (char)
    lea rsi, [codes + rax]     ; Identifica o símbolo hexadecimal contido em 'codes'
    
    mov rax, 1                 ; Chamada de sistema: write
    push rcx                   ; Salva o valor de rcx, que será sobrescrito pela syscall
    syscall                    ; Executa a chamada de sistema

    pop rcx                    ; Recupera o valor de rcx
    pop rax                    ; Recupera o valor original (recebido) de rax

    test rcx, rcx              ; Testa a condição de parada (rcx == 0)
    jnz .iterate               ; Caso não satisfaça a condição, continua o loop

    ret                        ; Retorna para o endereço armazenado na pilha
  
  _exit:

    mov rax, 60
    xor rdi, rdi
    syscall                    ; Syscall: exit -> code: 0 (sucesso)
