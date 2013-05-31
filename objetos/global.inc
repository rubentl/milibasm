%include "system.inc"

%macro  str     2
%1      db      %2
long_ %+ %1      equ     $-%1
%endmacro
%macro  strpas	2
%1	db	(%%f-$)-1,%2
%%f:
%endmacro
%macro Itoa	2
	mov	eax,%1
	mov	ebx,%2
	call	HexToAsc
%endmacro
%macro 	InitCiclos 1
	rdtsc
	mov	%1,eax
	cld
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
%endmacro
%macro	DoneCiclos 1
	clc
	rdtsc
	sub	eax,%1
	sub	eax,byte 15
%endmacro
%macro	DameTecla 1
	call	TeclaApretada
	test	eax,eax
	jz	%1
	call	ObtenerTecla	
%endmacro
	
struc   TLista
.primero        resd    1
.ultimo      	resd    1
.actual		resd	1
.contador    	resd    1
endstruc

struc   TNodo
.anterior       resd    1
.siguiente      resd    1
endstruc

struc	TNodoMemoria
.anterior	resd	1
.siguiente	resd	1
.tamano		resd	1
endstruc

struc	TMemoria
.libre_primero		resd	1
.libre_ultimo		resd	1
.libre_actual		resd	1
.libre_contador		resd	1
.ocupado_primero	resd	1
.ocupado_ultimo		resd	1
.ocupado_actual		resd	1
.ocupado_contador	resd	1
.flags		resd	1
.heap		resd	1
.tamano		resd	1
endstruc
	
%assign Compactado	0x2
%assign CompactadoMask  0xfffffffd

struc	pollfd
.fd	resd	1
.events	resw	1
.revent resw	1
endstruc

 
;códigos de comando
%assign cmNulo		0x00
%assign	cmGuardar	0x01
%assign cmImprimir	0x02
%assign cmBloquePrincipio	0x03
%assign cmBloqueFin	0x04
%assign cmRedibujar	0x05
%assign cmContenidos	0x06
%assign cmSobre		0x07
%assign	cmIndice	0x08
%assign cmLenguaje	0x09
%assign	cmMenu		0x0a
%assign	cmSalir		0x0b
%assign	cmNuevo		0x0c
%assign cmAbrir		0x0d
%assign cmCerrar	0x0e

%assign POLLIN		0x0001

%assign	TCL_ESC	0x1b
%assign	TCL_a	0x61
%assign	TCL_b	0x62
%assign	TCL_c	0x63
%assign	TCL_d	0x64
%assign	TCL_e	0x65
%assign	TCL_f	0x66
%assign	TCL_g   0x67
%assign	TCL_h	0x68
%assign	TCL_i	0x69
%assign	TCL_j	0x6a
%assign	TCL_k	0x6b
%assign	TCL_l	0x6c
%assign	TCL_m	0x6d
%assign	TCL_n	0x6e
%assign	TCL_gn	0xf1
%assign	TCL_o	0x6f
%assign	TCL_p	0x70
%assign	TCL_q	0x71
%assign	TCL_r	0x72
%assign	TCL_s	0x73
%assign	TCL_t	0x74
%assign	TCL_u	0x75
%assign	TCL_v	0x76
%assign	TCL_w	0x77
%assign	TCL_x	0x78
%assign	TCL_y	0x79
%assign	TCL_z	0x7a
%assign	TCL_A	0x41
%assign	TCL_B	0x42
%assign	TCL_C	0x43
%assign	TCL_D	0x44
%assign	TCL_E	0x45
%assign	TCL_F	0x46
%assign	TCL_G   0x47
%assign	TCL_H	0x48
%assign	TCL_I	0x49
%assign	TCL_J	0x4a
%assign	TCL_K	0x4b
%assign	TCL_L	0x4c
%assign	TCL_M	0x4d
%assign	TCL_N	0x4e
%assign	TCL_GN	0xd1
%assign	TCL_O	0x4f
%assign	TCL_P	0x50
%assign	TCL_Q	0x51
%assign	TCL_R	0x52
%assign	TCL_S	0x53
%assign	TCL_T	0x54
%assign	TCL_U	0x55
%assign	TCL_V	0x56
%assign	TCL_W	0x57
%assign	TCL_X	0x58
%assign	TCL_Y	0x59
%assign	TCL_Z	0x5a
%assign TCL_1	0x31
%assign TCL_2	0x32
%assign TCL_3	0x33
%assign TCL_4	0x34
%assign TCL_5	0x35
%assign TCL_6	0x36
%assign TCL_7	0x37
%assign TCL_8	0x38
%assign TCL_9	0x39
%assign TCL_0	0x30
%assign TCL_exclamacioni	0x21
%assign TCL_espacio	0x20
%assign TCL_comillas	0x22
%assign TCL_dolar	0x24
%assign TCL_porciento	0x25
%assign TCL_ampersan	0x26
%assign TCL_barrad	0x2F
%assign TCL_parentesisi	0x28
%assign TCL_parentesisd	0x29
%assign TCL_igual	0x3d
%assign TCL_interrogaciond	0x3f
%assign TCL_interrogacioni	0xbf
%assign TCL_exclamaciond	0xa1
%assign TCL_arroba	0x40
%assign TCL_cuadradillo	0x23
%assign TCL_barra	0x7c
%assign TCL_tabulador	0x09
%assign TCL_enter	0x0a
%assign TCL_retroceso	0x7f
%assign TCL_inicio	0x7e315b1b
%assign TCL_avpag	0x7e355b1b
%assign TCL_repag	0x7e365b1b
%assign TCL_fin		0x7e345b1b
%assign TCL_flechaar	0x00415b1b
%assign TCL_flechaab	0x00425b1b
%assign TCL_flechaiz	0x00445b1b
%assign TCL_flechade	0x00435b1b
%assign TCL_borrar	0x7e335b1b
%assign TCL_insertar	0x7e325b1b
%assign TCL_barrai	0x5c
%assign TCL_coma	0x2c
%assign TCL_punto	0x2e
%assign TCL_guion	0x2d
%assign TCL_puntocoma	0x3b
%assign TCL_dospuntos	0x3a
%assign TCL_guionbajo	0x5f
%assign TCL_llaved	0x7d
%assign TCL_llavei	0x7b
%assign TCL_corchetei	0x5b
%assign TCL_corcheted	0x5d
%assign TCL_por	0x2a
%assign TCL_mas	0x2b
%assign TCL_acentoa	0xe1
%assign TCL_acentoe	0xe9
%assign TCL_acentoi	0xed
%assign TCL_acentoo	0xf3
%assign TCL_acentou	0xfa
%assign TCL_acentoA	0xc1
%assign TCL_acentoE	0xc9
%assign TCL_acentoI	0xcd
%assign TCL_acentoO	0xd3
%assign TCL_acentoU	0xda
%assign TCL_dieresisu	0xfc
%assign TCL_dieresisU	0xdc
%assign TCL_anguloi	0x3c
%assign	TCL_angulod	0x3e