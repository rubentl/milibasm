%ifndef _Memoria
%define _Memoria
%include "Lista.asm"

Memoria:
.Iniciar:			; eax=dir de TMemoria,ebx=dir del bloque heap
				; ecx=tamaño del bloque heap 
			
	sub	ecx,byte TNodoMemoria_size
	mov	dword [eax+TMemoria.tamano],ecx
	mov	dword [eax+TMemoria.heap],ebx
	mov	dword [ebx+TNodoMemoria.tamano],ecx
	xor	edx,edx
	mov	dword [eax+TMemoria.flags],edx

	push	eax		; Iniciamos las listas a 0
	call	Lista.Iniciar
	mov	eax,dword [esp]
	add	eax,byte TMemoria.ocupado_primero
	call	Lista.Iniciar

	pop	eax		; añadimos todo el bloque como libre
	mov	ebx,dword [eax+TMemoria.heap]
	call	Lista.Anadir
	
	retn
; ------------------------------------------------------------------------
.Get:			; eax=dir de TMemoria,ebx=tamaño
				; jc error, jnc eax <= dirección del bloque 
	
	add	ebx,byte TNodoMemoria_size
	mov	esi,dword [eax+TMemoria.libre_primero]	;esi=dir libre_primero 
  .ciclo1:
	mov	edx,dword [esi+TNodoMemoria.tamano]
	cmp	ebx,edx					;¿es bastante grande?
	jb	short .yaesta1
	mov	esi,dword [esi+TNodoMemoria.siguiente]	;siguiente nodo 
	test	esi,esi					;¿es el último nodo? 
	jz	short .error1
	jmp	short .ciclo1
  .yaesta1:
	sub	edx,ebx
	mov	dword [esi+TNodoMemoria.tamano],edx
	add	edx,esi
	add	edx,byte TNodoMemoria_size
	sub	ebx,byte TNodoMemoria_size
	mov	dword [edx+TNodoMemoria.tamano],ebx
	add	eax,byte TLista_size
	mov	ebx,edx
	push	ebx
	call	Lista.Anadir
	pop	eax
	add	eax,byte TNodoMemoria_size
	clc
	retn
  .error1:
	stc
	retn
; ---------------------------------------------------------------------	
.Free:			; eax=TMemoria,ebx=dir bloque a liberar

	and	dword [eax+TMemoria.flags],OrdenadoMask	
	sub	ebx,byte TNodoMemoria_size
	add	eax,byte TLista_size
	push	ebx
	push	eax
	call	Lista.Eliminar
	pop	eax
	pop	ebx
	sub	eax,byte TLista_size
	call	Lista.Anadir
	retn	 
; -------------------------------------------------------------------
.GetMax:			; eax=TMemoria
				; eax<=TNodoMemoria con tamaño máximo
				; ebx<=Tamaño máximo
				; jc si error 
	mov	edx,dword [eax+TMemoria.libre_contador]
	test	edx,edx
	jz	short .error2
	mov	esi,dword [eax+TMemoria.libre_primero]
	mov	edx,dword [esi+TNodoMemoria.tamano]
	push	esi
	push	edx
  .nocambio2:	
 	mov	esi,dword [esi+TNodoMemoria.siguiente]
	test	esi,esi
	jz	.nomas2
	mov	edx,dword [esi+TNodoMemoria.tamano]
	mov	ecx,dword [esp]
	cmp	ecx,edx
	ja	.nocambio2
	mov	dword [esp+4],esi
	mov	dword [esp],edx
	jmp	short .nocambio2
  .nomas2:
	pop	ebx
	pop	eax
	retn
  .error2:
	stc	
	retn		 
; ----------------------------------------------------------------
.Compactar:		; eax=TMemoria
%assign TMem   4
%assign MemSi  8
%assign MemAc  12
%assign MemBus 16
		
	test	dword [eax+TMemoria.flags],CompactadoMask
	jnz	.salir4
	push	ebp
	mov	ebp,esp
	sub	esp,byte 4*4
	mov	dword [ebp-TMem],eax
	mov	esi,dword [eax+TMemoria.libre_primero]
	mov	dword [ebp-MemSi],esi
  .ciclo3:	
	mov	esi,dword [ebp-MemSi]
	test	esi,esi
	jz	.salir3
	mov	eax,dword [esi+TNodoMemoria.siguiente]
	test	eax,eax
	jz	.salir3
	mov	dword [ebp-MemAc],esi
	mov	dword [ebp-MemSi],eax
	mov	ebx,dword [esi+TNodoMemoria.tamano]
	add	ebx,esi
	add	ebx,byte TNodoMemoria_size
	mov	dword [ebp-MemBus],ebx
	mov	eax,dword [ebp-TMem]
	call	Lista.Buscar
	jc	.ciclo3		
	mov	ebx,dword [ebp-MemAc]
	mov	ecx,dword [ebp-MemBus]
	mov	eax,dword [ebp-TMem]
	call	Memoria.Unir
	jmp	.ciclo3
  .salir3:	
	mov	esi,dword [ebp-TMem]
	or	dword [esi+TMemoria.flags],CompactadoMask
	mov	esp,ebp
	pop	ebp
  .salir4:	
	retn	
; ---------------------------------------------------------------------	
.Unir:			; eax=TMemoria; ebx,ecx=TNodoMemoria
				; se une ebx en ecx
	push	ebx
	mov	ebx,ecx	
	push	ecx
	call	Lista.Eliminar
	mov	edi,dword [esp]
	mov	eax,dword [edi+TNodoMemoria.tamano]
	add	eax,byte TNodoMemoria_size
	mov	esi,dword [esp+4]
	mov	edx,dword [esi+TNodoMemoria.tamano]
	add	eax,edx
	mov	dword [esi+TNodoMemoria.tamano],eax
	pop	edx
	pop	eax
	retn
%endif