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
	mov di,[posX]
	mov si,[posX]
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

DrawPixel:	
		
		mov di, [posX]
		mov si,[posX]
		mov dl,0
.loop: 
		mov cx,40
		mov ax,[Color]
		rep STOSB
		mov ax,di 
		add ax,280
		mov di,ax 
		inc dl
		cmp dl,40
		jnz .loop
		RET

