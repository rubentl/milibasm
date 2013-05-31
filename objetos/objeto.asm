;================================================================[RECT]=================
ORect:	
.Init:					;eax=PRect se preserva
					;bh=x,bl=y,ch=tx,cl=ty
	push	eax
	push	ebx
	push	ecx
	IniciarVMT	eax,ORect
	mov	esi,eax
	pop	ecx
	pop	ebx
	pop	eax
	shl	ebx,16
	mov	bx,cx
	xor	edx,edx
	mov	dword [esi+TRect.ty],ebx
	mov	dword [eax+TRect.padre],edx
	mov	dword [esi+TRect.id],idRect
	ret
.Done:					;eax=PRect,eax<=nulo
	LiberarMem	eax
	xor	eax,eax
	ret
.Asignar:				;eax=PRect se preserva
					;bh=x,bl=y,ch=tx,cl=ty
	shl	ebx,16
	mov	bx,cx
	mov	dword [eax+TRect.ty],ebx
	ret
.Copiar:				;eax=PRect se preserva
					;bh<=x,bl<=y,ch<=tx,cl<=ty
	mov	ebx,dword [eax+TRect.ty]
	mov	cx,bx
	shr	ebx,16
	ret
.Dentro:				;eax=PRect se preserva
					;bh=x,bl=y,ch=tx,cl=ty
	push	edx
	cmp	byte [eax+TRect.x],bh
	jbe	.seguir
	mov	bh,byte [eax+TRect.x]
  .seguir:
	cmp	byte [eax+TRect.y],bl
	jbe	.seguir1
	mov	bl,byte [eax+TRect.y]
  .seguir1:
	mov	dl,byte [eax+TRect.x]
	add	dl,byte [eax+TRect.tx]
	mov	dh,bh
	add	dh,ch
	cmp	dh,dl
	jbe	.seguir2
	sub	dh,dl
	sub	ch,dh
	dec	ch
  .seguir2:
  	mov	dl,byte [eax+TRect.y]
	add	dl,byte [eax+TRect.ty]
	mov	dh,bl
	add	dh,cl
	cmp	dh,dl
	jbe	.seguir3
	sub	dh,dl
	sub	cl,dh
	dec	cl  	
  .seguir3:
  	pop	edx
	ret
align	16
.VMT:
	dd	ORect.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
;================================================================[VISTA]=================
OVista:
.Init:					;eax=PVista se preserva
					;bh=x,bl=y,ch=tx,cl=ty
	push	eax
	push	ebx
	push	ecx
	IniciarVMT	eax,OVista
	call	ORect.Init
	pop	ecx
	pop	ebx
	pop	eax
	mov	edi,eax
	mov	dword [eax+TVista.eventos],ebx
	mov	dword [eax+TVista.id],idVista
	mov	dword [edi+TVista.paleta],palAplicacion
	ret
	
.Dibujar:			;eax=PVista se preserva

	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	dl,byte " "
	VCall	eax,TVista,Copiar
	VCall	eax,TVista,MoverCaracter
	ret

.Ejecutar:
	ret	

.DameColor:			;eax=PVista se preserva
				;bl=indice de color,bl<=color
	xor	edx,edx
	mov	esi,dword [Aplicacion]
	xor	ecx,ecx
	and	ebx,0x000000ff
	mov	edx,dword [esi+TAplicacion.dirpaleta]
	mov	cl,byte [eax+TVista.paleta]
	add	edx,ecx
	add	edx,ebx
	mov	bl,byte [edx]
	ret
	
.MoverCaracter:			;eax=PVista se preserva
				;bh=x,bl=y,ch=tx,cl=ty,dh=atributo,dl=caracter
	push	eax
	VCall	eax,TVista,Dentro
	mov	esi,ebx
	and	ebx,0x0000ffff
	push	ebx		;x y	[esp+12]
	mov	esi,ecx
	and	ecx,0x000000ff
	and	esi,0x0000ff00
	push	ecx		;ty	[esp+8]
	shr	esi,8
	push	esi		;tx	[esp+4]
	and	edx,0x0000ffff
	push	edx		;atributo y caracter [esp]
	
  .ciclo1:
	mov	esi,dword [Aplicacion]
	mov	eax,dword [esp+12]
	mul	byte [esi+TAplicacion.maxX]
	mov	edi,eax
	mov	eax,dword [esp+12]
	and	eax,0x0000ff00
	shr	eax,8
	add	edi,eax
	shl	edi,1
	add	edi,dword [esi+TAplicacion.buffer]
	mov	eax,dword [esp]
	mov	ecx,dword [esp+4]
	cld
	rep	stosw
	inc	dword [esp+12]
	dec	dword [esp+8]
	jnz	.ciclo1
	add	esp,byte 4*4
	pop	eax
	ret 

