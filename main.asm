%macro calcPos 3
	mov ax, [%2]
	mov cx, [%2]
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
	add ax,[%1]
	mov [%3],ax 
%endmacro

%macro MoveEnemies 0 
	push si 
	push ax
	mov si,0
	mov ax,[enemies+si]
	inc ax 
	mov [enemies+si],ax

	add si,4
	mov ax,[enemies+si]
	inc ax 
	mov [enemies+si],ax
	pop ax	
	pop si
%endmacro
	
	
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
		call 	Render 
		inc Byte [Counter]
		mov ax,[playerScreenPos]
		mov [clearPlayerPos],ax 
		
		;call calcPlayerPos
		calcPos posX,posY,playerScreenPos
		call SetDirection
		call EnemyBlock ; handles enemy Logic clearly needs a better name 
		call moveShot 
		call calcShotPos
		

		CMP	BYTE [Quit], 1
JNE	.gameLoop			; loop if counter > 0
		CALL	RestoreVideo
		CALL	RestoreKB
		; exit
		MOV	AX, 0x4C00
		INT	0x21
;1e7



EnemyBlock: 

	CMP Byte [Counter],WaitInterval
	jnz .notReached 
	mov ax,[enemyScreenPos]
	mov [oldEnemiePos],ax 
	MoveEnemies
	call EnemyHandler
	mov word [Counter],0
.notReached:
	ret

SetDirection: ; current issue sometimes a keystroke is ignored 
				 
	mov bl, [controlByte]
	cmp bl, 72 
	jne .checkLeft
	dec word [posY]
	jmp .done 

.checkLeft:
	cmp bl, 75
	jne .checkRight
	dec word [posX]
	jmp .done 
.checkRight:
	cmp bl, 77
	jne .checkDown
	inc word [posX]
	jmp .done 
.checkDown:
	cmp bl, 80
	jne .done
	inc word [posY]	
.done:
	ret 

spawnShot: 

	mov ax,[posX]
	mov bx,[posY]
	mov [shotPosX],ax
	mov [shotPosY],bx
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


calcShotPos:
	mov bx, 0
	mov ax, [processedShotPos]
	mov [oldShotPos],ax
	mov ax,[cs:shots+bx]
	mov [shotPosX],ax 
	add bx,2 
	mov ax,[cs:shots+bx]
	mov [shotPosY],ax  
	calcPos shotPosX,shotPosY,processedShotPos
	ret


;spawnShot 	
moveShot:
	mov ax,[shots+2]
	add ax,[shotMomentum]
	mov [shots+2],ax 
ret 
;calculateShotPositon for ScreenArray ;  
;Collision 
;after render Logic 
; move current Shot position into into ClearShotPos 



EnemyHandler:
	
	mov si,0
	mov bl,3

.loop:
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
	
	
ret 

.data
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
shotPointer: dw shots,shots+4,shots+8,shots+12
shots: dw 12,180,12,180,23,180,0,0
shotIndexStart: db 0
shotIndexEnd: db 3

shotPosX: dw 10
shotPosY: dw 180
shotMomentum: dw -2
processedShotPos: dw 0
oldShotPos: dw 0 
clearPlayerPos: dw 0
clearEnemyPos: dw 0,0 



enemieArrLength: db 2
%include "video.asm"
%include "kb.asm"


