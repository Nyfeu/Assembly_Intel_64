global _start

section .bss

  in_buffer: resb 128             ; Reserva 128 bytes para o buffer de entrada

section .data

  string_demo: db "Hello, World!", 0

  new_line: db 10
  negative_sign: db '-'

section .text

  _start:                         ; Código executado para testes
    
    mov rdi, string_demo
    call print_string
    call print_newline

    mov rdi, 0xffffffffffffffff   ; Carrega com o valor máximo de uint
    call print_uint
    call print_newline

    mov rdi, 0x8000000000000000   ; Carrega com o valor máximo neg de int
    call print_int
    call print_newline

    mov rdi, 0x7fffffffffffffff   ; Carrega com o valor máximo positivo de int
    call print_int
    call print_newline

    mov rdi, in_buffer            ; Passa como arg o buffer de entrada 1 byte
    call read_char
    call print_char
    call print_newline

    call read_char                ; Para limpar o buffer de entrada (ENTER)

    mov rdi, string_demo          ; Conta os caracteres de string_demo
    call string_length

    mov rdi, rax                  ; Passa o resultado como exit_code
    call exit
  
  read_char:                      ; Recebe arg: buffer char (rdi)
    
    ; Guardando os valores dos registradores

    push rax
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

    ; Recuperando os valores dos registradores

    pop rcx
    pop rsi
    pop rdi
    pop rdx
    pop rax

    ; Retornando para o endereço salvo na STACK
    
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
