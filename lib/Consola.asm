%ifndef _Consola
%define _Consola
%include "DecToAsc.asm"
%include "Memoria.asm"

Consola:
.Iniciar:				; eax=PConsola se preserva
	push	eax
	lea	edx,[eax+TConsola.terminal]
	sys_ioctl STDIN,TCGETS
	mov	eax,dword [edx+termios.c_lflag]
	push	eax
	and	eax,byte ~(ICANON | ECHO)
	mov	dword [edx+termios.c_lflag],eax
	sys_ioctl STDIN,TCSETS
	pop	dword [edx+termios.c_lflag]
	sys_open vcsa,O_RDWR
	test	eax,eax
	jns	Consola.ok
	sys_open vcsa0,O_RDWR
	mov	esi,dword [esp]
	test	eax,eax
	js	Consola.Error1
.ok:		
	mov	esi,dword [esp]
	mov	dword [esi+TConsola.handle],eax
	lea	ecx,[esi+TConsola.maxY]	
	sys_read eax,EMPTY,2
	xor	eax,eax
	mov	al,byte [esi+TConsola.maxX]
	mul	byte [esi+TConsola.maxY]
	shl	eax,1
	mov	dword [esi+TConsola.longitud],eax
	mov	esi,dword [esp]
	LocalizarMem	{dword [esi+TConsola.longitud]}
	mov	esi,dword [esp]
	mov	dword [esi+TConsola.buffer],eax
	LocalizarMem	{dword [esi+TConsola.longitud]}
	mov	esi,dword [esp]
	mov	dword [esi+TConsola.buffer_old],eax
	mov	ecx,eax
	mov	ebx,dword [esi+TConsola.handle]
	mov	edx,dword [esi+TConsola.longitud]
	push	byte 4
	pop	esi
	sys_pread
	sys_write STDOUT,cur_salvar,long_cur_salvar 
	pop	eax
	ret
.Error1:
	lea	edx,[esi+TConsola.terminal]
	sys_ioctl STDIN,TCSETS
	sys_write STDOUT,ErAbrirArchivo,long_ErAbrirArchivo
	sys_exit  -1
	ret
.Hecho:				; eax=PConsola se preserva
	push	eax
	lea	edx,[eax+TConsola.terminal]
	sys_ioctl STDIN,TCSETS
	mov	esi,dword [esp]
	mov	ebx,dword [esi+TConsola.handle]
	mov	ecx,dword [esi+TConsola.buffer_old]
	mov	edx,dword [esi+TConsola.longitud]
	push	byte 4
	pop	esi
	sys_pwrite
	mov	esi,dword [esp]
	LiberarMem {dword [esi+TConsola.buffer]}
	mov	esi,dword [esp]
	LiberarMem {dword [esi+TConsola.buffer_old]}
	mov	esi,dword [esp]
	sys_close {dword [esi+TConsola.handle]}
	sys_write STDOUT,cur_restaurar,long_cur_restaurar
	pop	eax
	retn
	
.Limpiar:			; eax=PConsola se preserva
	push	eax
	mov	ch,byte [eax+TConsola.maxX]
	mov	cl,byte [eax+TConsola.maxY]
	xor	ebx,ebx
	xor	edx,edx
	call	Consola.Rectangulo
	pop	eax
	retn
		
.Volcado:			;eax=PConsola se preserva
	push	eax
	mov	ebx,dword [eax+TConsola.handle]
	mov	ecx,dword [eax+TConsola.buffer]
	mov	edx,dword [eax+TConsola.longitud]
	push	byte 4
	pop	esi
	sys_pwrite
	pop	eax
	ret	

.IrXY:				; eax=PConsola, bh=x, bl=y, ebx<=offset
	push	eax
	mov	esi,eax
	mov	eax,ebx
	mul	byte [esi+TConsola.maxX]
	mov	edi,eax
	movzx	eax,bh
	add	edi,eax
	shl	edi,1
	add	edi,dword [esi+TConsola.buffer]
	pop	eax
	mov	ebx,edi
	ret

.CurXY:				; eax=PConsola, ebx=xy
	push	eax
	push	ebx
	mov	eax,ebx
	mov	ebx,cur.X
	shr	eax,8
	and	eax,0xff
	call	DecToAsc
	pop	eax
	mov	ebx,cur.Y
	and	eax,0xff
	call	DecToAsc
	sys_write STDOUT,cur,12
	pop	eax
	retn
		
.Frase:				; eax=PConsola, bh=x, bl=y, ecx=strpas, dl=atributo
	push	eax
	push	edx
	push	ecx
	call	Consola.IrXY
	pop	esi
	movzx	ecx,byte [esi]
  .ciclo:
	mov	ah,byte [esp]
	inc	esi
	mov	al,byte [esi]
	mov	word [ebx],ax
	inc	ebx
	inc	ebx
	dec	ecx
	jnz	.ciclo
	pop	edx
	pop	eax
	ret

.Caracter:			; eax=PConsola, bh=x, bl=y, ch=color, cl=caracter, edx=cuantos
	push	eax
	push	ecx
	push	edx
	call	Consola.IrXY
	pop	ecx
	pop	eax
  .ciclo1:	
	mov	word [ebx],ax
	inc	ebx
	inc	ebx
	dec	ecx
	jnz	.ciclo1	
	pop	eax
	ret

.Rectangulo:			; eax=PConsola, bh=x, bl=y, ch=tx, cl=ty, dh=atributo, dl=caracter
	push	eax
	push	ebx
	push	ecx
	push	edx
  .ciclo2:	
	mov	ecx,dword [esp]
	mov	edx,dword [esp+4]
	shr	edx,8
	and	edx,0xff
	mov	ebx,dword [esp+8]
	call	Consola.Caracter
	inc	byte [esp+8]
	dec	byte [esp+4]
	jnz	.ciclo2	
	add	esp,3*4
	pop	eax
	ret
	
.TeclaApretada 			;eax=PConsola, ebx<=0 no tecla
	push	eax
	mov	dword [eax+TConsola.poll+Tpollfd.fd],STDIN
	mov	word [eax+TConsola.poll+Tpollfd.events],POLLIN
	lea	ebx,[eax+TConsola.poll]
	xor	ecx,ecx
	mov	eax,168
	mov	edx,ecx
	inc	ecx
	int	byte 0x80
	mov	ebx,eax
	pop	eax
	retn

.ObtenerTecla 			;eax=PConsola, ebx<=tecla
	push	eax
	push	eax
	sys_read STDIN,esp,4
	pop	ebx
	pop	eax
	retn

vcsa	db	"/dev/vcsa",EOL	
vcsa0   db      "/dev/vcsa0",EOL
str ErAbrirArchivo,{"Imposible abrir /dev/vcsa",__n}
str cur_salvar, {0x1b,"[s"}
str cur_restaurar, {0x1b,"[u"}
cur:	db 0x1b
	db "["
.Y:	dd 0
	db ";"
.X:	dd 0
	db "H"
%endif