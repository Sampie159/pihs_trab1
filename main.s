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
lnmsg:      .asciz "Os lucky numbers são: "
lnelem:     .asciz "%d "
nlnmsg:     .asciz "Não existe lucky number nessa matriz.\n"
intentrada: .asciz "%d"
num:        .long 0
linhas:     .long 0
colunas:    .long 0
matriz:     .long 0
vetln:      .long 0
qtln:       .long 0
saida:      .asciz "Muito obrigado por usar este humilde programa ;^)\n"
menu:
    .ascii "O que deseja fazer?\n"
    .ascii "1 - Preencher matriz NxM.\n"
    .ascii "2 - Buscar elemento na matriz\n"
    .ascii "3 - Mostrar diagonal princial.\n"
    .ascii "4 - Mostar lucky numbers.\n"
    .asciz "0 - Sair.\n"

    .text
    .globl main

main:
main_loop:  
    pushl $menu
    call printf
    addl $4, %esp

    pushl $num
    pushl $intentrada
    call scanf
    addl $8, %esp

    movl num, %eax
    cmpl $0, %eax
    je sair
    cmpl $1, %eax
    je chama_preenche
    cmpl $2, %eax
    je chama_busca
    cmpl $3, %eax
    je chama_diaprin
    cmpl $4, %eax
    je chama_ln
    jmp main_loop

chama_preenche: 
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
    jmp main_loop
chama_busca:    
    call buscar_elemento
    jmp main_loop
chama_diaprin:  
    call printa_diagonal
    jmp main_loop
chama_ln:   
    call encontra_lucky_numbers
    jmp main_loop

sair:
    pushl $saida
    call printf
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
    pushl $lnelem
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

encontra_lucky_numbers:
    pushl %ebp
    movl %esp, %ebp
    subl $32, %esp
    movl $0, qtln
    movl $0, -4(%ebp)           # i = linha atual
eln_loop:
    movl linhas, %eax
    cmpl %eax, -4(%ebp)
    je eln_fim
    movl $0, -8(%ebp)           # j = coluna atual
eln_loop_colunas:
    movl colunas, %eax
    cmpl %eax, -8(%ebp)
    je eln_colunas_fim

    ## linha * colunas + coluna = [i,j]
    mull -4(%ebp)
    addl -8(%ebp), %eax
    movl $4, %ebx
    mull %ebx
    addl matriz, %eax
    movl (%eax), %eax
    movl %eax, -12(%ebp)        # elemento pos [i,j]
eln_percorre_linhas:
    movl $0, -16(%ebp)          # i_aux = linha atual
elnpl_loop:
    movl linhas, %eax
    cmpl %eax, -16(%ebp)
    je eln_percorre_colunas

    movl colunas, %eax
    mull -16(%ebp)
    addl -8(%ebp), %eax
    movl $4, %ebx
    mull %ebx
    addl matriz, %eax
    movl (%eax), %eax
    movl %eax, -20(%ebp)        # elemento encontrado
    movl -12(%ebp), %eax
    cmpl %eax, -20(%ebp)
    jg falha_comp
    incl -16(%ebp)
    jmp elnpl_loop
falha_comp:
    incl -8(%ebp)
    jmp eln_loop_colunas
eln_percorre_colunas:
    movl $0, -16(%ebp)          # j_aux = coluna atual
elnpc_loop:
    movl colunas, %eax
    cmpl %eax, -16(%ebp)
    je elnpc_fim

    movl colunas, %eax
    mull -4(%ebp)
    addl -16(%ebp), %eax
    movl $4, %ebx
    mull %ebx
    addl matriz, %eax
    movl (%eax), %eax
    movl %eax, -20(%ebp)
    movl -12(%ebp), %eax
    cmpl %eax, -20(%ebp)
    jl falha_comp
    incl -16(%ebp)
    jmp elnpc_loop
elnpc_fim:
    movl qtln, %eax
    movl $4, %ebx
    mull %ebx
    addl vetln, %eax
    movl -12(%ebp), %ebx
    movl %ebx, (%eax)
    movl qtln, %eax
    incl %eax
    movl %eax, qtln
    incl -8(%ebp)
    jmp eln_loop_colunas
eln_colunas_fim:
    incl -4(%ebp)
    movl $0, -8(%ebp)
    jmp eln_loop
eln_fim:
print_lucky_numbers:
    movl $0, %eax
    cmpl qtln, %eax
    je zero_ln
    pushl $lnmsg
    call printf
    addl $4, %esp
    movl $0, -4(%ebp)
pl_loop:
    movl qtln, %eax
    cmpl %eax, -4(%ebp)
    je pl_fim

    movl -4(%ebp), %eax
    movl $4, %ebx
    mull %ebx
    addl vetln, %eax
    pushl (%eax)
    pushl $lnelem
    call printf
    addl $8, %esp
    incl -4(%ebp)
    jmp pl_loop
zero_ln:
    pushl $nlnmsg
    call printf
    movl %ebp, %esp
    popl %ebp
    ret
pl_fim:
    pushl $newline
    call printf
    movl %ebp, %esp
    popl %ebp
    ret
