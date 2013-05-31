%ifndef _Rect
%define _Rect

Rect:	
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
%endif