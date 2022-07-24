OldKBHandler: DW 0
OldKBSeg: DW 0

InstallKB: PUSH ES
    PUSH BX
    PUSH DX
    ; backup old KB interrupt 
    MOV ax, 0x3509
    int 0x21
    mov [OldKBHandler],BX
    mov [OldKBSeg],ES 
    mov ah,0x25
    mov dx, KBHandler 
    int 0x31
    pop dx
    pop BX
    pop es 
    ret 

RestoreKB: Push DX 
    PUSH DS
    mov ax,0x2509
    mov dx, [OldKBHandler]
    mov ds, [OldKBSeg]
    int 0x21
    pop ds
    pop dx
    ret 

DirTable: DB 72,75,77,80 
KBHandler: Push ax
    push SI
    in al,0x60
.testEsc: CMP al,0x01 
    jne .testDirs
    mov [Quit],al 
.testDirs: mov si,0
    mov ah,4
.testLoop: cmp al,[DirTable+SI]
    JE .writeDir
    INC SI
    DEC AH
    JNZ .testLoop
    JMP .done 
.writeDir: inc si  
    mov word [MoveDir],SI 
.done:
    out 0x20,al 
    pop si 

