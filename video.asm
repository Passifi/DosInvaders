; the VGA hardware is always in one of two states:
; * refresh, where the screen gets redrawn.
;            This is the state the VGA is in most of the time.
; * retrace, a relatively short period when the electron gun is returning to
;            the top left of the screen, from where it will begin drawing the
;            next frame to the monitor. Ideally, we write the next frame to
;            the video memory entirely during retrace, so each refresh is
;            only drawing one full frame
; The following procedure waits until the *next* retrace period begins.
; First it waits until the end of the current retrace, if we're in one
; (if we're in refresh this part of the procedure does nothing)
; Then it waits for the end of refresh.
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


FillScreen:
	mov di,[playerScreenPos]
	
	mov dl,0
.loop: 
		mov cx,40
		mov ax,0xff
		rep STOSB
		mov ax,di 
		add ax,280
		mov di,ax 
		inc dl
		cmp dl,40
		jnz .loop
		RET

;so in order to change this to a spriteBlit I think all I need to do is to load in 
;data instead of one value in ax this means a different copy command(which I do think exists if I recall correcly)
;

BlitSprite:	
		
		mov si, Ship;still not sure how this works 
		mov di,[playerScreenPos]
		
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
		; mov ax,di ; moves di up by one line of screen space
		; add ax,280
		; mov di,ax 
		; inc dl  
		; cmp dl,16 ; magic numbers are bad! here 40 stands for the height of the box
		; jnz .loop
.done
		RET




DrawBox:	
		
		mov di, [posX] ;still not sure how this works 
		mov si,[posX]
		mov dl,0
.loop: 
		mov cx,40 ;Magic number are bad here 40 stands for the width of the box! 
		mov ax,[Color] 
		rep STOSB ; mov data in ax cx times to position di 
		mov ax,di ; moves di up by one line of screen space
		add ax,280
		mov di,ax 
		inc dl  
		cmp dl,40 ; magic numbers are bad! here 40 stands for the height of the box
		jnz .loop
		RET

