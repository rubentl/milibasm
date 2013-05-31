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
	mov	eax,dword [consola]
	mov	ebx,0x1010
	mov	ecx,0x0f01
	mov	edx,0x1A0A
	mov	esi,frase
	mov	edi,elprocedimiento
	call	EditLinea
	
	;; ===========================================
	call	Consola.Volcado
	
.ciclo:	
	DameTecla eax,.ciclo

	call	Consola.Hecho
	sys_exit 0

elprocedimiento:
	push	eax
	mov	ecx,eax
	mov	eax,dword  [consola]
	xor	ebx,ebx
	mov	edx,0x0f
	call	Consola.Frase
	pop	eax
	ret
	
strpas	frase,"EditLinea."

%include "Memoria.asm"
%include "Lista.asm"
%include "Consola.asm"
%include "Marco.asm"
%include "EditLinea.asm"
%include "DecToAsc.asm"
%include "HexToAsc.asm"
%include "MoverMem.asm"
						
UDATASEG
mem	resb	TMemoria_size
heap	resb	Heap_size
consola	resd	1
END