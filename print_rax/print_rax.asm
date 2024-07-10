global _start

section .data

	codes: db '0123456789ABCDEF'        ; Caracteres ASCII utilizados para representação
                                            ; dos números em formato hexadecimal.
                                
  	EOL: db 10                          ; Caractere especial '\n' (End of Line).
	
section .text

	_start:
	
		mov rax, 0x8899AABBCCDDEEFF ; Número em formato hexadecimal.
		
		; Configurando argumentos para a syscall: write
		
		mov rdi, 1                  ; Define o descritor de arquivo: 'stdout'
		mov rdx, 1                  ; Número de bytes a serem escritos
		
		; Criando um contador de bits para o registrador:
		
		mov rcx, 64                 ; Quantidade total de bits em 'rax'.
		
		; Cada 4 bits devem ser exibidos como um dígido hexadecimal,
		; para isso, será utilizado um loop até o último caractere
		; ter sido escrito em 'stdout'.
		
	.loop:
	
		; Iniciando o ciclo de repetição que irá escrever cada dígito hexa.

		push rax                    ; Guardando o valor de rax na stack
		
    		sub rcx, 4                  ; Subtraí 4 de rcx - ou seja: um digito hexadecimal,
					    ; atuando como controle para o ciclo de repetição!

		shr rax, cl                 ; cl é a menor parte de rcx (8 bits) - LSBs - sendo
		                            ; suficiente para representação de um 'char'.
		
    		; A instrução 'shr' (shift right) desloca os bits para a direita. Usar 'sar'
    		; (shift arithmetic right) teria o mesmo efeito - neste caso - pois não estamos 
    		; lidando com números sinalizados.

		and rax, 0xf                ; Aplica o operador AND (bitwise) com 0b1111
		
		; Isso resulta na aplicação de uma máscara para os 4 LSBs de rax.
		; Ou seja, isola o caractere anteriormente deslocado pelo 'shr'.
		
		lea rsi, [codes + rax]      ; Load Effective Address (lea), carrega o caractere
		                            ; referenciado por [codes + rax] em rsi.
		                            ; Por exemplo: [codes + 10] => rsi = 'A'.
		
		; A próxima etapa é imprimir (escrever) o caractere, usando a syscall write.
		
		mov rax, 1                  ; Atribui o código da syscall write em rax
		
		push rcx                    ; Guarda o valor de rcx antes da chamada, pois,
					    ; rcx será sobrescrito pela chamada.
		
		syscall                     ; Os argumentos já foram inicializados anteriormente,
		                            ; então, é escrito o dígito hexa na 'stdout'.
		
		; Agora, deve-se recuperar os valores para que seja iterado o próximo caractere
		
		pop rcx                     ; Recupera o valor da contagem da stack
		pop rax                     ; Recupera o número hexa original - sem nenhuma
		                            ; operação aplicada, tal como: shifts e máscaras.
		
		; A instrução 'test' irá aplicar o operador AND (bitwise) entre rcx e ele mesmo,
		; dessa forma, resultando no próprio valor de rcx. No entanto, essa instrução
		; atualiza a flag de status ZF (Zero Flag) - ou seja: quando rcx for zero,
		; irá ativar a flag e o salto condicional não será executado - finalizando o ciclo.
		
		test rcx, rcx               ; Testa se rcx é zero.
		jnz .loop                   ; Caso não seja, retorna para o ínicio do loop.
	
	print_newline:
	
		; Para a escrita apropriada, será adicionado o caractere
                ; especial: '\n' (end of line) ao final da cadeia desejada. 

		; Estaremos aproveitando os argumentos já inicializados para 
		; a chamada de sistema write - em rdi e rdx.

    		mov rax, 1
    		mov rsi, EOL
    		syscall 
		
	_end:
	
		; Neste trecho é executada a syscall: exit - para finalizar o programa.
	
		mov rax, 60
		xor rdi, rdi
		
		; xor irá verificar se todos os bits contidos nos operandos são
    		; iguais. Caso sejam, resultará em zero - ou seja, programa finalizado com sucesso.
		
		; Como os operandos são ambos: rdi, independentemente do valor em rdi,
		; carregará de uma forma simples o valor zero (0) em rdi - exit_code = 0.
		
		syscall
		
		; Programa finalizado com sucesso.
