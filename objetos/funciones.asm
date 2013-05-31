; --------------------------------------------------------------		
MemoriaIniciar:			; eax=dir de TMemoria,ebx=dir del bloque heap
				; ecx=tamaño del bloque heap 
			
	sub	ecx,byte TNodoMemoria_size
	mov	dword [eax+TMemoria.tamano],ecx
	mov	dword [eax+TMemoria.heap],ebx
	mov	dword [ebx+TNodoMemoria.tamano],ecx
	xor	edx,edx
	mov	dword [eax+TMemoria.flags],edx

	push	eax		; Iniciamos las listas a 0
	call	ListaIniciar
	mov	eax,dword [esp]
	add	eax,byte TMemoria.ocupado_primero
	call	ListaIniciar

	pop	eax		; añadimos todo el bloque como libre
	mov	ebx,dword [eax+TMemoria.heap]
	call	ListaAnadir
	
	retn
; ------------------------------------------------------------------------
MemoriaGet:			; eax=dir de TMemoria,ebx=tamaño
				; jc error, jnc eax <= dirección del bloque 
	
	add	ebx,3
	and	ebx,0xfffffffc
	add	ebx,byte TNodoMemoria_size
	mov	esi,dword [eax+TMemoria.libre_primero]	;esi=dir libre_primero 
.ciclo:
	mov	edx,dword [esi+TNodoMemoria.tamano]
	cmp	ebx,edx					;¿es bastante grande?
	jb	short .yaesta
	mov	esi,dword [esi+TNodoMemoria.siguiente]	;siguiente nodo 
	test	esi,esi					;¿es el último nodo? 
	jz	short .error
	jmp	short .ciclo
.yaesta:
	sub	edx,ebx
	mov	dword [esi+TNodoMemoria.tamano],edx
	add	edx,esi
	add	edx,byte TNodoMemoria_size
	sub	ebx,byte TNodoMemoria_size
	mov	dword [edx+TNodoMemoria.tamano],ebx
	add	eax,byte TLista_size
	mov	ebx,edx
	push	ebx
	call	ListaAnadir
	pop	eax
	mov	ecx,dword [eax+TNodoMemoria.tamano]
	add	eax,byte TNodoMemoria_size
	mov	edi,eax
	shr	ecx,2
	push	eax
	cld
	xor	eax,eax
	rep	stosd
	pop	eax
	clc
	retn
.error:
	stc
	retn
; ---------------------------------------------------------------------	
MemoriaFree:			; eax=TMemoria,ebx=dir bloque a liberar
	
	sub	ebx,byte TNodoMemoria_size
	add	eax,byte TLista_size
	push	ebx
	push	eax
	call	ListaEliminar
	pop	eax
	pop	ebx
	sub	eax,byte TLista_size
	call	ListaAnadir
	retn	 
; -------------------------------------------------------------------
GetMaxMem:			; eax=TMemoria
				; eax<=TNodoMemoria con tamaño máximo
				; ebx<=Tamaño máximo
				; jc si error 
	mov	edx,dword [eax+TMemoria.libre_contador]
	test	edx,edx
	jz	short .error
	mov	esi,dword [eax+TMemoria.libre_primero]
	mov	edx,dword [esi+TNodoMemoria.tamano]
	push	esi
	push	edx
.nocambio:	
	mov	esi,dword [esi+TNodoMemoria.siguiente]
	test	esi,esi
	jz	.nomas
	mov	edx,dword [esi+TNodoMemoria.tamano]
	mov	ecx,dword [esp]
	cmp	ecx,edx
	ja	.nocambio
	mov	dword [esp+4],esi
	mov	dword [esp],edx
	jmp	short .nocambio
.nomas:
	pop	ebx
	pop	eax
	retn
.error:
	stc	
	retn		 
; ----------------------------------------------------------------
MemoriaCompactar:		; eax=TMemoria
%assign TMem   4
%assign MemSi  8
%assign MemAc  12
%assign MemBus 16
		
	test	dword [eax+TMemoria.flags],CompactadoMask
	jnz	.salir2
	push	ebp
	mov	ebp,esp
	sub	esp,byte 4*4
	mov	dword [ebp-TMem],eax
	mov	esi,dword [eax+TMemoria.libre_primero]
	mov	dword [ebp-MemSi],esi
.ciclo1:	
	mov	esi,dword [ebp-MemSi]
	test	esi,esi
	jz	.salir
	mov	eax,dword [esi+TNodoMemoria.siguiente]
	test	eax,eax
	jz	.salir
	mov	dword [ebp-MemAc],esi
	mov	dword [ebp-MemSi],eax
	mov	ebx,dword [esi+TNodoMemoria.tamano]
	add	ebx,esi
	add	ebx,byte TNodoMemoria_size
	mov	dword [ebp-MemBus],ebx
	mov	eax,dword [ebp-TMem]
	call	ListaBuscar
	jc	.ciclo1		
	mov	ebx,dword [ebp-MemAc]
	mov	ecx,dword [ebp-MemBus]
	mov	eax,dword [ebp-TMem]
	call	UnirMem
	jmp	.ciclo1
.salir:	
	mov	esi,dword [ebp-TMem]
	or	dword [esi+TMemoria.flags],CompactadoMask
	mov	esp,ebp
	pop	ebp
.salir2:	
	retn	
