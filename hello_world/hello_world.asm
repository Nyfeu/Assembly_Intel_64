;  **********  Primeiro código em Assembly - Hello, World!  *************************************  ;


;  Este é o meu primeiro código em Assembly - Intel 64 - x86_64 ou AMD64


;  **********  Global  **************************************************************************  ;


;  O rótulo que demarca a primeira instrução deve ser declarado como: 'global'.
;  Isso faz com que o ponto de entrada seja identificado e, posteriormente, acessível ao linker.

global _start

;  **********  Seção - data  ********************************************************************  ;


;  Essa seção é responsável pelas variáveis globais (disponíveis a qualquer momento da execução
;  do programa).


section .data

    message: db 'Hello, World!', 10   ; String a ser escrita - através da diretiva 'db' (data byte),
                                      ; com nova linha ao final. O byte '10' é o caractere de
                                      ; nova linha pela tabela ASCII - '\n' (End of Line).
                                      ; A separação por vírgula garante que o caractere especial
                                      ; será alocado no endereço seguinte ao da cadeia de chars,
                                      ; facilitando o acesso através do buffer 'message'.

;  **********  Seção - text  ******************************i*************************************  ;


;  Essa seção é responsável pelas instruções do programa


section .text

    _start:                           ;  Para nos livrarmos dos endereços numéricos, usamos rótulos.
                                      ;  A instr. 'mov' serve para atribuir um valor ao registrador
                                      ;  ou para um endereço na memória.

        mov  rax, 1                   ;  O número da chamada de sistema (write)
        mov  rdi, 1                   ;  Argumento (#1) em rdi: onde escrever -> stdout
        mov  rsi, message             ;  Argumento (#2) em rsi: onde começa a string (buffer)
        mov  rdx, 14                  ;  Argumento (#3) em rdx: quantos bytes devem ser escritos
        syscall                       ;  Executa a chamada de sistema

        mov  rax, 60                  ;  O número da chamada de sistema (exit).
        xor  rdi, rdi                 ;  Zera o registrador rdi - que será o responsável
        syscall                       ;  pelo código de retorno do programa.
                                      ;  Executa a chamada de sistema de forma equivalente à
                                      ;  'return 0' da linguagem C.

;  **********************************************************************************************  ;
