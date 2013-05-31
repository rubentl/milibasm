%ifndef _Ventana
%define _Ventana
%include "Marco.asm"
%include "Consola.asm"
%include "Rect.asm"
	
Dibujar_Ventana:		; eax=PConsola se preserva ebx=PVentana se preserva
	push	ebp
	push	eax
	mov	ebp,ebx
	mov	eax,ebx
	call    Rect.Copiar
	mov	eax,dword [esp]
	mov	edi,ebp
	mov	dh,byte [edi+TVentana.paleta]
	mov	dl," "
	call	Consola.Rectangulo
	mov	eax,ebp
	call	Rect.Copiar
	mov	eax,dword [esp]
	mov	edi,ebp
	mov	dh,byte [edi+TVentana.paleta]
	mov	dl,byte [edi+TVentana.marco]
	cmp	dl,mcDoble
	jne	Dibujar_Ventana.mcSimple
	call	MarcoDoble
	jmp	Dibujar_Ventana.Salir
.mcSimple:
	call	MarcoSimple
.Salir:
	mov	ebx,ebp
	pop	eax
	pop	ebp
	retn
%endif