; ---------------------------------------------------------------------	
UnirMem:			; eax=TMemoria; ebx,ecx=TNodoMemoria
				; se une ebx en ecx
	push	ebx
	mov	ebx,ecx	
	push	ecx
	call	ListaEliminar
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
; ----------------------------------------------------------------------	
ListaIniciar:			; eax=dir de una estructura TLista
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
ListaAnadir:			; eax=TLista, ebx=dir de bloque a añadir
	push	eax		; preservamos eax
	mov	ecx,dword [eax+TLista.primero]
	test	ecx,ecx
	jz	short .nueva
	mov	edi,[eax+TLista.ultimo]		; edi=dir ultimo de la lista
	mov	[ebx+TNodo.anterior],edi	; añadido.anterior=dir ultimo
	mov	[eax+TLista.ultimo],ebx		; TLista.ultimo=añadido
	mov	[edi+TNodo.siguiente],ebx	; ultimo.siguiente=añadido
	mov	[eax+TLista.actual],ebx		; TLista.actual=añadido
	inc	dword [eax+TLista.contador]	; incrementamos el contador
	pop	eax
	retn
.nueva:	
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
ListaEliminar:			; eax=TLista,ebx=dir de bloque a eliminar
				; preservamos eax
	push	eax
	mov	edx,dword [ebx+TNodo.anterior]
	mov	ecx,dword [ebx+TNodo.siguiente]
	xor	esi,esi
	test	edx,edx
	jz	short .primero				;es el primer elemento
	test	ecx,ecx
	jz	short .ultimo				;es el último
	mov	dword [edx+TNodo.siguiente],ecx
	mov	dword [ecx+TNodo.anterior],edx
	jmp	short .salir
.primero:	
	test	ecx,ecx
	jnz	.seguir 
	call	ListaIniciar
	pop	eax
	ret
.seguir:
	mov	dword [eax+TLista.primero],ecx
	mov	dword [ecx+TNodo.anterior],esi
	jmp	short .salir
.ultimo:	
	mov	dword [eax+TLista.ultimo],edx	 
	mov	dword [edx+TNodo.siguiente],esi
.salir:	
	mov	dword [ebx+TNodo.anterior],esi
	dec	dword [eax+TLista.contador]
	mov	dword [ebx+TNodo.siguiente],esi
	pop	eax
	retn
; ------------------------------------------------------------------	
ListaBuscar:			; eax=TLista,ebx=dir del nodo a buscar
				; jc no está, preservamos eax
	push	eax
	clc
	mov	edx,dword [eax+TLista.primero]
	cmp	edx,ebx
	je	short .salir
.ciclo:	
	test	edx,edx
	jz	short .noesta
	mov	edx,dword [edx+TNodo.siguiente]
	cmp	edx,ebx
	je	short .salir
	jmp	short .ciclo
.noesta:	
	stc
.salir:	
	pop	eax
	retn 
; ----------------------------------------------------------	
HexToAsc:                    ;eax=hex, ebx=Buffer del string

	mov	edi,eax
	
	and	eax,dword 0xF
	mov	esi,.tabla
	mov	dl,byte [esi+eax]
	mov	byte [ebx+7],dl

	mov	eax,edi
	mov	cl,4
	and	eax,dword 0xF0
	shr	eax,cl
	mov	dl, byte [esi+eax]
	mov	byte [ebx+6],dl
	
	mov	eax,edi
	add	cl,4
	and	eax,dword 0xF00
	shr	eax,cl
	mov	dl,byte [esi+eax]
	mov	byte [ebx+5],dl
	
	mov	eax,edi
	add	cl,4
	and	eax,dword 0xF000
	shr	eax,cl
	mov	dl,byte [esi+eax]
	mov	byte [ebx+4],dl
	
	mov	eax,edi
	add	cl,4
	and	eax,dword 0xF0000
	shr	eax,cl
	mov	dl,byte [esi+eax]
	mov	byte [ebx+3],dl
	
	mov	eax,edi
	add	cl,4
	and	eax,dword 0xF00000
	shr	eax,cl
	mov	dl,byte [esi+eax]
	mov	byte [ebx+2],dl
	
	mov	eax,edi
	add	cl,4
	and	eax,dword 0xF000000
	shr	eax,cl
	mov	dl,byte [esi+eax]
	mov	byte [ebx+1],dl
	
	mov	eax,edi
	add	cl,4
	and	eax,dword 0xF0000000
	shr	eax,cl
	mov	dl,byte [esi+eax]
	mov	byte [ebx],dl	
	retn
.tabla:	
	db	"0123456789ABCDEF"	
; -------------------------------------------------------------
DecToAsc:                    ;eax=hex, ebx=Buffer del string

	xor	ecx,ecx
	mov	edi,ebx
        _mov	ebx,10
.1:
	xor	edx,edx
	div	ebx
	push	edx
	inc	ecx
	test	eax,eax
	jnz	short .1
.2:
	pop	edx
	or	edx,byte 30h
	mov	byte [edi],dl
	inc	edi
	dec     ecx
	jnz     short .2
	mov	byte [edi],cl
	retn
; -------------------------------------------------------------
TeclaApretada:			;eax=0 no tecla
	mov	dword [poll+pollfd.fd],STDIN
	mov	word [poll+pollfd.events],POLLIN
	mov	eax,168
	mov	ebx,poll
	xor	ecx,ecx
	mov	edx,ecx
	inc	ecx
	int	byte 0x80
	ret
; ------------------------------------------------------------
ObtenerTecla:			;eax<=tecla
	push	eax
	sys_read STDIN,esp,4
	pop	eax
	ret
