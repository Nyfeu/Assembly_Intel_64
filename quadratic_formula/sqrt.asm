
global sqrt

section .text

    sqrt:

        ; Recebe a -> registrador rdi (argumento)

        ; Inicializa x_n = a / 2

        xor rdx, rdx         ; Limpando rdx
        mov rax, rdi         ; Move o valor de 'a' para rax
        shr rax, 1           ; x_n = a / 2 usando deslocamento para a direita (equivale à div por 2)
        mov rcx, rax         ; x_n = a / 2 (rcx)

        ; Inicializa prev_x = 0

        xor rsi, rsi         ; prev_x = 0

    .loop:

        cmp rsi, rcx         ; Compara prev_x e x_n
        je .end              ; Se prev_x == x_n, sai do loop

        mov rsi, rcx         ; prev_x = x_n

        xor rdx, rdx         ; Limpando rdx para a próxima divisão
        mov rax, rdi         ; Move a para rax
        div rcx              ; Dividindo a por x_n, resultado em rax, resto em rdx

        add rax, rcx         ; x_n + a / x_n
        shr rax, 1           ; x_n = (x_n + a / x_n) / 2 usando deslocamento para a direita

        mov rcx, rax         ; Atualiza x_n

        jmp .loop            ; Repete o loop

    .end:

        ret                  ; Retorna com a raiz quadrada aproximada em rcx



