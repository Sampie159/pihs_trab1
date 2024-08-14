# Desenvolva um código em assembly que deve apresentar um menu com as seguintes opções:
# 
# 1 - Preencher matriz NxM
# 2 - Buscar elemento na matriz
# 3 - Mostrar diagonal principal
# 4 - Mostrar lucky numbers (Um lucky number é o menor elemento de sua linha e o maior em sua coluna)
# 5 - Sair e mostrar uma boa mensagem
# 
# Pode ser feito em duplas.

    .data
linhasmsg:  .asciz "Quantas linhas?\n"
colmsg:     .asciz "Quantas colunas?\n"
pm_prompt:  .asciz "Dê um valor para o elemento (%d, %d)\n"
elemento:   .asciz "%10d "
newline:    .asciz "\n"
matnquad:   .asciz "A matriz não é quadrada portanto não possui uma diagonal principal.\n"
diaprinmsg: .asciz "Diagonal principal: "
saidadebug: .asciz "%d\n"
elemmsg:    .asciz "Qual elemento deseja encontrar?\n"
encmsg:     .asciz "Elemento encontrado na posição (%d, %d)\n"
nencmsg:    .asciz "Elemento não encontrado na matriz.\n"

intentrada: .asciz "%d"
num:        .long 0
linhas:     .long 0
colunas:    .long 0
matriz:     .long 0
vetln:      .long 0
qtln:       .long 0

    .text
    .globl main

main:
    pushl $linhasmsg
    call printf
    pushl $linhas
    pushl $intentrada
    call scanf
    addl $12, %esp
    
    pushl $colmsg
    call printf
    pushl $colunas
    pushl $intentrada
    call scanf
    addl $12, %esp
    
    movl linhas, %eax
    movl colunas, %ebx
    mull %ebx
    movl $4, %ebx
    mull %ebx
    
    pushl %eax
    call malloc
    movl %eax, matriz
    
    call malloc
    movl %eax, vetln
    addl $4, %esp
    
    call preenche_matriz
    call printa_matriz
    call printa_diagonal
    call buscar_elemento
    call encontrar_lucky_numbers

    pushl $0
    call exit

preenche_matriz:
    xorl %eax, %eax
    xorl %ebx, %ebx
pm_loop:
    cmpl linhas, %eax
    je pm_fim
pm_colunas_loop:
    cmpl colunas, %ebx
    je pm_fim_colunas

    pushl %eax
    movl colunas, %ecx
    mull %ecx
    addl %ebx, %eax
    movl %eax, %ecx
    popl %eax

    pushl %ecx
    pushl %ebx
    pushl %eax
    pushl $pm_prompt
    call printf
    addl $4, %esp
    popl %eax
    popl %ebx
    popl %ecx

    #leal matriz(, %ecx, 4), %edx
    pushl %eax
    movl $4, %eax
    mull %ecx
    addl matriz, %eax
    pushl %ebx
    pushl %eax
    pushl $intentrada
    call scanf
    addl $8, %esp

    popl %ebx
    popl %eax
    incl %ebx
    jmp pm_colunas_loop
pm_fim:
    ret
pm_fim_colunas:
    incl %eax
    xorl %ebx, %ebx
    jmp pm_loop

printa_matriz:
    xorl %eax, %eax
    xorl %ebx, %ebx
prtm_loop:
    cmpl linhas, %eax
    je prtm_fim
prtm_colunas_loop:
    cmpl colunas, %ebx
    je prtm_fim_colunas

    pushl %eax
    # linha * colunas + coluna
    movl colunas, %ecx
    mull %ecx
    addl %ebx, %eax
    movl %eax, %ecx

    pushl %ebx
    #leal matriz(, %ecx, 4), %edx
    movl $4, %eax
    mull %ecx
    addl matriz, %eax
    pushl (%eax)
    pushl $elemento
    call printf
    addl $8, %esp
    popl %ebx
    popl %eax
    incl %ebx
    jmp prtm_colunas_loop
prtm_fim_colunas:
    incl %eax
    xorl %ebx, %ebx
    pushl %eax
    pushl %ebx
    pushl $newline
    call printf
    addl $4, %esp
    popl %ebx
    popl %eax
    jmp prtm_loop
