OldKBHandler:	DW	0
OldKBSeg:	DW	0

InstallKB:	PUSH	ES
		PUSH	BX
		PUSH	DX
		; backup old KB interrupt
		MOV	AX, 0x3509			; get interrupt 9
		INT	0x21
		MOV	[OldKBHandler], BX
		MOV	[OldKBSeg], ES
		; install new KB interrupt
		MOV	AH, 0x25
		MOV	DX, KBHandler
		INT	0x21
		POP	DX
		POP	BX
		POP	ES
		RET

RestoreKB:	PUSH	DX
		PUSH	DS
		MOV	AX, 0x2509
		MOV	DX, [OldKBHandler]
		MOV	DS, [OldKBSeg]
		INT	0x21
		POP	DS
		POP	DX
		RET

KBHandler:	PUSH	AX
		push si 
		
		mov byte [controlByte],0 ; reset control byte
		 
		IN	AL, 0x60			; get key event
		cmp al, 0x01
		jne .escTest
		call spawnShot
		jmp .done
	.escTest:	
		CMP	AL, 0x01			; ESC pressed?
		JNE	.testDirs
		MOV	[Quit], AL
.testDirs: MOV si,0
	mov ah,4
.testLoop: cmp al, [movDir+SI]
	JE .writeCommand
	inc si 
	dec ah 
	jnz .testLoop 
	jmp .done

.writeCommand:
	mov byte [controlByte],al 
	
.done:		MOV	AL, 0x20			; ACK
		OUT	0x20, AL			; send ACK
 		pop si
		POP	AX
		
		IRET

movDir: DB 72,75,77,80 ; up left right down