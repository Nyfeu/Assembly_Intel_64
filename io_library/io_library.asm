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
;
;  > Convenção para chamadas utilizada (x86_64 System V Application Binary Interface):
;
;      +--------------+-------------------------------------------+
;      | Caller-saved | rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11 |
;      +--------------+-------------------------------------------+
;      | Callee-saved | rsp, rbx, rbp, r12, r13, r14, r15         |
;      +--------------+-------------------------------------------+
;
;  > São utilizados os primeiros 6 registradores para argumentos
;  > E o registrador rax para retorno de valores em geral
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

      mov rdi, out_buffer
      call parse_int

      mov rdi, rax
      call print_int
      call print_newline
      jmp .end

    .print_error:

      mov rdi, str_error
      call print_string
      call print_newline

    .end:                         ; Trecho responsável por finalizar o programa

      mov rdi, in_buffer
      mov rsi, out_buffer
      call string_equals

      mov rdi, rax                ; Passa o resultado como exit_code
      call exit                   ; Chama a função que fará a syscall: exit

; -------------------------------------------------------------------------------------------------

  read_char:

    ;
    ;  read_char -> lê um único caractere do stdin
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço para armazenar o caractere lido
    ;
    ;  > Saída:
    ;     - rax -> 1 se um caractere foi lido, 0 se fim da linha
    ;
    ;  > Utilizados: rax, rdi, rsi, rdx e rcx
    ;

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

      ; Retornando para o endereço salvo na STACK

      ret

; -------------------------------------------------------------------------------------------------

  read_word:

    ;
    ;  read_word -> lê uma palavra (string) do stdin
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço do buffer de entrada
    ;     - rsi -> Tamanho máximo do buffer
    ;
    ;  > Saída:
    ;     - rax -> 1 se sucesso, 0 se buffer cheio
    ;
    ;  > Utilizados: rax,, rdi, rsi, rcx
    ;

    ; Inicializa os registradores

    xor rcx, rcx

    .iterate:

      push rdi
      push rcx
      lea rdi, [rdi + rcx]
      call read_char
      pop rcx
      pop rdi

      test rax, rax
      jz .end_of_stream
      cmp rcx, rsi
      je .end_of_buffer
      inc rcx
      jmp .iterate

    .end_of_stream:

      mov rax, 1
      jmp .end

    .end_of_buffer:

      xor rax, rax

    .cleanup_stdin:

      ; Continuar lendo até encontrar um '\n' para limpar o buffer de stdin

      push rdi
      push rcx
      lea rdi, [rdi + rcx]
      call read_char
      pop rcx
      pop rdi

      test rax, rax
      jz .end
      cmp al, 10
      jne .cleanup_stdin

    .end:

      mov byte[rdi + rcx], 0

      ret

; -------------------------------------------------------------------------------------------------

  parse_uint:

    ;
    ;  parse_uint > converte uma string de dígitos em um inteiro sem sinal
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da string (buffer)
    ;
    ;  > Saída:
    ;     - rax -> Valor inteiro (unsigned) resultante
    ;
    ;  > Utilizados: rax, rsi, rdi, rdx e rcx
    ;

    ; Inicializar rax, rdx e rcx

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

      mov rsi, 10                 ; rdi = 10
      imul rax, rsi               ; rax = rax * 10

      ; Adicionar o novo dígito

      add rax, rcx                ; rax = rax + cl

      ; Incrementar o contador de caracteres

      inc rdx

      ; Repetir

      jmp .iterate

    .end:

      ; Retornar para o endereço salvo

      ret

; -------------------------------------------------------------------------------------------------

  parse_int:

    ;
    ;  parse_int -> converte uma string de dígitos em um inteiro com sinal
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da string (buffer)
    ;
    ;  > Saída:
    ;     - rax -> Valor inteiro resultante
    ;
    ;  > Utilizados: rax, rdi e rcx
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
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da string (buffer)
    ;
    ;  > Saída:
    ;     - rax -> Comprimento da string
    ;
    ;  > Utilizados: rax e rdi
    ;

    ; Zerando o valor do contador (rax)

    xor rax, rax

    .iterate:

      cmp byte[rdi + rax], 0
      je .end
      inc rax
      jmp .iterate

    .end:

      ; Retornando para o endereço na STACK

      ret

