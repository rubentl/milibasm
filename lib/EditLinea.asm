%ifndef _EditLinea
%define _EditLinea
%include "Memoria.asm"
%include "MoverMem.asm"
%include "Consola.asm"

EditLinea:			; eax=PConsola se preserva, ebx=xy, ecx=txty, dh=atributo
				; esi=PStringPas 
				; edi=Procedimiento con argumento en 
				; eax=PStringPas ebx=tecla ecx=cursor ebx<=tecla
	push	ebp
	push	edi
	push	esi
	push	ebx
	mov	ebp,eax
	push	ecx
	push	edx
	xor	edx,edx
	and	dword [esp],0xff00
	push	ebx
	mov	dl,byte [esi]
	LocalizarMem edx
	push	eax

%define PROCEDIMIENTO dword [esp+24]
%define STRPAS  dword [esp+20]
%define XY	dword [esp+16]
%define TXTY    dword [esp+12]
%define COLOR   dword [esp+8]
%define CURSOR  dword [esp+4]
%define COPIA	dword [esp]

	xor	ecx,ecx
	mov	eax,STRPAS
	mov	ebx,COPIA
	mov	cl,byte [eax]
	inc	ecx
	call	MoverMem
	
.Refresco:
	mov	eax,ebp
	mov	ebx,XY
	mov	edx,COLOR
	mov	ecx,STRPAS
	shr	edx,8
	call	Consola.Frase

	mov	ebx,CURSOR
	add	ebx,0x0101
	call	Consola.CurXY

	call	Consola.Volcado
		
.ciclo
	DameTecla ebp,EditLinea.ciclo
	mov	edx,PROCEDIMIENTO
	test	edx,edx
	jz	short EditLinea.SinPro
	mov	eax,STRPAS
	mov	ecx,CURSOR
	call	edx
.SinPro:
	cmp	ebx,TCL_flechade
	jne	short EditLinea.otra1
	mov	eax,STRPAS
	mov	edx,XY
	mov	cl,byte [eax]
	dec	cl
	add	dh,cl
	mov	eax,CURSOR
	cmp	ah,dh
	jae	short EditLinea.Refresco
	add	CURSOR,0x0100
	jmp	short EditLinea.Refresco
.otra1:	
	cmp	ebx,TCL_flechaiz
	jne	short EditLinea.otra2
	mov	eax,CURSOR
	mov	edx,XY
	cmp	ah,dh
	jbe	near EditLinea.Refresco
	sub	CURSOR,0x0100
	jmp	EditLinea.Refresco
.otra2:
	cmp	ebx,TCL_inicio
	jne	short EditLinea.otra3
	mov	eax,CURSOR
	mov	edx,XY
	cmp	ah,dh
	jbe	EditLinea.Refresco
	mov	eax,XY
	mov	CURSOR,eax
	jmp	EditLinea.Refresco
.otra3:
	cmp	ebx,TCL_fin
	jne	short EditLinea.otra4
	mov	eax,STRPAS
	mov	bl,byte [eax]
	mov	ecx,XY
	dec	bl
	add	ch,bl
	mov	eax,CURSOR
	cmp	ah,ch
	jae	EditLinea.Refresco
	mov	CURSOR,ecx
	jmp	EditLinea.Refresco
.otra4:
	cmp	ebx,TCL_borrar
	jne	short EditLinea.otra5
.Borrar:	
	mov	esi,STRPAS
	mov	dl,byte [esi]
	inc	esi
	mov	ecx,CURSOR
	mov	ebx,XY
	shr	ecx,8
	and	ecx,0xff
	sub	cl,bh
	sub	dl,cl
	add	esi,ecx
	dec	dl
	mov	edi,esi
	inc	esi
.repetimos:	
	mov	al,byte[esi]
	mov	byte [edi],al
	inc	esi
	inc	edi
	dec	dl
	jnz	short EditLinea.repetimos
	mov	byte [edi],0x20
	jmp	EditLinea.Refresco

.otra5:
	cmp	bl,TCL_retroceso
	jne	short EditLinea.otra6
	sub	CURSOR,0x0100
	jmp	short EditLinea.Borrar
.otra6:		
	cmp	ebx,TCL_ESC
	jne	short EditLinea.otra7
	mov	eax,COPIA
	xor	ecx,ecx
	mov	cl,byte [eax]
	mov	ebx,STRPAS
	inc	ecx
	call	MoverMem
	jmp	EditLinea.Refresco
.otra7:		
	cmp	bl,TCL_enter
	je      short EditLinea.Salir
	cmp	bl,TCL_tabulador
	je	short EditLinea.Salir
	cmp	ebx,TCL_insertar
	je	EditLinea.ciclo
	mov	eax,ebx
	mov	esi,STRPAS
	mov	dl,byte [esi]
	inc	esi
	mov	ecx,CURSOR
	mov	ebx,XY
	shr	ecx,8
	and	ecx,0xff
	sub	cl,bh
	sub	dl,cl
	add	esi,ecx
	mov	edi,esi
	mov	bl,byte [esi]
	mov	byte [edi],al
	dec	dl
	jz	short EditLinea.insertar_salir
.insertamos:	
	inc	esi
	inc	edi
	mov	al,byte [esi]
	mov	byte [edi],bl
	dec	dl
	jz	short EditLinea.insertar_salir
	inc	esi
	inc	edi
	mov	bl,byte [esi]
	mov	byte [edi],al
	dec	dl
	jnz	short EditLinea.insertamos
.insertar_salir:
	mov	eax,STRPAS
	mov	edx,XY
	mov	cl,byte [eax]
	dec	cl
	add	dh,cl
	mov	eax,CURSOR
	cmp	ah,dh
	jae	EditLinea.Refresco
	add	CURSOR,0x0100
	jmp	EditLinea.Refresco		
.Salir:	
	LiberarMem {COPIA}
	add	esp,byte 4*7
	mov	eax,ebp
	pop	ebp
	retn
%endif