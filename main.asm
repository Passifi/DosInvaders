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
		call SetDirection
		call DrawPixel
		CMP	BYTE [Quit], 1
		JNE	.gameLoop			; loop if counter > 0
		CALL	RestoreVideo
		CALL	RestoreKB
		; exit
		MOV	AX, 0x4C00
		INT	0x21


Timer:

	CMP Byte [Counter],WaitInterval
	jnz .notReached 
	inc word [posX]
	mov word [Counter],0
.notReached:
	ret

SetDirection: ; reset position values 
	mov ax, [posY]
	mov bl, [controlByte]
	cmp bl, 72
	jne .checkLeft
	sub ax,1
	mov word [posY],ax
	jmp .done 
.checkLeft:
	mov ax,[posX]
	cmp bl, 75
	jne .checkRight
	sub ax,1
	mov word [posX],ax 
	jmp .done 
.checkRight:
	cmp bl, 77
	jne .checkDown
	add ax,1
	mov word [posX],ax
	jmp .done 
.checkDown:
	mov ax,[posY]
	cmp bl, 78
	jne .done
	add ax,1
	mov word [posY],ax
	
.done
	ret 


Quit:		DB	0
posX:	DW 0
posY: DW 0
WaitInterval equ 0x05
controlByte: DB 0

%include "kb.asm"
%include "video.asm"
; start with automated movement !! 
; then try and control it ! 
; then sprite drawing ! 

