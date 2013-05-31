%ifndef _NPalabras
%define _NPalabras

NPalabras: ;eax=*strpas bl=caracter separador eax<=número de palabras

	  mov esi,eax         ;esi = *strpas
	  xor ecx,ecx
	  inc esi	      
	  mov cl,byte [eax]   ;ecx = longitud *strpas
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
.ciclo2:  
	  inc edi
	  cmp bl,byte [esi+edi]
	  je .salirciclo2
	  cmp edi,ecx
	  ja .salirciclo2
	  jmp .ciclo2
.salirciclo2:
	  cmp edi,ecx
	  jbe .ciclo1
	  mov eax,edx
	  retn
%endif