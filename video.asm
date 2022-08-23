SpriteWitdth equ 16
ScreenWidth equ 320
ScreenHeight equ 200
Ship:		INCBIN	"ship.dat"
ScrBase: DW 0
Color: DW 0x000f
Counter: DW 0x0
WaitFrame:	PUSH	DX
		; port 0x03DA contains VGA status
		MOV	DX, 0x03DA
.waitRetrace:	IN	AL, DX	
					; read from status port
		; bit 3 will be on if we're in retrace
		TEST	AL, 0x08			; are we in retrace?
		JNZ	.waitRetrace
		
.endRefresh:	IN	AL, DX
		TEST	AL, 0x08			; are we in refresh?
		JZ	.endRefresh
		POP DX
		RET

; NOTE: makes ES point to video memory!
InitVideo:	; set video mode 0x13
		MOV	AX, 0x13
		INT	0x10
                ; make ES point to the VGA memory
                MOV	AX, 0xA000
		MOV	ES, AX
		RET

RestoreVideo:	; return to text mode 0x03
		MOV	AX, 0x03
		INT	0x10
		RET
Render: 
	mov cx, [clearPlayerPos]
	call ClearSprite
	mov cx,[playerScreenPos]
	call BlitSprite
	mov cx,[oldEnemiePos]
	call ClearSprite
	mov cx,[enemyScreenPos]
	call BlitSprite
ret 

ClearSprite:
	push di 
	mov di,cx
	
	mov dl,0
.loop: 
		mov cx,SpriteWitdth
		mov ax,0xff
		rep STOSB
		mov ax,di 
		add ax,ScreenWidth-SpriteWitdth
		mov di,ax 
		inc dl
		cmp dl, SpriteWitdth
		jnz .loop
	pop di
		RET

;so in order to change this to a spriteBlit I think all I need to do is to load in 
;data instead of one value in ax this means a different copy command(which I do think exists if I recall correcly)
;

BlitSprite:	
		push si 
		push di 
		mov si, Ship
		mov di,cx
		
		CLD					; increment
		MOV	CH, 0				; clear hi-counter
		MOV	DL, 0x10			; 16 rows
		MOV	CL, 0x08			; 8 word copies
.loop:							; increment
						; clear hi-counter
		; 16 rows
		MOV	CL, 0x08	
		rep movsw  ; mov data in ax cx times to position di
		dec DL
		jz .done 
		add di,304
		jmp .loop
		
.done:
		pop di
		pop si
		RET




clearScreen:	
		push di
		push si 
		mov di, 0 
		mov dx,0
	.loop: 
		mov cx,ScreenWidth/2
		mov ax,0xff
		rep STOSW ; mov data in ax cx times to position di 
		mov ax,di ; moves di up by one line of screen space
		add ax,ScreenWidth
		mov di,ax 
		inc dx
		cmp dx,ScreenHeight 
	jnz .loop
		pop si 
		pop di
RET

DrawShot:	
		push si 
		push di
		mov di, [processedShotPos]
		mov si,24
		mov dl,0
.loop: 
		mov cx,2
		mov ax,[Color] 
		rep STOSB ; mov data in ax cx times to position di 
		mov ax,di ; moves di up by one line of screen space
		add ax,ScreenWidth-2
		mov di,ax 
		inc dl  
		cmp dl,8 
		jnz .loop
		pop di
		pop si
		RET

