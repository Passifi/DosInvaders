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
		mov cx, [playerScreenPos]
		call ClearSprite
		call calcPlayerPos
		
		inc Byte [Counter]
		call SetDirection
		mov cx, [playerScreenPos]
		call BlitSprite
		
		call EnemyHandler
		call DrawShot
		CMP	BYTE [Quit], 1
		JNE	.gameLoop			; loop if counter > 0
		CALL	RestoreVideo
		CALL	RestoreKB
		; exit
		MOV	AX, 0x4C00
		INT	0x21
;1e7



Timer: 

	CMP Byte [Counter],WaitInterval
	jnz .notReached 
	call MoveEnemies
	mov word [Counter],0
.notReached:
	ret

SetDirection: ; current issue sometimes a keystroke is ignored 
				 
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
	
.done:
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

processShots:
	push BX
	mov bx,[shotIndexStart]
	shl bx 
	mov si,bx
	mov ax,[shots+si]
	mov [shotPos],ax
	inc si
	inc si 
	mov ax,[shots+si]
	mov [shotPos+2],ax 
	call calcShotPos
	call DrawShot
	


calcShotPos:
	mov ax, [shotPos+2]
	mov cx, [shotPos+2]
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
	add ax,[shotPos]
	mov [processedShotPos],ax 
ret 

MoveEnemies: 
	push si 
	mov si,0
	mov ax,[enemies+si]
	inc ax 
	mov [enemies+si],ax

	add si,4
	mov ax,[enemies+si]
	inc ax 
	mov [enemies+si],ax
	
	pop si
	ret 
	

EnemyHandler:
	
	mov si,0
	mov bl,3
.loop:

	mov cx,[oldEnemiePos] ; erease enemy sprites 
	call ClearSprite
	mov cx,[oldEnemiePos+2] 
	call ClearSprite

	call Timer 
	; rebuild to loop 
	; firstEnemy
	mov word ax,  [enemies + si]
	mov  word [ePosX],ax
	inc si
	inc si 
	mov word ax,[enemies + si]
	mov word [ePosY],ax
	call calcEnemyPos
	mov word cx, [enemyScreenPos]
	mov [oldEnemiePos],cx 
	call BlitSprite
	; secondEnemy
	inc si
	inc si
	mov word ax,[enemies + si]
	mov word [ePosX],ax
	inc si
	inc si 
	mov word ax,[enemies + si]
	mov word [ePosY],ax
	call calcEnemyPos
	mov word cx, [enemyScreenPos]
	mov [oldEnemiePos+2],cx
	call BlitSprite
	
	
	

	
ret 

Quit:		DB	0
playerScreenPos:	DW 0
posX:	DW 12
posY: DW 180
WaitInterval equ 0x05
controlByte: DB 0
keyIntVal: DW 0
enemyScreenPos: DW 0
ePosX: dw 0
ePosY: dw 0
enemies: dw 160,122,160,12
oldEnemiePos: dw 0,0
shots: dw 0,0,0,0,0,0,0,0
shotIndexStart: db 0
shotIndexEnd: db 0

shotPos: dw 0,0
processedShotPos: dw 0,-1,-1,-1,-1


enemieArrLength: db 2
%include "video.asm"
%include "kb.asm"