.MoverFrase:			;eax=PVista se preserva
				;bh=x,bl=y,ch=atributo,edx=strpas
	push	eax
	push	ecx
	VCall	eax,TVista,Dentro
	pop	ecx
	and	ebx,0x0000ffff
	push	ebx		;x y [esp+12]
	and	ecx,0x0000ff00
	push	ecx		;atributo [esp+8]
	movzx	ecx,byte [edx]
	inc	edx
	push	edx		;strpas [esp+4]
	push	ecx		;número de bytes del strpas [esp]
	VCall	eax,TVista,Copiar
	cmp	ch,byte [esp]
	jae	.ciclo2
	mov	byte [esp],ch
	  
  .ciclo2:	
	mov	esi,dword [Aplicacion]
	mov	eax,dword [esp+12]
	mul	byte [esi+TAplicacion.maxX]
	mov	edi,eax
	mov	eax,dword [esp+12]
	and	eax,0x0000ff00
	shr	eax,8
	add	edi,eax
	shl	edi,1
	add	edi,dword [esi+TAplicacion.buffer]
	mov	eax,dword [esp+8]
	mov	ecx,dword [esp+4]
	movzx	ebx,byte [ecx]
	or	eax,ebx
	cmp	al,"\"		; "\"
	je	.noloponemos
	mov	word [edi],ax
	add	dword [esp+12],0x0100
  .noloponemos:
	inc	dword [esp+4]
	dec	dword [esp]
	jns	.ciclo2
	add	esp,byte 4*4
	pop	eax	
	ret
align	16	
.VMT:
	dd	ORect.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OVista.Dibujar
	dd	OVista.DameColor
	dd	OVista.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
;================================================================[TEXTO]===================
OTexto:
.Init:				;eax=PTexto se preserva
				;bx=x,bl=y,ecx=strpas
	push	eax
	push	ecx
	IniciarVMT eax,OTexto
	xor 	ecx,ecx
	mov	edi,dword [esp]
	inc	ecx
	mov	ch,byte [edi]
	dec	ch
	call	OVista.Init
	pop	ebx
	VCall	eax,TTexto,CopiarStr
	VCall	eax,TTexto,AnalizarStr
	pop	eax
	mov	dword [eax+TTexto.id],idTexto
	ret
	
.DameColor:			;eax=PTexto se preserva
				;bl=indice de color,bl<=color
	mov	esi,dword [eax+TTexto.padre]
	movzx	edx,byte [esi+TVista.paleta]
	mov	byte [eax+TTexto.paleta],dl
	ACall	Vista,DameColor
	ret
	
.Dibujar:			;eax=PTexto se preserva
	push	eax
	push	ebp	
	ACall	Vista,Dibujar
	mov	ebp,dword [esp+4]
	mov	bl,palNormal
  	mov	eax,ebp
  	VCall	eax,TTexto,DameColor
  	mov	ch,bl
  	mov	bh,byte [ebp+TTexto.x]
  	mov	bl,byte [ebp+TTexto.y]
  	mov	edx,dword [ebp+TTexto.texto]
  	VCall	eax,TTexto,MoverFrase
  	mov	bl,byte [eax+TTexto.lugar]
  	test	bl,bl
  	jz	.salir
  	mov	bl,palResaltado
  	mov	eax,ebp
  	VCall	eax,TTexto,DameColor
  	mov	dh,bl
  	mov	bh,byte [ebp+TTexto.x]
  	mov	bl,byte [ebp+TTexto.y]
  	xor	ecx,ecx
  	or	cx,word 0x0101
  	add	bh,byte [ebp+TTexto.lugar]
  	mov	dl,byte [ebp+TTexto.caracter]
  	dec	bh
  	VCall	eax,TTexto,MoverCaracter
  .salir:
	pop	ebp
	pop	eax
	ret

