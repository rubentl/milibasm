%ifndef _DamePalabra
%define _DamePalabra

DamePalabra:                  ;eax=*strpas ebx=buffer cl=char dl=numero

	  and edx,0xff
	  and ecx,0xff
	  push edx            ;dword [esp+4] = numero
	  push ebx            ;dword [esp] = buffer
	  movzx ebx,cl        ;bl=char	  
          mov esi,eax         ;esi = *strpas
	  movzx ecx,byte [eax];ecx = longitud *strpas
	  inc esi
	  xor edx,edx         ;edx = contador
	  xor edi,edi         ;edi = i
.ciclo1:  
	  inc edi
	  cmp bl,byte [esi+edi]
	  jne .salirciclo1
	  cmp edi,ecx
	  ja .salirciclo1
	  jmp .ciclo1
.salirciclo1: 
	  cmp edi,ecx
	  ja .nocontador
	  inc edx
.nocontador:
	  mov eax,dword [esp+4]
	  cmp eax,edx
	  je .ciclo3
.ciclo2:  
	  inc edi
	  cmp bl,byte [esi+edi]
	  je .salirciclo2
	  cmp edi,ecx
	  ja .salirciclo2
	  jmp .ciclo2
.salirciclo2:
	  cmp edi,ecx
	  jne .ciclo1
.ciclo3:  
	  mov eax,dword [esp]
          push ecx
	  mov cl,byte [esi+edi]
	  mov byte [eax],cl
	  pop ecx
	  inc dword [esp]
	  inc edi
	  cmp byte [esi+edi],bl
	  je  .salirciclo3
	  cmp edi,ecx
	  ja .salirciclo3
	  jmp .ciclo3
.salirciclo3: 
	  pop eax
	  mov byte [eax],0
	  pop edx
	  retn
%endif