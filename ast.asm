
section .data
    delim db " ", 0

section .bss
    root resd 1

section .text

extern	check_atoi
extern	print_tree_inorder
extern	print_tree_preorder
extern	evaluate_tree

extern	malloc
extern	strtok
extern	strlen
extern	strdup

global	create_tree
global	iocla_atoi


iocla_atoi:
	enter	0, 0
	mov		ecx, [esp + 8]
	xor		eax, eax
	xor		edx, edx

	cmp		byte[ecx], '-'			; se verifica daca este numar negativ
	jnz		number
	inc		ecx

number:
	mov		dl, byte[ecx]
									; cifrele apartin in intervalul ascii [48, 57]
	cmp		dl, 48					; se verifica daca este cifra
	jl		negative

	cmp		dl, 57
	jg 		negative

	sub 	dl, 48
	imul 	eax, 10					; se creeaza numarul in modul

	add 	eax, edx
	inc 	ecx
	jmp 	number

negative:
	mov 	ecx, [esp + 8]
	cmp 	byte[ecx], '-'
	jnz 	out_atoi				
	neg 	eax 					; trasformare in numar negativ, daca este cazul

out_atoi:
	leave
	ret



reverse:
	enter	0, 0
	push	eax
	push	eax
	call	strlen
	add		esp, 4

	mov		ecx, eax
	dec		ecx
	mov		edi, ecx
	sar		ecx, 1					; lungime = lungime/2
	pop 	eax
	xor		ebx, ebx

create:
	mov		dl, byte [eax + edi]	; swap cifrele aflate in pozitiile extreme
	mov		dh, byte [eax + ebx]	; exemplu swap prima cifra cu ultima cifra
	mov		byte [eax+ ebx], dl
	mov		byte [eax + edi], dh
	dec		ecx
	dec		edi
	inc 	ebx
	cmp 	ecx, 0
	jge 	create

	leave
	ret


create_tree:
    enter	0, 0
	push	ebx						; se salveaza toata stiva
	push	ecx
	push	edx
	push	edi
	push	esi

    push	eax
    call	reverse					; reverse forma poloneza prefixata
    add		esp, 4
    
    mov 	ebx, [eax] 				; se salveaza valoarea din eax

    push 	delim					; punem pe stiva valorile necesare
    push 	eax 					; pt a se putea executa strtok
    call 	strtok
    add 	esp, 8

integer:
	cmp		byte[eax], '+'			; se verifica daca este numar sau operator
	jz 		operator
	cmp 	byte[eax], '-'
	jz 		operator
	cmp 	byte[eax], '*'
	jz 		operator
	cmp 	byte[eax], '/'
	jz 		operator
	
	push 	eax
	call 	reverse					; reverse numar extras cu strtok
	add 	esp, 4
	push 	eax
	call 	strdup					; copiere numar extras cu strtok 
	add 	esp, 4

	mov 	ebx, eax
	push 	4						; malloc pentru un integer
	call 	malloc
	add 	esp, 4

	mov 	[eax], ebx 				; punem in spatiul alocat numarul extras
									; cu strtok
	push 	eax 					; salvare nod

extract:
    push 	delim					; se extrag caracterele pana la urmatorul spatiu
    push 	0
    call 	strtok
    add 	esp, 8
    cmp 	eax, 0					; se executa pana la finalul sirului de caractere
    jz		out
    jmp	 	integer


operator:
	pop 	esi						; nodul stang
	pop 	edi						; nodul drept
	push 	eax
	call 	strdup
	add 	esp, 4

	mov 	ebx, eax
	push 	12
	call 	malloc					; malloc pentru 3 noduri (nodul parinte ce
	add 	esp, 4					; contine operatorul + nodul drept + nodul stang)

	mov 	[eax], ebx 				; se pune operator in nodul parinte
	mov 	[eax + 4], esi			; se adauga in nodul stang
	mov 	[eax + 8], edi			; se adauga in nodul drept
	push 	eax   					; se salveaza tree-ul

	jmp 	extract


out:
	pop 	eax						; se restaureaza stiva
	pop 	esi
	pop 	edi
    pop 	edx
    pop 	ecx
    pop 	ebx

    leave
    ret