.CopiarStr:				;eax=PTexto se preserva
					;ebx=dir de StrPas
	push	eax
	push	ebx
	movzx	ecx,byte [ebx]
	inc	ecx
	push	ecx
	LocalizarMem ecx
	mov	esi,dword [esp+8]
	mov	dword [esi+TTexto.texto],eax
	mov	edi,eax
	mov	esi,dword [esp+4]
	pop	ecx
  .ciclo:
  	mov	al,byte [esi]
	mov	byte [edi],al
	inc	esi
	inc	edi
	dec	cl
	jnz	.ciclo
	pop	ebx
	pop	eax
	ret

.AnalizarStr:				;eax=PTexto se preserva
	push	eax
	mov	esi,dword [eax+TTexto.texto]
	xor	edx,edx
	movzx	ecx,byte [esi]
  .ciclo1:
	inc	esi
	mov	al,byte [esi]
	inc	edx
	cmp	al,"\"		; "\"
	je	.yaesta
	dec	ecx
	jnz	.ciclo1
	pop	eax
	xor	edx,edx
	mov	word [eax+TTexto.lugar],dx
	ret
  .yaesta:
  	pop	eax
  	inc	esi
  	mov	bl,byte [esi]
  	mov	byte [eax+TTexto.lugar],dl
  	mov	byte [eax+TTexto.caracter],bl
  	ret	
.Done:					;eax=PTexto
	push	eax
	mov	edx,dword [eax+TTexto.texto]
	LiberarMem edx
	pop	eax
	ACall	Vista,Done
	ret
	
align	16
.VMT:
	dd	OTexto.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OTexto.Dibujar
	dd	OTexto.DameColor
	dd	OVista.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OTexto.CopiarStr
	dd	OTexto.AnalizarStr
	
;================================================================[VENTANA]=================
OVentana:			
.Init:				;eax=PVentana se preserva
				;bh=x,bl=y,ch=tx,cl=ty,edx=strpas título
	push	edx
	IniciarVMT eax,OVentana
	call	OGrupo.Init
	mov	byte [eax+TVentana.paleta],palVentana
	VCall	eax,TVentana,InsertarMarco
	pop	ebx
	VCall	eax,TVentana,InsertarTitulo
	mov	dword [eax+TVentana.id],idVentana
	ret

.Ejecutar:
	ret
	
.InsertarMarco:			;eax=PVentana
	push	eax
	LocalizarMem TMarco_size
	pop	esi
	mov	dword [esi+TVentana.marco],eax
	push	esi
	push	eax
	mov	eax,esi
	VCall	eax,TVentana,Copiar
	xor	ebx,ebx
	mov	eax,dword [esp]
	call	OMarco.Init
	pop	ebx
	pop	eax
	VCall	eax,TVentana,Insertar
	ret			

.InsertarTitulo:			;eax=PVentana se preserva
					;ebx=dir strpas		
	push	eax
	push	ebx
	LocalizarMem TTexto_size
	pop	ecx
	mov	edi,dword [esp]
	mov	dword [edi+TVentana.titulo],eax
	mov	bx,0x0200
	call	OTexto.Init
	mov	ebx,eax
	pop	eax
	mov	edi,dword [ebx+TTexto.texto]
	movzx	ecx,byte [edi]
	movzx	edx,byte [eax+TVentana.tx]
	cmp	byte [ebx+TTexto.lugar],0
	je	.sinbarra
	inc	edx
  .sinbarra:
	sub	ecx,4
	sub	edx,5
	cmp	ecx,edx
	jbe	.seguir
	mov	byte [ebx+TTexto.tx],dl
	mov	byte [edi],dl
  .seguir: 	
	VCall	eax,TVentana,Insertar
	ret

.Dibujar:
	push	eax
	ACall	Grupo,Dibujar
	mov	esi,dword [esp]
	mov	eax,dword [esi+TVentana.marco]
	VCall	eax,TVista,Dibujar
	pop	esi
	mov	eax,dword [esi+TVentana.titulo]
	VCall	eax,TTexto,Dibujar
	ret	
		
align	16
.VMT:
	dd	OGrupo.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OVentana.Dibujar
	dd	OVista.DameColor
	dd	OVentana.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OGrupo.Insertar
	dd	OGrupo.Eliminar
	dd	OGrupo.Liberar
	dd	OGrupo.PorCadaUno
	dd	OGrupo.ElPrimeroQue
	dd	OVentana.InsertarTitulo
	dd	OVentana.InsertarMarco

