; -------------------------------------------------------------------------------------------------
;
;  > Filename: io_library.asm
;
;  > Purpose: código para manipulação de entradas e saídas
;             de números e strings.
;
;  > Author: André Solano Ferreira Rodrigues Maiolini
;  > Date: 15/07/2024
;
; -------------------------------------------------------------------------------------------------

global _start                     ; Definindo o ponto de entrada do programa

; -------------------------------------------------------------------------------------------------

section .bss                      ; Seção para reserva de dados não inicializados na memória

  in_buffer: resb 20              ; Reserva 20 bytes para o buffer de entrada
  out_buffer: resb 15             ; Reserva 15 bytes para o buffer de saída

; -------------------------------------------------------------------------------------------------

section .data                     ; Dados inicializados utilizados no código

  str_read:   db "Digite a string a ser copiada: ", 0
  str_error:  db "Não foi possível alocar a string no destino!", 0
  str_result: db "A string copiada foi: ", 0

  new_line: db 10
  null_char: db 0
  negative_sign: db '-'

; -------------------------------------------------------------------------------------------------

section .text

  _start:

    ;
    ;  _start -> Ponto de entrada do programa
    ;
    ;  Chama funções para ler string, copiar string e exibir
    ;  resultado ou mensagem de erro.
    ;

    mov rdi, str_read             ; Passa o buffer da string
    call print_string             ; Imprime a string

    mov rdi, in_buffer            ; Passa o buffer para entrada de strings
    mov rsi, 20                   ; Tamanho do buffer: 20 bytes (chars)
    call read_word                ; Chama a função para leitura de strings

    mov rdi, in_buffer            ; Passa o buffer source (fonte)
    mov rsi, out_buffer           ; Passa o buffer target (destino)
    mov rdx, 15                   ; Tamanho do buffer target: 15 bytes (chars)
    call string_copy              ; Chama a função para cópia da string

    test rax, rax                 ; Verifica se foi possível realizar a cópia
    jnz .print_result             ; Caso tenha sido possível, imprime o resultado
    jmp .print_error              ; Caso contrário, imprime a mensagem de erro

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

    .end:                         ; Trecho responsável por finalizar o programa

      mov rdi, 0                  ; Passa o resultado como exit_code
      call exit                   ; Chama a função que fará a syscall: exit

; -------------------------------------------------------------------------------------------------

  read_char:

    ;
    ;  read_char -> lê um único caractere do stdin
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço para armazenar o caractere lido
    ;
    ;  > Saída:
    ;     - rax -> 1 se um caractere foi lido, 0 se fim da linha
    ;

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
    syscall

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

; -------------------------------------------------------------------------------------------------

  read_word:

    ;
    ;  read_word -> lê uma palavra (string) do stdin
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço do buffer de entrada
    ;     - rsi -> Tamanho máximo do buffer
    ;
    ;  > Saída:
    ;     - rax -> 1 se sucesso, 0 se buffer cheio
    ;

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

; -------------------------------------------------------------------------------------------------

  parse_uint:

    ;
    ;  parse_uint > converte uma string de dígitos em um inteiro sem sinal
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da string (buffer)
    ;
    ;  > Saída:
    ;     - rax -> Valor inteiro (unsigned) resultante
    ;

    ; Salvar os valores dos registradores

    push rbx
    push rcx

    ; Inicializar rax e rdx

    xor rax, rax                  ; rax = 0 (resultado final)
    xor rdx, rdx                  ; rdx = 0 (contador de caracteres)
    xor rcx, rcx                  ; rcx = 0 (caractere lido)

    .iterate:

      mov cl, byte [rdi + rdx]    ; Carregar caractere atual
      cmp cl, byte [null_char]    ; Verificar se é o caractere nulo ('\0')
      je .end                     ; Se for, terminar o parsing
      cmp cl, '0'                 ; Verificar se é menor que '0'
      jl .end                     ; Se menor, finalizar
      cmp cl, '9'                 ; Verificar se é maior que '9'
      jg .end                     ; Se maior, finalizar

      ; Caso seja um dígito válido, proceder com a conversão:

      sub cl, '0'                 ; Converter char para dígito (0-9)

      ; Multiplicar rax por 10

      mov rbx, 10                 ; rbx = 10
      imul rax, rbx               ; rax = rax * 10

      ; Adicionar o novo dígito

      add rax, rcx                ; rax = rax + cl

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

; -------------------------------------------------------------------------------------------------

  parse_int:

    ;
    ;  parse_int -> converte uma string de dígitos em um inteiro com sinal
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da string (buffer)
    ;
    ;  > Saída:
    ;     - rax -> Valor inteiro resultante
    ;

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

; -------------------------------------------------------------------------------------------------

  string_length:

    ;
    ;  string_length -> calcula o comprimento de uma string
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da string (buffer)
    ;  > Saída:
    ;     - rax -> Comprimento da string
    ;

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

; -------------------------------------------------------------------------------------------------

  print_char:

    ;
    ;  print_char -> imprime um único caractere no stdout
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço do caractere a ser impresso (buffer)
    ;

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

; -------------------------------------------------------------------------------------------------

  print_newline:

    ;
    ;  print_newline -> imprime uma nova linha ('\n' - end of line)
    ;
    ;  > Não recebe nem emite nenhuma entrada ou saída
    ;

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

; -------------------------------------------------------------------------------------------------

  print_string:

    ;
    ;  print_string -> imprime uma string no stdout
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da string (buffer)
    ;

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

; -------------------------------------------------------------------------------------------------

  string_equals:

    ;
    ;  string_equals -> compara duas strings
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da primeira string
    ;     - rsi -> Endereço da segunda string
    ;
    ;  > Saída:
    ;     - rax -> 1 se iguais, 0 se diferentes
    ;

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

; -------------------------------------------------------------------------------------------------

  string_copy:

    ;
    ;  string_copy -> copia uma string para um buffer de saída
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada
    ;     - rdi -> endereço do buffer da string (source)
    ;     - rsi -> endereço do buffer de saída (target)
    ;     - rdx -> tamanho do buffer de saída (bytes)
    ;
    ;  > Saída
    ;     - rax -> se possível a alocação retorna o endereço do buffer,
    ;              caso contrário retorna o valor nulo (0)
    ;

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

; -------------------------------------------------------------------------------------------------

  print_uint:

    ;
    ;  print_uint -> imprime um valor decimal inteiro não sinalizado (8 bytes)
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> valor do inteiro não sinalizado de 8 bytes
    ;

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

; -------------------------------------------------------------------------------------------------

  print_int:

    ;
    ;  print_int -> imprime um valor decimal inteiro sinalizado (8 bytes)
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> valor do inteiro sinalizado de 8 bytes
    ;

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

; -------------------------------------------------------------------------------------------------

  exit:

    ;
    ;  exit -> executa a syscall: exit, para finalizar a execução do programa
    ;
    ;  Registradores (callee-saved):
    ;
    ;  > Entrada:
    ;     - rdi -> aceita um exit_code inteiro
    ;

    mov rax, 60
    syscall

; -------------------------------------------------------------------------------------------------
