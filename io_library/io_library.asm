global _start

section .data

  string_demo: db "Hello, World!", 0

  new_line: db 10 

section .text

  _start:                         ; Código executado para testes
    
    mov rdi, string_demo
    call print_string
    call print_newline

    mov rdi, 0xffffffffffffffff   ; Carrega com o valor máximo de uint
    call print_uint
    call print_newline

    mov rdi, string_demo          ; Conta os caracteres de string_demo
    call string_length

    mov rdi, rax                  ; Passa o resultado como exit_code
    call exit
  
  string_length:                  ; Aceita arg: buffer string (rdi)
    
    xor rax, rax

    .iterate:

      cmp byte[rdi + rax], 0
      je .end
      inc rax
      jmp .iterate

    .end:

      ret

  print_char:                     ; Recebe como arg: buffer char (rdi)

    mov rsi, rdi
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall
    ret

  print_newline:                  ; Escreve o char: '\n'
                                  ; Não aceita argumentos
    mov rax, 1
    mov rdi, 1
    mov rsi, new_line
    mov rdx, 1
    syscall
    ret

  print_string:
    
    mov rax, rdi                  ; Passa o arg para rax (buffer string)
    xor rcx, rcx                  ; Zera o registrador rcx

    .iterate:                     ; Estrutura de repetição para write char
      
      cmp byte[rax + rcx], 0      ; Verifica se é o char final ('\0')
      je .end                     ; Caso seja, retorna

      lea rsi, [rax + rcx]

      push rcx
      push rax

      mov rdi, rsi
      call print_char
      
      pop rax
      pop rcx

      inc rcx                     ; Caso contrário, incrementa rcx
      jmp .iterate                ; e começa a próxima iteração

    .end:

      ret

  print_uint:                     ; Recebe arg: rdi (inteiro 64 bits)

    mov rax, rdi                  ; Guarda arg em rax

    ; Salva os valores dos registradores

    push rbx
    push rcx
    push rdx
    push rsi
    
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
      
      ; Recuperando valores iniciais dos registradores

      pop rbx
      pop rcx
      pop rdx
      pop rsi

      ret

  exit:                           ; Aceita um exit_code (rdi)

    mov rax, 60
    syscall
