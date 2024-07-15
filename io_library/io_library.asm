global _start

section .bss

  in_buffer: resb 20              ; Reserva 20 bytes para o buffer de entrada
  out_buffer: resb 15             ; Reserva 15 bytes para o buffer de saída 

section .data

  str_read:   db "Digite a string a ser copiada: ", 0
  str_error:  db "Não foi possível alocar a string no destino!", 0
  str_result: db "A string copiada foi: ", 0

  new_line: db 10
  null_char: db 0
  negative_sign: db '-'
  
section .text

  _start:                         ; Código executado para testes
    
    mov rdi, str_read
    call print_string
    
    mov rdi, in_buffer
    mov rsi, 20                   ; Tamanho do buffer: 20 bytes (chars)
    call read_word

    mov rdi, in_buffer
    mov rsi, out_buffer
    mov rdx, 15
    call string_copy

    test rax, rax
    jnz .print_result
    jmp .print_error

    .print_result:

      mov rdi, str_result
      call print_string

      mov rdi, rax
      call print_string
      call print_newline 
      jmp .end

    .print_error:

      mov rdi, str_error
      call print_string
      call print_newline

    .end:
      
      mov rdi, 0                    ; Passa o resultado como exit_code
      call exit
  
  read_char:                      ; Recebe arg: buffer char (rdi)
    
    ; Guardando os valores dos registradores

    push rdx
    push rdi
    push rsi
    push rcx

    ; Executando a chamada de sistema

    mov rsi, rdi
    mov rax, 0
    mov rdi, 0
    mov rdx, 1
    syscall                       ; Executa syscall: read

    ; Verificando o final de stream de dados

    xor rax, rax
    cmp byte[rsi], 10
    je .end

    mov rax, 1

    .end:
      
      ; Recuperando os valores dos registradores
      
      pop rcx
      pop rsi
      pop rdi
      pop rdx
      
      ; Retornando para o endereço salvo na STACK
      
      ret

  read_word:                    ; Arg1: buffer (rdi)
                                ; Arg2: total_size (rsi) 
    push rdi
    push rsi
    push rbx
    
    xor rbx, rbx 

    .iterate:

      push rdi
      lea rdi, [rdi + rbx]
      call read_char
      pop rdi
      test rax, rax
      jz .end_of_stream
      cmp rbx, rsi
      je .end_of_buffer
      inc rbx
      jmp .iterate

    .end_of_stream:
      
      mov rax, 1
      jmp .end

    .end_of_buffer:

      xor rax, rax

    .cleanup_stdin:

      ; Continuar lendo até encontrar um '\n' para limpar o buffer de stdin
      
      push rdi
      lea rdi, [rdi + rbx]
      call read_char
      pop rdi

      test rax, rax
      jz .end
      cmp al, 10
      jne .cleanup_stdin

    .end:

      mov byte[rdi + rbx], 0

      pop rbx
      pop rsi
      pop rdi

      ret

  parse_uint:                     ; Recebe addr do buffer para a string (rdi)
    
    ; Salvar os valores dos registradores

    push rbx
    push rcx
    
    ; Inicializar rax e rdx

    xor rax, rax                ; rax = 0 (resultado final)
    xor rdx, rdx                ; rdx = 0 (contador de caracteres)
    xor rcx, rcx                ; rcx = 0 (caractere lido)
    
    .iterate:
      
      mov cl, byte [rdi + rdx]  ; Carregar caractere atual
      cmp cl, byte [null_char]  ; Verificar se é o caractere nulo ('\0')
      je .end                   ; Se for, terminar o parsing
      cmp cl, '0'               ; Verificar se é menor que '0'
      jl .end                   ; Se menor, finalizar
      cmp cl, '9'               ; Verificar se é maior que '9'
      jg .end                   ; Se maior, finalizar
      
      ; Caso seja um dígito válido, proceder com a conversão:

      sub cl, '0'               ; Converter char para dígito (0-9)
      
      ; Multiplicar rax por 10

      mov rbx, 10               ; rbx = 10
      imul rax, rbx             ; rax = rax * 10
      
      ; Adicionar o novo dígito

      add rax, rcx              ; rax = rax + cl
      
      ; Incrementar o contador de caracteres

      inc rdx

      ; Repetir

      jmp .iterate
      
    .end:
      
      ; Restaurar os valores dos registradores

      pop rcx
      pop rbx
      
      ; Retornar para o endereço salvo

      ret

  parse_int:                      ; Recebe addr do buffer para a string (rdi)
    
    mov cl, byte [rdi]            ; Carrega o primeiro caractere
    cmp cl, '-'                   ; Verificar se é o caractere nulo ('-')
    je .negative

    .positive:

      call parse_uint
      jmp .end

    .negative:

      lea rdi, [rdi + 1]
      call parse_uint
      neg rax
      inc rdx

    .end:

      ret

  string_length:                  ; Aceita arg: buffer string (rdi)
     
    ; Guardando os valores dos registradores

    push rax
    push rdi
    
    ; Zerando o valor do contador (rax)

    xor rax, rax

    .iterate:
      
      cmp byte[rdi + rax], 0
      je .end
      inc rax
      jmp .iterate

    .end:
       
      ; Recuperando os valores dos registradores

      pop rdi
      pop rax

      ; Retornando para o endereço na STACK

      ret

  print_char:                     ; Recebe como arg: buffer char (rdi)

    ; Guardando os valores dos registradores

    push rax
    push rsi
    push rdx
    push rcx
    push rdi

    ; Executando a chamada de sistema

    mov rsi, rdi
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall                       ; Syscall: write

    ; Recuperando os valores dos registradores

    pop rdi
    pop rcx
    pop rdx
    pop rsi
    pop rax

    ; Retornando para o endereço na STACK  

    ret

  print_newline:                  ; Escreve o char: '\n'
                                  ; Não aceita argumentos

    ; Guardando os valores dos registradores

    push rax
    push rsi
    push rdx
    push rcx
    push rdi

    ; Executando a chamada de sistema

    mov rax, 1
    mov rdi, 1
    mov rsi, new_line
    mov rdx, 1
    syscall                       ; Syscall: write

    ; Recuperando os valores dos registradores

    pop rdi
    pop rcx
    pop rdx
    pop rsi
    pop rax

    ; Retornando para o endereço na STACK  

    ret

  print_string:

    ; Guardando os valores dos registradores

    push rax
    push rcx
    push rdi

    ; Iniciando o procedimento
    
    mov rax, rdi                  ; Passa o arg para rax (buffer string)
    xor rcx, rcx                  ; Zera o registrador rcx

    .iterate:                     ; Estrutura de repetição para write char
      
      cmp byte[rax + rcx], 0      ; Verifica se é o char final ('\0')
      je .end                     ; Caso seja, retorna

      lea rsi, [rax + rcx]

      mov rdi, rsi
      call print_char

      inc rcx                     ; Caso contrário, incrementa rcx
      jmp .iterate                ; e começa a próxima iteração

    .end:

      ; Recuperando os valores dos registradores

      pop rdi
      pop rcx
      pop rax

      ; Retornando para o endereço na STACK

      ret

  string_equals:                  ; Arg1: buffer1 (rdi)
                                  ; Arg2: buffer2 (rsi)
    push rcx
    push rbx

    xor rcx, rcx

    .iterate:
      
      mov al, byte[rdi + rcx]
      mov bl, byte[rsi + rcx]

      cmp al, bl                  ; Compara os caracteres
      jne .not_eq
      
      cmp al, 0
      je .eq
      
      inc rcx
      jmp .iterate

    .eq:

      mov rax, 1
      jmp .end

    .not_eq:
      
      xor rax, rax

    .end:
      
      pop rbx
      pop rcx
      
      ret   

  string_copy:                    ; Arg1: string (rdi) addr
                                  ; Arg2: buffer (rsi) addr
                                  ; Arg3: tamanho do buffer (rdx)
    push rbx
    
    xor rax, rax
    xor rbx, rbx   


    .loop:
      
      mov al, byte[rdi + rbx]
      mov byte[rsi + rbx], al
      
      cmp al, 0
      je .success
      
      inc rbx
      
      cmp rbx, rdx
      jge .overflow
      jmp .loop

    .overflow:
      
      xor rax, rax
      jmp .end
    
    .success:
      
      mov rax, rsi

    .end:
      
      pop rbx
      
      ret

  print_uint:                     ; Recebe arg: rdi (inteiro 64 bits)

    ; Salva os valores dos registradores

    push rax
    push rbx
    push rcx
    push rdx
    push rdi

    ; Guarda arg em rax (rdi)

    mov rax, rdi
    
    ; Alocando espaço na pilha (STACK)

    sub rsp, 21                   ; Aloca 21 bytes na pilha (20 digitos + '\0')
                                  ; MAX_UINT = 18.446.744.073.709.551.615
    
    ; Inicializar o buffer e índice

    lea rbx, [rsp + 20]           ; rbx aponta para o final do buffer
    mov byte[rbx], 0              ; Adiciona '\0' (nulo) ao final da cadeia

    .convert:
      
      xor rdx, rdx                ; Zera os MSBytes do operando
                                  ; Divide rdx:rax por s (div s)
      
      mov rcx, 10                 ; Define o divisor rcx = 10
      div rcx                     ; (Q) rax = rax / 10, (R) rdx = rax % 10
        
      add dl, '0'                 ; Soma aos LSBs de rdx '0',
                                  ; ou seja, converte para char (ASCII)
        
      dec rbx                     ; Move o ponteiro do buffer para a esquerda

      mov byte[rbx], dl           ; Armazena o dígito no buffer
        
      test rax, rax               ; Verifica se rax é zero
      jnz .convert                
      
    .print:
      
      ; Configurando os parâmetros da syscall write

      lea rdi, [rbx]
      call print_string

      ; Desalocando o buffer da pilha (STACK)

      add rsp, 21
     
    .end:

      ; Recuperando valores iniciais dos registradores

      pop rdi
      pop rdx
      pop rcx
      pop rbx
      pop rax

      ; Retornando para o endereço na STACK

      ret

  print_int:                      ; Recebe arg: rdi (inteiro 64 bits) 

    ; Salva os valores dos registradores

    push rax
    push rdi

    ; Guarda arg em rax

    mov rax, rdi                  
    
    ; Verifica se o número é negativo

    test rax, rax
    jns .positive
    
    .negative:

      neg rax                     ; Aplicando 2's complement

      mov rdi, negative_sign
      call print_char

    .positive:
      
      mov rdi, rax
      call print_uint

    .end:

      ; Recuperando valores iniciais dos registradores

      pop rdi
      pop rax

      ; Retornando para o endereço na STACK

      ret
    
  exit:                           ; Aceita um exit_code (rdi)

    mov rax, 60
    syscall
