%include "global.inc"
%include "TObjeto.aso"

CODESEG

%assign	THeapsize  1024*2048


START
	mov	eax,Memoria
	mov	ebx,Bloque
	mov	ecx,THeapsize
	call	MemoriaIniciar
	
	LocalizarMem	TAplicacion_size
	mov	dword [Aplicacion],eax
	call	OAplicacion.Init
	
	LocalizarMem  TVentana_size
	push	eax
	mov	dword [Ventana],eax
	mov	ebx,0x2001
	mov	ecx,0x2020
	mov	edx,titulos
	call	OVentana.Init
	LocalizarMem TTexto_size 
	push	eax 
	mov	ebx,0x0104 
	mov	ecx,texto
	call	OTexto.Init 
	pop	ebx 
	mov	eax,dword [Ventana] 
	VCall	eax,TVentana,Insertar

	mov	ebx,dword [Ventana]
	mov	eax,dword [Aplicacion]
	VCall	eax,TAplicacion,Insertar
		
	mov	eax,[Aplicacion]
	VCall	eax,TAplicacion,Dibujar

	mov	eax,[Aplicacion]
	VCall	eax,TAplicacion,Volcado
  .otra2:	
	DameTecla .otra2

	mov	eax,dword [Aplicacion]
	call	OAplicacion.Done
	sys_exit

OAplicacion:			
.Init:				;eax=PAplicacion se preserva
	
	push	eax
	IniciarVMT eax,OAplicacion
	VCall	eax,TAplicacion,IniciarPantalla
	xor	ebx,ebx
	mov	ch,byte [eax+TAplicacion.maxX]
	mov	byte [eax+TAplicacion.paleta],bl
	mov	cl,byte [eax+TAplicacion.maxY]
	call	OGrupo.Init
	mov	dword [eax+TAplicacion.dirpaleta],colores
	LocalizarMem	{dword [eax+TAplicacion.longitud]}
	pop	esi
	mov	dword [esi+TAplicacion.buffer],eax
	mov	eax,esi
	ret
.Done:				;eax=PAplicacion se preserva
	push	eax
	mov	esi,dword [eax+TAplicacion.buffer]
	LiberarMem esi
	pop	eax
	VCall	eax,TAplicacion,TerminarPantalla
	call	OGrupo.Done
	ret
.IniciarPantalla:		;eax=PAplicacion se preserva
	push	eax
	lea	edx,[eax+TAplicacion.terminal]
	sys_ioctl STDIN,TCGETS
	mov	eax,dword [edx+termios.c_lflag]
	push	eax
	and	eax,byte ~(ICANON | ECHO)
	mov	dword [edx+termios.c_lflag],eax
	sys_ioctl STDIN,TCSETS
	pop	dword [edx+termios.c_lflag]
	sys_open vcsa,O_RDWR
	mov	esi,dword [esp]
	mov	dword [esi+TAplicacion.handle],eax
	lea	ecx,[esi+TAplicacion.maxY]	
	sys_read eax,EMPTY,2
	xor	eax,eax
	mov	al,byte [esi+TAplicacion.maxX]
	mul	byte [esi+TAplicacion.maxY]
	shl	eax,1
	mov	dword [esi+TAplicacion.longitud],eax
	pop	eax
	ret
.TerminarPantalla:		;eax=PAplicacion se preserva	
	push	eax
	lea	edx,[eax+TAplicacion.terminal]
	sys_ioctl STDIN,TCSETS
	mov	esi,dword [esp]
	sys_close {dword [esi+TAplicacion.handle]}
	pop	eax
	ret
.Volcado:			;eax=PAplicacion se preserva
	push	eax
	mov	ebx,dword [eax+TAplicacion.handle]
	mov	ecx,dword [eax+TAplicacion.buffer]
	mov	edx,dword [eax+TAplicacion.longitud]
	push	byte 4
	pop	esi
	sys_pwrite
	pop	eax
	ret	
.VMT:
	dd	OAplicacion.Done
	dd	ORect.Asignar
	dd	ORect.Copiar
	dd	ORect.Dentro
	dd	OGrupo.Dibujar
	dd	OVista.DameColor
	dd	OVista.Ejecutar
	dd	OVista.MoverFrase
	dd	OVista.MoverCaracter
	dd	OGrupo.Insertar
	dd	OGrupo.Eliminar
	dd	OGrupo.Liberar
	dd	OGrupo.PorCadaUno
	dd	OGrupo.ElPrimeroQue	
	dd	OAplicacion.Volcado
	dd	OAplicacion.IniciarPantalla
	dd	OAplicacion.TerminarPantalla


colores	db	0x07,0x0f,0x0e,0x4e	;aplicacion
	db	0x7f,0x7e,0x7b,0x4e	;dialogo
	db	0x1f,0x1e,0x1c,0x4e	;ventana
	db	0x1b,0x1f,0x1c,0x4e	;menu

vcsa	db	"/dev/vcsa0",EOL	
strpas  Abrir,"\Abrir"
strpas  Nuevo,"\Nuevo"
strpas  Cerrar,"\Cerrar"
strpas  titulos,"La Ventana"
strpas  texto,"Elemento de construcción defectuoso por la casa del guarda."

%include "funciones.asm"
%include "objeto.asm"

UDATASEG
Bloque		resb	THeapsize
Aplicacion	resd	1
Memoria		resb	TMemoria_size
poll		resb	pollfd_size
Ventana		resd	1
Menu		resd	1
	
END