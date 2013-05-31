%ifndef _DentroDe
%define _DentroDe

DentroDe:			; al=caracter ebx=*char jc está dentro de *char
	clc
	xor	edx,edx
.DentroDe1:	
	mov	dl,byte [ebx]	
	test	edx,edx
	jz	short .salir
	inc	ebx
	cmp	eax,edx
	jne	short .DentroDe1
	stc
.salir:	
	retn	
%endif
