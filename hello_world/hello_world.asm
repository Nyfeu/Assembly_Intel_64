;  **********  Primeiro código em Assembly - Hello, World!  ************************  ;


	;  Este é o meu primeiro código em Assembly - Intel 64 - x86_64 ou AMD64


;  **********  Global  *************************************************************  ;


	;  O rótulo que demarca a primeira instrução deve ser declarado
	;  como: 'global'.


	global _start


;  **********  Seção - data  ********************************************************  ;


	;  Essa seção é responsável pelas variáveis globais (disponíveis
	;  a qualquer momento da execução do programa).


	section .data
	message: db 'Hello, World!', 10   ;  Mensagem a ser escrita - através da diretiva 'db'
						                        ;  O byte igual a '10' é uma convenção
                                    ;  para uma nova linha ('\n' em C).

;  **********  Seção - text  *******************************************************  ;


	;  Essa seção é responsável pelas instruções


	section .text
	_start:                 ;  Para nos livrarmos dos endereços numéricos, usamos rótulos
						              ;  A instrução 'mov' serve para dar um valor ao registrador
						              ;  ou para a memória.

	  	mov  rax, 1			    ;  O número da chamada de sistema (write)
		  mov  rdi, 1			    ;  Argumento (#1) em rdi: onde escrever -> stdout
		  mov  rsi, message		;  Argumento (#2) em rsi: onde começa a string
		  mov  rdx, 14			  ;  Argumento (#3) em rdx: quantos bytes devem ser escritos
		  syscall				      ;  Executa a chamada de sistema


		  mov  rax, 60        ;  O número da chamada de sistema (exit).
		  xor  rdi, rdi			  ;  Zera o registrador rdi - que será o responsável
		  syscall				      ;  por dar o código de retorno do programa.
			  			            ;  Executa a chamada de sistema
				  		            ;  Então equivale à 'return 0' da linguagem C.
