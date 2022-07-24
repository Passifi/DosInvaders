		; tell NASM we want 16-bit assembly language
		BITS	16
		ORG	0x100				; DOS loads us here
Start:		CALL	InstallKB
		CALL	InitVideo
		MOV BX, 0x1000
		MOV CX, 0xffff
		mov DX, 0x00
		
.gameLoop:	CALL	WaitFrame
		call FillScreen
		inc Byte [Counter]
		CMP Byte [Counter],10
		jnz .notReached 
		inc word [posX]
		mov word [Counter],0
.notReached:
		call DrawPixel
		CMP	BYTE [Quit], 1
		JNE	.gameLoop			; loop if counter > 0
		CALL	RestoreVideo
		CALL	RestoreKB
		; exit
		MOV	AX, 0x4C00
		INT	0x21

Quit:		DB	0
posX:	DW 0

%include "kb.asm"
%include "video.asm"
; start with automated movement !! 
; then try and control it ! 
; then sprite drawing ! 

