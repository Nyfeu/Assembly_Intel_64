
global _start

section .data

	test: dq -1
	new_line: db 10
	codes: db "0123456789ABCDEF"

section .text

	print_newline: 

		mov rax, 1
		mov rdi, 1
		mov rsi, new_line
		mov rdx, 1
		syscall

		ret

	print_hex:

		mov rax, rdi
		mov rcx, 64
		mov rdi, 1
		mov rdx, 1

	.iterate:

		push rax
		sub rcx, 4
		shr rax, cl
		and rax, 0xf
		lea rsi, [codes + rax]
		
		mov rax, 1
		push rcx
		syscall

		pop rcx
		pop rax

		test rcx, rcx
		jnz .iterate
		ret

	_start:
		
		mov byte[test], 1
		mov rdi, [test]
		call print_hex
		call print_newline

		mov word[test], 1
		mov rdi, [test]
    call print_hex
    call print_newline

		mov dword[test], 1
		mov rdi, [test]
		call print_hex
		call print_newline

		mov qword[test], 1
		mov rdi, [test]
		call print_hex
		call print_newline

		mov rax, 60
		xor rdi, rdi
		syscall
