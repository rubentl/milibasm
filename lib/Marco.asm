%ifndef _Marco
%define _Marco
%include "Consola.asm"

McDoble	        db "œ","š","•","–","™","“"
McSimple	db "Œ","Š","…","†","‰","ƒ"

%assign	SD	0
%assign HO	1
%assign VE	2
%assign SI	3
%assign ID	4
%assign II	5

MarcoSimple:	; eax=Consola se preserva, bh=x, bl=y, ch=tx, cl=ty, dh=atributo
	mov	esi,McSimple
	jmp	short MarcoDoble.sigue
MarcoDoble:
	mov	esi,McDoble
.sigue:	
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov	dl,byte [esi+HO]
	mov	cl,byte 1
	push	esi
	call	Consola.Rectangulo     ;esp=Marco,esp+4=atributo,esp+8=txty,esp+12=xy,esp+16=Cons. 
	mov	ebx,dword [esp+12]
	mov	esi,dword [esp]
	mov	ecx,dword [esp+8]
	mov	edx,dword [esp+4]
	mov	dl,byte [esi+HO]
	add	bl,cl
	mov	cl,byte 1
	call	Consola.Rectangulo
	mov	ebx,dword [esp+12]
	mov	esi,dword [esp]
	mov	ecx,dword [esp+8]
	mov	edx,dword [esp+4]
	mov	dl,byte [esi+VE]
	mov	ch,byte 1
	call	Consola.Rectangulo
	mov	ebx,dword [esp+12]
	mov	esi,dword [esp]
	mov	ecx,dword [esp+8]
	mov	edx,dword [esp+4]
	mov	dl,byte [esi+VE]
	add	bh,ch
	mov	ch,byte 1
	call	Consola.Rectangulo	
	mov	ebx,dword [esp+12]
	mov	esi,dword [esp]
	mov	ecx,dword [esp+4]
	xor	edx,edx
	mov	cl,byte [esi+SI]
	inc	edx
	call	Consola.Caracter
	mov	ebx,dword [esp+12]
	mov	esi,dword [esp]
	mov	ecx,dword [esp+4]
	mov	edx,dword [esp+8]
	add	bh,dh
	xor	edx,edx
	mov	cl,byte [esi+SD]
	inc	edx	
	call	Consola.Caracter
	mov	ebx,dword [esp+12]
	mov	esi,dword [esp]
	mov	ecx,dword [esp+4]
	mov	edx,dword [esp+8]
	add	bl,dl
	xor	edx,edx
	mov	cl,byte [esi+II]
	inc	edx	
	call	Consola.Caracter
	mov	edx,dword [esp+8]
	mov	ebx,dword [esp+12]
	pop	esi
	add	bh,dh
	pop	ecx
	add	bl,dl
	xor	edx,edx
	mov	cl,byte [esi+ID]
	inc	edx	
	call	Consola.Caracter
	add	esp,byte 4*2
	pop	eax
	retn	
%endif
