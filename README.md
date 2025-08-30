[![Assembly](https://img.shields.io/badge/Language-Assembly-blue.svg)](https://en.wikipedia.org/wiki/Assembly_language)
[![Platform](https://img.shields.io/badge/Platform-Intel%2064-lightgrey.svg)](https://en.wikipedia.org/wiki/X86-64)

# 🚀 Assembly para Intel 64 (x86-64)

## 📖 Descrição

Este repositório é o meu diário de bordo pessoal na jornada de aprendizado da arquitetura Intel 64 (também conhecida como x86-64 ou AMD64). Aqui você encontrará uma coleção de códigos em Assembly, desde escrever os valores de um registrador até projetos mais elaborados. Cada diretório representa um pequeno passo nessa fascinante exploração da programação de baixo nível.

## 📂 Projetos Desenvolvidos

Aqui está uma visão geral dos projetos que você encontrará neste repositório. Cada um foca em um conceito diferente da programação em Assembly.

| Projeto | Descrição |
|:-----|:---:|
| `hello_world` | Um programa simples que imprime "Hello, World!" no console usando syscall. | 
| `strlen` | Implementação da função strlen para calcular o comprimento de uma string terminada com nulo (`0`). | 
| `print_rax` | Um utilitário para depuração que imprime o valor contido no registrador rax em formato hexadecimal. | 
| `print_call` | Demonstra o uso de funções (call) para modularizar o código, chamando uma rotina que imprime um valor hexadecimal. |
| `endianness` | Código para visualizar a diferença de ordenação de bytes entre little-endian e big-endian. |
| `pointers` | Exemplos práticos sobre como declarar, carregar e manipular dados na memória usando ponteiros. | 
| `io_library` | Uma biblioteca de entrada/saída com funções úteis para ler e escrever strings e números, facilitando a interação com o usuário. | 
| `quadratic_formula` | Um programa completo que calcula as raízes de uma equação de segundo grau. Utiliza a `io_library` e uma função `sqrt` para o cálculo da raiz quadrada. | 

## 🎯 Objetivos

- **Explorar** e **entender** os fundamentos da programação em Assembly para a arquitetura Intel 64.
- **Testar** diferentes técnicas e algoritmos em baixo nível.
- **Manter um registro** do meu progresso e dos meus experimentos.

## 🛠️ Ferramentas e Pré-requisitos

Para executar os projetos deste repositório, você precisará de um ambiente Linux e das seguintes ferramentas:

* **Assembler:** [NASM](https://www.nasm.us/)
* **Linker:** `ld` (GNU Linker)

Você pode instalar essas ferramentas em uma distribuição baseada em Debian (como o Ubuntu) com o comando:
`sudo apt-get install nasm build-essential`
