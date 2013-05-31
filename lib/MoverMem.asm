%ifndef _MoverMem
%define _MoverMem

MoverMem:			; eax=fuente, ebx=destino, ecx=longitud
	mov	esi,eax
	mov	edi,ebx
	mov	eax,ecx
	cld
	and	eax,3
	shr	ecx,2
	rep	movsd
	mov	ecx,eax
	rep	movsb
	retn
%endif