global _start

section .data

	codes: db '0123456789ABCDEF'  ; Através do deslocamento do
                                ; endereço codes, pode-se acessar
                                ; todos os símbolos hexadecimais

  EOL: db 10                    ; Caractere end_of_line 
	
section .text

	_start:
	
		mov rax, 0x1122334455667788  ; número em formato hexa
		
		mov rdi, 1
		mov rdx, 1
    mov rcx, 64
		
		; cada 4 bits devem ser exibidos como um dígido hexadecimal
		
	.loop:

		push rax
		
		sub rcx, 4
		sar rax, cl
		and rax, 0xf
		
		lea rsi, [codes + rax]      ; Cria um deslocamento sobre codes
		mov rax, 1
		
		push rcx
		syscall
		
		pop rcx
		pop rax
	
    ; Enquanto rcx não for zero, continua a execução do loop.
    ; Caso seja zero, a Zero Flag será definida e 
    ; o salto condicional não será executado. 

		test rcx, rcx
		jnz .loop

	_end:

    ; Para a escrita apropriada, será adicionado o caractere
    ; especial: '\n' (end of line). 

    mov rax, 1
    mov rdi, 1
    mov rsi, EOL
    mov rdx, 1
    syscall

    ; xor irá verificar se todos os bits contidos em rdi são
    ; iguais. Caso sejam, resultará em zero - ou seja, programa 
    ; finalizado com sucesso. 

    ; Esse resultado independerá do valor contido em rdi! 

		mov rax, 60
		xor rdi, rdi
		syscall