;================================================================[MARCO]=================
OMarco:
.Init:				;eax=PMarco se preserva
				;bh=x,bl=y,ch=tx,cl=ty
	push	edx
	IniciarVMT eax,OMarco
	call	OVista.Init
	pop	edx
	VCall	eax,TMarco,HacerDoble
	mov	dword [eax+TMarco.id],idMarco
	ret
.Dibujar:			;eax=PMarco se preserva
	
	push	eax	
	mov	eax,dword [eax+TMarco.padre]
	VCall	eax,TRect,Copiar
	pop	eax
	VCall	eax,TMarco,Asignar		
	cmp	byte [eax+TMarco.tipo],Simple
	jne	.doble
	mov	edi,MarcoSimple
	jmp	.simple
 .doble:
 	mov	edi,MarcoDoble
 .simple:	
 	push	edi
	mov	esi,dword [eax+TMarco.padre]
	mov	cl,byte [esi+TGrupo.paleta]
	mov	byte [eax+TMarco.paleta],cl
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	edi,dword [esp]
	mov	dl,byte [edi+HO]
	VCall	eax,TVista,Copiar
	mov	cl,1
	VCall	eax,TVista,MoverCaracter
	
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	edi,dword [esp]
	mov	dl,byte [edi+HO]
	VCall	eax,TVista,Copiar
	add	bl,cl
	mov	cl,1
	dec	bl
	VCall	eax,TVista,MoverCaracter
	
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	edi,dword [esp]
	mov	dl,byte [edi+VE]
	VCall	eax,TVista,Copiar
	mov	ch,1
	VCall	eax,TVista,MoverCaracter
	
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	edi,dword [esp]
	mov	dl,byte [edi+VE]
	VCall	eax,TVista,Copiar
	add	bh,ch
	mov	ch,1
	dec	bh
	VCall	eax,TVista,MoverCaracter
	
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	edi,dword [esp]
	mov	dl,byte [edi+SI]
	VCall	eax,TVista,Copiar
	mov	cx,0x0101
	VCall	eax,TVista,MoverCaracter
	
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	edi,dword [esp]
	mov	dl,byte [edi+SD]
	VCall	eax,TVista,Copiar
	add	bh,ch
	mov	cx,0x0101
	dec	bh
	VCall	eax,TVista,MoverCaracter
	
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	mov	edi,dword [esp]
	mov	dl,byte [edi+II]
	VCall	eax,TVista,Copiar
	add	bl,cl
	mov	cx,0x0101
	dec	bl
	VCall	eax,TVista,MoverCaracter
	
	mov	bl,palNormal
	VCall	eax,TVista,DameColor
	mov	dh,bl
	pop	edi
	mov	dl,byte [edi+ID]
	VCall	eax,TVista,Copiar
	add	bl,cl
	add	bh,ch
	mov	cx,0x0101
	dec	bl
	dec	bh
	VCall	eax,TVista,MoverCaracter
	ret

.Ejecutar:
	ret

.HacerSimple:			;eax=PMarco
	mov	byte [eax+TMarco.tipo],Simple
	ret

.HacerDoble:			;eax=PMarco
	mov	byte [eax+TMarco.tipo],Doble
	ret

align	16
.VMT:
	dd	ORect.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OMarco.Dibujar
	dd	OVista.DameColor
	dd	OMarco.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OMarco.HacerSimple
	dd	OMarco.HacerDoble
	
MarcoDoble	db "œ","š","•","–","™","“"
MarcoSimple	db "Œ","Š","…","†","‰","ƒ"
;================================================================[GRUPO]=================
OGrupo:
.Init:				;eax=PGrupo se preserva
	push	eax
	IniciarVMT eax,OGrupo
	call	OVista.Init
	lea	eax,[eax+TGrupo.hijos]
	call	ListaIniciar
	pop	eax
	mov	dword [eax+TGrupo.id],idGrupo
	mov	dword [eax+TGrupo.paleta],palAplicacion
	ret
	
.Done:				;eax=PGrupo,eax<=nulo
	mov	ebx,.DoneTodo
	VCall	eax,TGrupo,PorCadaUno
	ACall	Vista,Done
	ret
  .DoneTodo:			;eax=PGrupo se preserva
				;ebx=PView
	push	eax
	mov	eax,ebx
	VCall	eax,TVista,Done
	pop	eax
	ret

