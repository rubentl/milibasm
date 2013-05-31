%ifndef _Lista
%define _Lista

Lista:
.Iniciar:			; eax=dir de una estructura TLista
        mov     esi,eax		; preservamos eax
	xor	edx,edx
        mov	edi,eax
	xor	eax,eax
	mov	dword [esi+TLista.contador],eax
	mov	dword [edi+TLista.primero],edx
	mov	dword [esi+TLista.ultimo],eax
	mov	dword [edi+TLista.actual],edx
	mov	eax,edi
	retn
; ----------------------------------------------------------------------
.Anadir:			; eax=TLista, ebx=dir de bloque a añadir
	push	eax		; preservamos eax
	mov	ecx,dword [eax+TLista.primero]
	test	ecx,ecx
	jz	short .nueva1
	mov	edi,[eax+TLista.ultimo]		; edi=dir ultimo de la lista
	mov	[ebx+TNodo.anterior],edi	; añadido.anterior=dir ultimo
	mov	[eax+TLista.ultimo],ebx		; TLista.ultimo=añadido
	mov	[edi+TNodo.siguiente],ebx	; ultimo.siguiente=añadido
	mov	[eax+TLista.actual],ebx		; TLista.actual=añadido
	inc	dword [eax+TLista.contador]	; incrementamos el contador
	pop	eax
	retn
  .nueva1:	
	mov	[eax+TLista.primero],ebx
	xor	ecx,ecx
	mov	[eax+TLista.ultimo],ebx
	mov	[ebx+TNodo.anterior],ecx
	mov	[eax+TLista.actual],ebx
	inc	dword [eax+TLista.contador]
	mov	[ebx+TNodo.siguiente],ecx
	pop	eax
	retn	
; -----------------------------------------------------------------------
.Eliminar:			; eax=TLista,ebx=dir de bloque a eliminar
				; preservamos eax
	push	eax
	mov	edx,dword [ebx+TNodo.anterior]
	mov	ecx,dword [ebx+TNodo.siguiente]
	xor	esi,esi
	test	edx,edx
	jz	short .primero5				;es el primer elemento
	test	ecx,ecx
	jz	short .ultimo5				;es el último
	mov	dword [edx+TNodo.siguiente],ecx
	mov	dword [ecx+TNodo.anterior],edx
	jmp	short .salir5
  .primero5:	
	test	ecx,ecx
	jnz	.seguir5 
	call	Lista.Iniciar
	pop	eax
	ret
  .seguir5:
	mov	dword [eax+TLista.primero],ecx
	mov	dword [ecx+TNodo.anterior],esi
	jmp	short .salir5
  .ultimo5:	
	mov	dword [eax+TLista.ultimo],edx	 
	mov	dword [edx+TNodo.siguiente],esi
  .salir5:	
	mov	dword [ebx+TNodo.anterior],esi
	dec	dword [eax+TLista.contador]
	mov	dword [ebx+TNodo.siguiente],esi
	pop	eax
	retn
; ------------------------------------------------------------------	
.Buscar:			; eax=TLista,ebx=dir del nodo a buscar
		 		; jc no está, preservamos eax
	push	eax
	clc
	mov	edx,dword [eax+TLista.primero]
	cmp	edx,ebx
	je	short .salir0
  .ciclo6:	
	test	edx,edx
	jz	short .noesta6
	mov	edx,dword [edx+TNodo.siguiente]
	cmp	edx,ebx
	je	short .salir0
	jmp	short .ciclo6
  .noesta6:	
	stc 
  .salir0:	
	pop	eax
	retn 
; -------------------------------------------------------------------------
.PorCadaUno:			;eax=TLista
				;ebx=procedimiento que recibe en ebx TNodo
				; y en eax TLista
	push	eax
	push	ebx
	mov	esi,dword [eax+TLista.primero]
  .ciclo7:	
	test	esi,esi
	jz	.salir7
	push	esi
	mov	ebx,esi
	mov	eax,dword [esp+8]
	call	dword [esp+4]
	pop	esi
	mov	esi,dword [esi+TNodo.siguiente]
	jmp	.ciclo7
  .salir7:
  	pop	ebx
  	pop	eax
  	ret
; ------------------------------------------------------------------------  	
.ElPrimeroQue:			;eax=TLista se preserva
				;ebx=procedimiento que devuelve verdadero(1) o falso(0) en ebx 	
				;y que recibe en ebx un TNodo y en eax TLista
				;ebx<=PVista o null
	push	eax
	push	ebx
	mov	esi,dword [eax+TLista.primero]
  .ciclo8:
  	test	esi,esi
  	jz	.salir8
  	push	esi
  	mov	ebx,esi
  	mov	eax,dword [esp+4]
  	call	dword [esp]
  	pop	esi
  	test	ebx,ebx
	jnz	.salirok  	
	mov	esi,dword [esi+TNodo.siguiente]
	jmp	.ciclo8
  .salirok:
  	mov	ebx,esi
  	pop	eax
  	pop	eax
  	ret
  .salir8:
  	pop	ebx
  	pop	eax
  	xor	ebx,ebx
  	retn
%endif