prtm_fim:
    ret

printa_diagonal:
    movl colunas, %eax
    cmpl linhas, %eax
    jne nao_quadrada
    pushl $diaprinmsg
    call printf
    addl $4, %esp
    xorl %ebx, %ebx
pd_loop:
    cmpl linhas, %ebx
    je pd_fim

    movl colunas, %eax
    mull %ebx
    addl %ebx, %eax

    #leal matriz(, %eax, 4), %ecx
    movl %eax, %ecx
    movl $4, %eax
    mull %ecx
    addl matriz, %eax
    pushl %ebx
    pushl (%eax)
    pushl $elemento
    call printf
    addl $8, %esp
    popl %ebx
    incl %ebx
    jmp pd_loop
pd_fim:
    pushl $newline
    call printf
    addl $4, %esp
    ret
nao_quadrada:
    pushl $matnquad
    call printf
    addl $4, %esp
    ret

buscar_elemento:
    pushl $elemmsg
    call printf
    addl $4, %esp

    pushl $num
    pushl $intentrada
    call scanf
    addl $8, %esp

    xorl %eax, %eax
    xorl %ebx, %ebx
be_loop:
    cmpl linhas, %eax
    je be_fim
be_loop_colunas:
    cmpl colunas, %ebx
    je be_colunas_fim

    pushl %eax
    movl colunas, %ecx
    mull %ecx
    addl %ebx, %eax
    movl %eax, %ecx

    movl $4, %eax
    mull %ecx
    addl matriz, %eax
    movl (%eax), %eax
    cmpl num, %eax
    popl %eax
    je be_encontrado
    incl %ebx
    jmp be_loop_colunas
be_encontrado:
    pushl %ebx
    pushl %eax
    pushl $encmsg
    call printf
    addl $12, %esp
    ret
be_colunas_fim:
    incl %eax
    xorl %ebx, %ebx
    jmp be_loop
be_fim:
    pushl $nencmsg
    call printf
    addl $4, %esp
    ret

encontrar_lucky_numbers:
    xorl %eax, %eax
    xorl %ebx, %ebx
eln_loop:
    cmpl linhas, %eax
    je eln_fim
    pushl %eax
eln_loop_colunas:
    cmpl colunas, %ebx
    je eln_colunas_fim

    pushl %eax
    movl colunas, %ecx
    mull %ecx
    addl %ebx, %eax
    pushl %eax
    mull %ebx
    movl $4, %ecx
    mull %ecx
    addl matriz, %eax
    movl (%eax), %eax
    movl %eax, num
    popl %eax
eln_percorre_linhas:
    xorl %eax, %eax
elnpl_loop:
    cmpl linhas, %eax
    je eln_percorre_colunas

    pushl %eax
    mull %ebx
    movl $4, %ecx
    mull %ecx
    addl matriz, %eax
    movl (%eax), %eax
    cmpl num, %eax
    jg elnpl_maior
    popl %eax
    incl %eax
    jmp elnpl_loop
elnpl_maior:
    incl %ebx
    popl %eax
    jmp eln_loop_colunas
eln_percorre_colunas:
    popl %eax
    pushl %ebx
    xorl %ebx, %ebx
elnpc_loop:
    cmpl colunas, %ebx
    je elnpc_fim

    pushl %eax
    mull %ebx
    movl $4, %ecx
    mull %ecx
    addl matriz, %eax
    movl (%eax), %eax
    cmpl num, %eax
    jl elnpc_menor
    popl %eax
    incl %ebx
    jmp elnpc_loop
elnpc_menor:
    popl %eax
    popl %ebx
    incl %ebx
    jmp eln_loop_colunas
elnpc_fim:
    popl %ebx

    pushl %eax
    movl qtln, %eax
    movl $4, %ecx
    mull %ecx
    addl vetln, %eax
    movl num, %ecx
    movl %ecx, (%eax)
    movl qtln, %eax
    incl %eax
    movl %eax, qtln
    popl %eax
    incl %ebx
    jmp eln_loop_colunas
eln_colunas_fim:
    popl %eax
    incl %eax
    xorl %ebx, %ebx
    jmp eln_loop
eln_fim:
    ret