.Dibujar:			;eax=PGrupo se preserva
	
	ACall	Vista,Dibujar
	mov	ebx,.DibujarTodo
	VCall	eax,TGrupo,PorCadaUno
	ret
  .DibujarTodo:			;eax=PGrupo se preserva
  				;ebx=PView
  	push	eax
  	mov	eax,ebx
	VCall	eax,TVista,Dibujar
  	pop	eax
  	ret

.Ejecutar:
	ret
	
.Insertar:			;eax=PGrupo se preserva
				;ebx=PVista a insertar
	push	eax
	push	eax
	push	ebx
	VCall	eax,TGrupo,Copiar
	mov	esi,dword [esp]
	add	byte [esi+TVista.x],bh
	add	byte [esi+TVista.y],bl
	mov	eax,dword [esp]
	VCall	eax,TVista,Copiar
	mov	eax,dword [esp+4]
	VCall	eax,TGrupo,Dentro
	mov	eax,dword [esp]
	VCall	eax,TVista,Asignar
	pop	ebx
	pop	eax
	mov	dword [ebx+TVista.padre],eax
	lea	eax,[eax+TGrupo.hijos]
	call	ListaAnadir
	pop	eax	
	ret

.Eliminar:			;eax=PGrupo se preserva
				;ebx=PVista a eliminar, no se libera
	push	eax
	lea	eax,[eax+TGrupo.hijos]
	call	ListaBuscar
	jc	.noesta
	xor	ecx,ecx
	mov	dword [ebx+TVista.padre],ecx
	call	ListaEliminar
  .noesta:
	pop	eax
	ret
	
.PorCadaUno:			;eax=PGrupo se preserva
				;ebx=procedimiento que recibe en ebx un PView
	push	eax
	push	ebx
	lea	eax,[eax+TGrupo.hijos]
	mov	esi,dword [eax+TLista.primero]
  .ciclo1:	
	test	esi,esi
	jz	.salir1
	push	esi
	mov	ebx,esi
	mov	eax,dword [esp+8]
	call	dword [esp+4]
	pop	esi
	mov	esi,dword [esi+TNodo.siguiente]
	jmp	.ciclo1
  .salir1:
  	pop	ebx
  	pop	eax
  	ret
  	
.ElPrimeroQue:			;eax=PGrupo se preserva
				;ebx=procedimiento que devuelve verdadero(1) o falso(0) en ebx 	
				;y que recibe en ebx un PView
				;ebx<=PVista o null
	push	eax
	push	ebx
	lea	eax,[eax+TGrupo.hijos]
	mov	esi,dword [eax+TLista.primero]
  .ciclo2:
  	test	esi,esi
  	jz	.salir2
  	push	esi
  	mov	ebx,esi
  	mov	eax,dword [esp+4]
  	call	dword [esp]
  	pop	esi
  	test	ebx,ebx
	jnz	.salirok  	
	mov	esi,dword [esi+TVista.siguiente]
	jmp	.ciclo2
  .salirok:
  	mov	ebx,esi
  	pop	eax
  	pop	eax
  	ret
  .salir2:
  	pop	ebx
  	pop	eax
  	xor	ebx,ebx
  	ret

.Liberar:			;eax=PGrupo se preserva
				;ebx=PVista a liberar ebx<=nulo
	push	eax
	push	ebx
	VCall	eax,TGrupo,Eliminar
	pop	ebx
	LiberarMem ebx
	pop	eax
	xor	ebx,ebx
	ret
align	16  	
.VMT:
	dd	OGrupo.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OGrupo.Dibujar
	dd	OVista.DameColor
	dd	OGrupo.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OGrupo.Insertar
	dd	OGrupo.Eliminar
	dd	OGrupo.Liberar
	dd	OGrupo.PorCadaUno
	dd	OGrupo.ElPrimeroQue
;=================================================[MENÚ]======================
OMenu:
.Init:					;eax=PMenu se preserva
					;bh=x,bl=y
	push	eax
	push	ebx
	IniciarVMT  eax,OMenu
	mov	ecx,0x1002
	mov	edx,Menu
	call	OVentana.Init	
	mov	eax,dword [eax+TVentana.marco]
	VCall	eax,TMarco,HacerSimple
	pop	ebx
	pop	eax
	mov	dword [eax+TMenu.paleta],palMenu
	mov	dword [eax+TMenu.id],idMenu						
    	ret
    	