; -------------------------------------------------------------------------------------------------

  print_char:

    ;
    ;  print_char -> imprime um único caractere no stdout
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço do caractere a ser impresso (buffer)
    ;
    ;  > Utilizados: rax, rsi, rdx, rcx e rdi
    ;

    ; Executando a chamada de sistema

    mov rsi, rdi
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall                       ; Syscall: write

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
    ;  > Utilizados: rax, rcx, rdi e rsi
    ;

    ; Iniciando o procedimento

    mov rax, rdi                  ; Passa o arg para rax (buffer string)
    xor rcx, rcx                  ; Zera o registrador rcx

    .iterate:                     ; Estrutura de repetição para write char

      cmp byte[rax + rcx], 0      ; Verifica se é o char final ('\0')
      je .end                     ; Caso seja, retorna

      lea rsi, [rax + rcx]

      mov rdi, rsi

      push rax
      push rcx
      call print_char
      pop rax
      pop rcx

      inc rcx                     ; Caso contrário, incrementa rcx
      jmp .iterate                ; e começa a próxima iteração

    .end:

      ; Retornando para o endereço na STACK

      ret

; -------------------------------------------------------------------------------------------------

  string_equals:

    ;
    ;  string_equals -> compara duas strings
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> Endereço da primeira string
    ;     - rsi -> Endereço da segunda string
    ;
    ;  > Saída:
    ;     - rax -> 1 se iguais, 0 se diferentes
    ;
    ;  > Utilizados: rax, rdx e rcx
    ;


    xor rcx, rcx

    .iterate:

      mov al, byte[rdi + rcx]
      mov dl, byte[rsi + rcx]

      cmp al, dl                  ; Compara os caracteres
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

      ret

; -------------------------------------------------------------------------------------------------

  string_copy:

    ;
    ;  string_copy -> copia uma string para um buffer de saída
    ;
    ;  Registradores:
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
    ;  > Utilizados: rax e rcx
    ;

    xor rax, rax
    xor rcx, rcx

    .loop:

      mov al, byte[rdi + rcx]
      mov byte[rsi + rcx], al

      cmp al, 0
      je .success

      inc rcx

      cmp rcx, rdx
      jge .end
      jmp .loop

    .success:

      mov rax, rsi

    .end:

      ret

; -------------------------------------------------------------------------------------------------

  print_uint:

    ;
    ;  print_uint -> imprime um valor decimal inteiro não sinalizado (8 bytes)
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> valor do inteiro não sinalizado de 8 bytes
    ;
    ;  > Utilizados: rax, rdi, rdx, rsi e rcx
    ;

    ; Guarda arg em rax (rdi)

    mov rax, rdi

    ; Alocando espaço na pilha (STACK)

    sub rsp, 21                   ; Aloca 21 bytes na pilha (20 digitos + '\0')
                                  ; MAX_UINT = 18.446.744.073.709.551.615

    ; Inicializar o buffer e índice

    lea rsi, [rsp + 20]           ; rsi aponta para o final do buffer
    mov byte[rsi], 0              ; Adiciona '\0' (nulo) ao final da cadeia

    .convert:

      xor rdx, rdx                ; Zera os MSBytes do operando
                                  ; Divide rdx:rax por s (div s)

      mov rcx, 10                 ; Define o divisor rcx = 10
      div rcx                     ; (Q) rax = rax / 10, (R) rdx = rax % 10

      add dl, '0'                 ; Soma aos LSBs de rdx '0',
                                  ; ou seja, converte para char (ASCII)

      dec rsi                     ; Move o ponteiro do buffer para a esquerda

      mov byte[rsi], dl           ; Armazena o dígito no buffer

      test rax, rax               ; Verifica se rax é zero
      jnz .convert

    .print:

      ; Configurando os parâmetros da syscall write

      lea rdi, [rsi]
      call print_string

      ; Desalocando o buffer da pilha (STACK)

      add rsp, 21

    .end:

      ; Retornando para o endereço na STACK

      ret

; -------------------------------------------------------------------------------------------------

  print_int:

    ;
    ;  print_int -> imprime um valor decimal inteiro sinalizado (8 bytes)
    ;
    ;  Registradores:
    ;
    ;  > Entrada:
    ;     - rdi -> valor do inteiro sinalizado de 8 bytes
    ;
    ;  > Utilizados: rax, rdi, rsi, rdx e rcx
    ;

    ; Guarda arg em rax

    mov rax, rdi

    ; Verifica se o número é negativo

    test rax, rax
    jns .positive

    .negative:

      neg rax                     ; Aplicando 2's complement

      mov rdi, negative_sign

      push rax
      call print_char
      pop rax

    .positive:

      mov rdi, rax
      call print_uint

    .end:

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
