%ifndef _HexToAsc
%define _HexToAsc

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
%endif