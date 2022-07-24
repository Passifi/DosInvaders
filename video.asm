;;;
InitVideo:
    mov ax,0x13
    int 0x10
    mov ax, 0xA000
    mov es,ax 
    ret

blankScreen: ;color in bx 
    mov bx,0xf
    mov ax,0
.bankLoop:
    mov [es:ax], bx
    inc ax 
    cmp ax, 64000
    jnz .bankLoop 
ret

WaitFrame: Push DX
    MOV DX,  0x03da 
.waitRetrace: in al, dx 
    TEST al, 0x08
    JNZ .waitRetrace
.endRefresh: IN AL, DX
    TEST    al,0x08 
    JZ .endRefresh
    POP DX
    ret  


