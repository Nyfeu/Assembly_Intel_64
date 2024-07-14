global _start

section .data

  string_demo: db "Hello, World!", 0
  new_line: db 10

section .text

  _start:
    
    mov rdi, string_demo
    call print_string
    call print_newline

    mov rdi, string_demo
    call string_length

    mov rdi, rax 
    call exit
  
  string_length:
    
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

  print_newline:
    
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

  exit:                           ; Aceita um exit_code (rdi)

    mov rax, 60
    syscall
