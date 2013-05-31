%ifndef _DecToAsc
%define _DecToAsc

DecToAsc:                    ;eax=hex, ebx=Buffer del string

	xor	ecx,ecx
	mov	edi,ebx
    mov	ebx,10
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
%endif
