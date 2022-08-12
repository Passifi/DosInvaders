		; tell NASM we want 16-bit assembly language
		BITS	16
		ORG	0x100				; DOS loads us here
Start:		CALL	InstallKB
		CALL	InitVideo
		MOV BX, 0x1000
		MOV CX, 0xffff
		mov DX, 0x00
		
.gameLoop:	
		CALL	WaitFrame
		call FillScreen
		call calcPlayerPos
		
		inc Byte [Counter]
		call SetDirection
		mov cx, [playerScreenPos]
		call BlitSprite
		mov cx, [enemyScreenPos]
		call BlitSprite
		CMP	BYTE [Quit], 1
		JNE	.gameLoop			; loop if counter > 0
		CALL	RestoreVideo
		CALL	RestoreKB
		; exit
		MOV	AX, 0x4C00
		INT	0x21


Timer: ; wait for time set in WaitInterval, currently also handles  posX update which I think is just legacy 

	CMP Byte [Counter],WaitInterval
	jnz .notReached 
	inc word [posX] 
	mov word [Counter],0
.notReached:
	ret

SetDirection: ; takes in the controlByte and changes position values may want to put this in a different folder
				; redesign 
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
	cmp bl, 80
	jne .done
	add ax,1
	mov word [posY],ax
	
.done
	ret 

calcPlayerPos:
	mov ax, [posY]
	mov cx, [posY]
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl cx,1
	shl cx,1
	shl cx,1
	shl cx,1
	shl cx,1
	shl cx,1
	add ax,cx
	add ax,[posX]
	mov [playerScreenPos],ax 
ret 

calcEnemyPos:
	mov ax, [ePosY]
	mov cx, [ePosY]
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl ax,1  
	shl cx,1
	shl cx,1
	shl cx,1
	shl cx,1
	shl cx,1
	shl cx,1
	add ax,cx
	add ax,[ePosX]
	mov [enemyScreenPos],ax 
ret 



Quit:		DB	0
playerScreenPos:	DW 0
posX:	DW 12
posY: DW 180
WaitInterval equ 0x05
controlByte: DB 0
keyIntVal: DW 0
enemyScreenPos: DW 0
ePosX: dw 160
ePosY: dw 10

%include "kb.asm"
%include "video.asm"
; start with automated movement !! 
; then try and control it ! 
; then sprite drawing ! 

