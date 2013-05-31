strpas	titmenu,"  -[ Menu ]-"
; --------------------------------------------------------------------------
Menu:
.Iniciar:		;eax=TMenu,preservamos eax
	push	eax
	mov	bx,0x050a
	mov	eax,dword [esp]
	mov	cx,0x1201
	call	Rect.Asignar
	mov	dword [eax+TMenu.paleta],PalMenu
	mov	dword [eax+TMenu.titulo],titmenu
	lea	eax,[eax+TMenu.primero]
	call	Lista.Iniciar
	pop	eax
	retn
; -----------------------------------------------------------------------
.InsertarMenuGrupo:		;eax=dir palabra,ebx=tecla
				;eax<=TMenuGrupo
	push	eax
	push	ebx
	LocalizarMem TMenuGrupo_size
	push	eax
	call	Menu.Iniciar
	pop	eax
	pop	ebx
	pop	edx
	mov	dword [eax+TMenuGrupo.tecla],ebx
	mov	dword [eax+TMenuGrupo.titulo],edx
	xor	edx,edx
	mov	dword [eax+TMenuGrupo.anterior],edx
	mov	dword [eax+TMenuGrupo.siguiente],edx
	mov	ebx,eax
	mov	esi,[dword VMenu]
	push	eax
	lea	eax,[esi+TMenu.primero]
	call	Lista.Anadir
	pop	eax
	ret
	
; -------------------------------------------------------------------------
.InsertarMenuElemento:		;eax=TMenuGrupo,ebx=dir palabra,ecx=comando
				;edx=tecla
				;preservamos eax
	push	eax
	push	ebx
	push	ecx
	push	edx
	LocalizarMem TMenuElemento_size
	pop	edx
	pop	ecx
	pop	ebx
	mov	dword [eax+TMenuElemento.palabra],ebx
	mov	dword [eax+TMenuElemento.comando],ecx
	mov	dword [eax+TMenuElemento.tecla],edx
	xor	edx,edx
	mov	dword [eax+TMenuElemento.anterior],edx
	mov	dword [eax+TMenuElemento.siguiente],edx
	mov	ebx,eax
	mov	esi,dword [esp]
	lea	eax,[esi+TMenuGrupo.primero]
	call	Lista.Anadir
	pop	eax
	ret

; ------------------------------------------------------------------------------
.Dibujar:		
	mov	eax,dword [VMenu]
	mov	ecx,dword [eax+TMenu.contador]
	inc	cl
	mov	byte [eax+TMenu.ty],cl
	call	Ventana.Dibujar
	push	eax
	
	mov	esi,paleta
	add	esi,dword [eax+TMenu.paleta]
	SetColor [esi],[esi+2],[esi+4]
	
	pop	eax
	push	dword [eax+TMenu.primero]
	movzx	ecx,byte [eax+TMenu.x]
	movzx	edx,byte [eax+TMenu.y]
	push	ecx
	push	edx
	mov	eax,dword [esp+8]
	test	eax,eax
	jz	.nomas
	inc	byte [esp+4]
	inc	byte [esp]
  .ciclo:
	mov	bh,byte [esp+4]
	mov	bl,byte [esp]
	call Consola.IrXY
	mov	esi,dword [esp+8]
	mov	eax,dword [esi+TMenuGrupo.titulo]
	call Consola.Frase
	inc	byte [esp]
	mov	eax,dword [esp+8]
	mov	edx,dword [eax+TMenuGrupo.siguiente]
	test	edx,edx
	jz	.nomas
	mov	dword [esp+8],edx
	jmp	.ciclo
  .nomas:
	  call Consola.Volcado
	  add	esp,4*3
	  ret
	
; -----------------------------------------------------------------------------
.DibujarMenuGrupo:		;eax=TMenuGrupo,preservamos eax
	push	eax
	mov	ecx,dword [eax+TMenuGrupo.contador]
	inc	cl
	mov	byte [eax+TMenuGrupo.ty],cl
	call	Ventana.Dibujar
	mov	eax,dword [esp]
	mov	esi,paleta
	add	esi,dword [eax+TMenuGrupo.paleta]
	SetColor [esi],[esi+2],[esi+4]
	mov	eax,dword [esp]
	push	dword [eax+TMenuGrupo.primero]
	movzx	edx,byte[eax+TMenuGrupo.x]
	movzx	ecx,byte[eax+TMenuGrupo.y]
	push	edx
	push	ecx
	mov	eax,dword [esp+8]
	test	eax,eax
	jz	.nomas1
	inc	byte [esp]
  .ciclo1:
	mov	bh,byte [esp+4]
	mov	bl,byte [esp]
	call Consola.IrXY
	mov	esi,dword [esp+8]
	mov	eax,dword [esi+TMenuElemento.palabra]
	call Consola.Frase
	inc	byte [esp]
	mov	eax,dword [esp+8]
	mov	edx,dword [eax+TMenuElemento.siguiente]
	test	edx,edx
	jz	.nomas1
	mov	dword [esp+8],edx
	jmp	.ciclo1
  .nomas1:
	add	esp,4*3
	  call Consola.Volcado
	  pop	eax
	ret	
; ---------------------------------------------------------------
.Ejecutar:			;eax<=comando
	call	Menu.Dibujar
	push	eax	
  .ciclo2:
	mov	esi,dword [VMenu]
	mov	eax,dword [esi+TMenu.primero]
	test	eax,eax
	jz	.salir3
	mov	dword [esp],eax
	DameTecla .ciclo2
  .otromenu:
	cmp	eax,TCL_ESC
	je	.salir3
	mov	esi,dword [esp]
	test	esi,esi
	jz	.ciclo2
	mov	ebx,dword [esi+TMenuGrupo.tecla]
	cmp	eax,ebx
	mov	edi,dword [esi+TMenuGrupo.siguiente]
	mov	dword [esp],edi
	jne	.otromenu
	pop	ebx
	mov	eax,esi
	call	Menu.EjecutarMenuGrupo
	jc	Menu.Ejecutar
	ret
  .salir3: 
	pop	eax
	mov	eax,cmRedibujar
	ret
; ---------------------------------------------------------------
.EjecutarMenuGrupo:		;eax=TMenuGrupo,eax<=comando
	push	eax
	push	eax
	mov	eax,dword [esp+4]
	call	Menu.DibujarMenuGrupo
  .ciclo3:
	cmp	eax,TCL_ESC
	je	.salir1
	mov	esi,dword [esp+4]
	mov	eax,dword [esi+TMenuGrupo.primero]
	test	eax,eax
	jz	.salir1
	mov	dword [esp],eax
	DameTecla .ciclo3
  .otroelemento:
	mov	esi,dword [esp]
	test	esi,esi
	jz	.ciclo3
	mov	ebx,dword [esi+TMenuElemento.tecla]
	cmp	eax,ebx
	mov	edi,dword [esi+TMenuElemento.siguiente]
	mov	dword [esp],edi
	jne	.otroelemento
	push	esi
	pop	esi
	pop	ebx
	pop	ecx
	mov	eax,dword [esi+TMenuElemento.comando]
	ret
  .salir1:	
 	stc
	pop	eax
	pop	eax
	mov	eax,cmRedibujar
	ret	

