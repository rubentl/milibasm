%include "libasm.inc"

%assign  Heap_size 1024*2048
	
bits 32

CODESEG
START
	mov	eax,mem
	mov	ebx,heap
	mov	ecx,Heap_size
	call	Memoria.Iniciar
	LocalizarMem TConsola_size
	mov	dword [consola],eax
	call	Consola.Iniciar	
	;; ============================================
	call	Obtener_Parametros
.ciclo_principal:	
	call	Dibujar_Titulo
	call	Obtener_Ordenes
	call	Ejecutar_Ordenes
	call	Presentar_Resultados
;	jmp	.ciclo_principal		

.ciclo:	
	DameTecla eax,.ciclo

	mov	eax,dword [consola]
	call	Consola.Hecho
	sys_exit 0
	
Obtener_Ordenes:
	retn
Ejecutar_Ordenes:
	retn
Presentar_Resultados:
	retn
	
Cadena:				; eax=strpas se preserva ebx<=buffer del resultado
	movzx	ecx,byte [eax]	
	push	eax
.ciclo:	
	cmp	byte [eax+ecx],0x20
	jne	short Cadena.empezamos
	dec	ecx
	jmp	short Cadena.ciclo
.empezamos:
	inc	ecx
	push	ecx
	LocalizarMem ecx
	mov	ebx,eax
	mov	eax,dword [esp+4]
	mov	ecx,dword [esp]
	call	MoverMem
	pop	ecx
	dec	ecx
	mov	byte [ebx],cl
	pop	eax
	retn
	
Dibujar_Titulo:
	mov	eax,dword [consola]
	call	Consola.Limpiar
	mov	ebx,0x0101
	mov	ecx,sqlfacil
	mov	dl,0x0b
	push	ebx
	call	Consola.Frase
	mov	edi,sqlfacil
	pop	ebx
	mov	dl,byte [edi]
	add	bh,dl
	add	bh,0xa
	mov	ecx,usuario
	mov	dl,0x0e
	push	ebx
	call	Consola.Frase
	mov	edi,usuario
	pop	ebx
	mov	dl,byte [edi]
	add	bh,dl
	push	ebx
	mov	ecx,Nombre_Usuario
	mov	dl,0x0c
	call	Consola.Frase
	pop	ebx
	mov	esi,Nombre_Usuario
	mov	dl,byte [esi]
	add	bh,dl
	push	ebx
	mov	ecx,base_de_datos
	mov	dl,0x0e
	call	Consola.Frase
	pop	ebx
	mov	esi,Nombre_Datos
	mov	dl,byte [esi]
	add	bh,dl
	mov	ecx,Nombre_Datos
	mov	dl,0x0c
	call	Consola.Frase
	call	Consola.Volcado
	retn
	
Obtener_Parametros:
	push	ebp
	LocalizarMem TVentana_size
	mov	ebp,eax
	mov	bx,0x0505
	mov	cx,0x2e06
	call	Rect.Asignar
	mov	ebx,ebp
	mov	dword [ebp+TVentana.paleta],0x1b1c1a1f
	mov	byte [ebx+TVentana.marco],mcDoble
	mov	eax,dword [consola]
	call	Dibujar_Ventana
	mov	eax,ebp
	call	Rect.Copiar
	add	bx,0x0402
	mov	eax,dword [consola]
	mov	ecx,txt_usuario
	mov	esi,ebp
	mov	dx,word [ebp+TVentana.paleta]
	shr	dx,8
	call	Consola.Frase
	mov	eax,ebp
	call	Rect.Copiar
	add	bx,0x0403
	mov	eax,dword [consola]
	mov	ecx,txt_contrasena
	mov	esi,ebp
	mov	dx,word [ebp+TVentana.paleta]
	shr	dx,8
	call	Consola.Frase
	mov	eax,ebp
	call	Rect.Copiar
	add	bx,0x0404
	mov	eax,dword [consola]
	mov	ecx,txt_base_de_datos
	mov	esi,ebp
	mov	dx,word [ebp+TVentana.paleta]
	shr	dx,8
	call	Consola.Frase
	mov	eax,ebp
	call	Rect.Copiar
	add	bx,0x1402
	mov	eax,dword [consola]
	mov	esi,ebp
	mov	edx,dword [esi+TVentana.paleta]
	shr	edx,8
	mov	esi,dword [usuario]
	xor	edi,edi
	call	EditLinea
	mov	eax,ebp
	call	Rect.Copiar
	add	bx,0x1403
	mov	eax,dword [consola]
	mov	esi,ebp
	mov	edx,dword [ebp+TVentana.paleta]
	shr	edx,8
	mov	esi,dword [contrasena]
	xor	edi,edi
	call	EditLinea
	mov	eax,ebp
	call	Rect.Copiar
	add	bx,0x1404
	mov	eax,dword [consola]
	mov	esi,ebp
	mov	edx,dword [ebp+TVentana.paleta]
	shr	edx,8
	mov	esi,dword [db]
	xor	edi,edi
	call	EditLinea	
	call	Consola.Volcado
	LiberarMem ebp
	pop	ebp
	retn
		
strpas  txt_sqlfacil,"SQL fácil"
strpas	txt_usuario,"Usuario: "
strpas  txt_contrasena,"Contraseña: "
strpas  txt_base_de_datos,"Base de Datos: "
		
%include "Ventana.asm"
%include "EditLinea.asm"

UDATASEG
mem	resb	TMemoria_size
heap	resb	Heap_size
consola	resd	1
contrasena resd 1
usuario resd	1
db	resd	1

END