.NuevoGrupo:				;eax=PMenu se preserva.
					;ebx=PMenuGrupo
	push	eax
	push	ebx
	VCall	eax,TMenu,Copiar
	inc	cl
	VCall	eax,TMenu,Asignar
	VCall	eax,TMenu,Copiar
	add	bh,0x1
	add	bl,cl
	dec	bl
	dec	bl
	push	ebx
	LocalizarMem	TMenuElemento_size
	pop	ebx
	mov	edi,dword [esp]
	mov	ecx,dword [edi+TMenuGrupo.titulo]
	mov	edx,dword [edi+TMenuGrupo.tecla]
	mov	esi,cmNulo
	call	OMenuElemento.Init
	mov	ebx,eax
	mov	eax,dword [esp+4]
	VCall	eax,TMenu,Insertar
	pop	ebx
	pop	eax
	VCall	eax,TMenu,Insertar	
	ret

		
align	16  	
.VMT:
	dd	OGrupo.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OGrupo.Dibujar
	dd	OVista.DameColor
	dd	OVentana.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OGrupo.Insertar
	dd	OGrupo.Eliminar
	dd	OGrupo.Liberar
	dd	OGrupo.PorCadaUno
	dd	OGrupo.ElPrimeroQue
	dd	OVentana.InsertarTitulo
	dd	OVentana.InsertarMarco
	dd	OMenu.NuevoGrupo


;==============================================[MENÚGRUPO]======================
OMenuGrupo:
.Init:					;eax=PMenuGrupo se preserva
					;bh=x,bl=y,ecx=Nombre,edx=tecla
	push	eax
	push	ebx
	push	edx
	push	ecx	
	IniciarVMT  eax,OMenuGrupo
	mov	ecx,0x1002
	pop	edx
	call	OVentana.Init	
	mov	eax,dword [eax+TVentana.marco]
	VCall	eax,TMarco,HacerSimple
	pop	edx
	pop	ebx
	pop	eax
	mov	dword [eax+TMenuGrupo.tecla],edx
	mov	dword [eax+TMenuGrupo.paleta],palMenu
	mov	dword [eax+TMenuGrupo.id],idMenuGrupo						
    	ret
    	
.NuevoElemento:				;eax=PMenuGrupo se preserva.
					;ebx=Nombre,ecx=tecla,edx=comando
	push	eax
	push	ebx
	push	ecx
	push	edx
	VCall	eax,TMenuGrupo,Copiar
	inc	cl
	VCall	eax,TMenuGrupo,Asignar
	VCall	eax,TMenuGrupo,Copiar
	add	bh,0x1
	add	bl,cl
	dec	bl
	dec	bl
	push	ebx
	LocalizarMem	TMenuElemento_size
	pop	ebx
	mov	ecx,dword [esp+8]
	mov	edx,dword [esp+4]
	mov	esi,dword [esp]
	call	OMenuElemento.Init
	mov	ebx,eax
	mov	eax,dword [esp+12]
	VCall	eax,TMenuGrupo,Insertar
	add	esp,4*3
	pop	eax
	ret

align	16  	
.VMT:
	dd	OGrupo.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OGrupo.Dibujar
	dd	OVista.DameColor
	dd	OVentana.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OGrupo.Insertar
	dd	OGrupo.Eliminar
	dd	OGrupo.Liberar
	dd	OGrupo.PorCadaUno
	dd	OGrupo.ElPrimeroQue
	dd	OVentana.InsertarTitulo
	dd	OVentana.InsertarMarco
	dd	OMenuGrupo.NuevoElemento

;========================================[MENÚELEMENTO]=======================
OMenuElemento:
.Init:					;eax=PMenuElemento
					;bh=x,bl=y,ecx=Nombre,edx=tecla,esi=comando
	push	eax
	push	ecx
	push	edx
	push	esi
	IniciarVMT eax,OMenuElemento	
	call	OTexto.Init
	pop	esi
	pop	edx
	pop	ecx
	pop	eax
	mov	dword [eax+TMenuElemento.tecla],edx
	mov	dword [eax+TMenuElemento.comando],esi
	mov	dword [eax+TMenuElemento.id],idMenuElemento
	mov	dword [eax+TMenuElemento.paleta],palMenu	
	ret


align	16
.VMT:
	dd	OTexto.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OTexto.Dibujar
	dd	OTexto.DameColor
	dd	OVista.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OTexto.CopiarStr
	dd	OTexto.AnalizarStr

strpas	Menu,"[ Menú ]"
