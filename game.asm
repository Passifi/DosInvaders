    BITS 16
    ORG 0x100

Start:
    ;init video 
    ;
    call InitVideo
    call InstallKB
.gameLoop: 
    call WaitFrame
    cmp byte [Quit],1
    jnz .gameLoop
		MOV	AX, 0x03
		INT	0x10
	

MoveDir: DW 0
Quit: DB 0
%include "kb.asm"
%include "video.asm"


