global _start

section .data

  string_demo: db "Hello, World!", 0

section .text

  _start:

    mov rdi, string_demo          ; Passa o addr do buffer como arg
    call strlen                   ; Chama a função strlen.
    
    mov rdi, rax                  ; Fará com que o exit_code seja
                                  ; o resultado de strlen.
    jmp exit                      ; Executará a syscall exit.

  strlen:                         ; Strlen recebe um buffer como arg (rdi)
    
    xor rax, rax                  ; Zera o registrador rax

    .iterate:                     ; Estrutura de repetição para inc rax
      
      cmp byte[rdi + rax], 0      ; Verifica se é o char final ('\0')
      je .end                     ; Caso seja, retorna
      inc rax                     ; Caso contrário, incrementa rax
      jmp .iterate                ; e começa a próxima iteração

    .end:

      ret

  exit:

    mov rax, 60
    syscall                       ; Para verificar o resultado, utilizar
                                  ; echo $?, pois é passado como exit_code
