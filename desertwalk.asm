; Tested with NASM version 2.15.04
;         and QEMU emulator version 5.1.0

[org 0x7c00]

Start:
    ; Get system time
    mov ah, 0x00
    int 0x1a
    ; Set initial screen pos to time values
    mov [ScreenX], dl
    mov [ScreenY], dh
    call UpdatePyramids ; Also clears screen
    ; Set initial cursor/player position
    mov dl, 40
    mov dh, 12
    call SetCursorPos
    call DrawPlayer
    call DrawPyramids
    call PrintScreenCoords
Loop:
    ; Get keyboard press
    mov ah, 0x00
    int 0x16
CheckW:
    cmp al, "w"
    jne CheckA
    dec dh       ; Update player pos
    cmp dh, 0xff ; If player was previously at top, wrap to bottom of screen
    jne Moved
    mov dh, 24
    ; Update screen pos
    mov bl, [ScreenY]
    dec bl
    mov [ScreenY], bl
    call UpdatePyramids
    jmp Moved
CheckA:
    cmp al, "a"
    jne CheckS
    dec dl       ; Update player pos
    cmp dl, 0xff ; If player was previously at left, wrap to right of screen
    jne Moved
    mov dl, 79
    ; Update screen pos
    mov bl, [ScreenX]
    dec bl
    mov [ScreenX], bl
    call UpdatePyramids
    jmp Moved
CheckS:
    cmp al, "s"
    jne CheckD
    inc dh     ; Update player pos
    cmp dh, 25 ; If player was previously at bottom, wrap to top of screen
    jne Moved
    mov dh, 0
    ; Update screen pos
    mov bl, [ScreenY]
    inc bl
    mov [ScreenY], bl
    call UpdatePyramids
    jmp Moved
CheckD:
    cmp al, "d"
    jne Draw
    inc dl      ; Update player pos
    cmp dl, 80  ; If player was previously at right, wrap to left of screen
    jne Moved
    mov dl, 0
    ; Update screen pos
    mov bl, [ScreenX]
    inc bl
    mov [ScreenX], bl
    call UpdatePyramids
    ; Fall through to Moved
Moved:
    mov al, " " ; Clear old position
    mov cx, 1
    call WriteChar
    call SetCursorPos
Draw:
    call DrawPlayer
    call DrawPyramids
    call PrintScreenCoords
    jmp Loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Functions

%include "lib.asm"

; equ is for defining a named constant
PERSON equ "%" ; What to draw the player as

DrawPlayer: ; Draw player at current cursor position
            ; Cursor position does not move
    push ax
    push cx
    mov al, PERSON
    mov cx, 1
    call WriteChar
    pop cx
    pop ax
    ret

DrawPyramids: ; Draw both pyramids
    push ax
    mov ax, Pyramid0
    call DrawPyramid
    mov ax, Pyramid1
    call DrawPyramid
    pop ax
    ret

DrawPyramid: ; Draw the pyramid having data at address ax
    ; Get bottom left coord of pyramid in (dl, dh)
    push bx
    push cx
    push dx
    ; Check if invisible
    mov bx, ax
    add bx, PY_OFFSET_VISIBLE
    mov cl, [bx]
    cmp cl, 0
    je DrawPyramid_Done ; Pyramid is invisible
    mov bx, ax
    add bx, PY_OFFSET_X
    mov dl, [bx]
    mov bx, ax
    add bx, PY_OFFSET_Y
    mov dh, [bx]
    call SetCursorPos
    ; Get pyramid height in bx
    mov bx, ax
    add bx, PY_OFFSET_HEIGHT
    mov bl, [bx]
DrawPyramid_Row:
    mov al, "/"
    call TeletypeOutput
    mov cl, bl
    shl cl, 1 ; Multiply by 2
    sub cl, 2
DrawPyramid_Brick:
    cmp cl, 0
    je DrawPyramid_BrickDone
    mov al, "_"
    call TeletypeOutput
    dec cl
    jmp DrawPyramid_Brick
DrawPyramid_BrickDone:
    mov al, "\"
    call TeletypeOutput
    dec bl
    cmp bl, 0
    je DrawPyramid_Done
    inc dl
    dec dh
    call SetCursorPos
    jmp DrawPyramid_Row
DrawPyramid_Done:
    pop dx
    pop cx
    pop bx
    ret

UpdatePyramids: ; Populate pyramid structs based on ScreenX and ScreenY
                ; Also clears screen
    push ax
    push bx

    ; P0 is visible if ScreenX is odd
    mov al, [ScreenX]
    and al, 0x1
    mov bx, Pyramid0
    add bx, PY_OFFSET_VISIBLE
    mov [bx], al

    ; P1 is visible if ScreenY is odd
    mov al, [ScreenY]
    and al, 0x1
    mov bx, Pyramid1
    add bx, PY_OFFSET_VISIBLE
    mov [bx], al

    ; Set P0 height
    mov al, [ScreenX]
    mov bl, 13
    mul bl ; Result is in ax
    mov bl, 12
    div bl ; Dividend in ax. Quotient in al. Remainder in ah.
    ;add ah, 4
    mov bx, Pyramid0
    add bx, PY_OFFSET_HEIGHT
    mov [bx], ah

UpdatePyramids_Done:
    pop bx
    pop ax
    call ClearScreen ; Remove existing pyramids
    ret

PrintScreenCoords: ; Print ScreenX/Y values in top left as hex bytes (0x__)
    push ax
    push dx
    mov dl, 0
    mov dh, 0
    call SetCursorPos
    mov dl, [ScreenX]
    call PrintByteHex
    mov dl, 0
    mov dh, 1
    call SetCursorPos
    mov dl, [ScreenY]
    call PrintByteHex
    pop dx
    pop ax
    ; Re-set cursor position (dl and dh were restored but not cursor pos)
    call SetCursorPos
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Variables

; dw is 2 bytes
; dd is 4 bytes

; The world is a grid of screens that can be walked around
ScreenX: db 0
ScreenY: db 0

Pyramids:
Pyramid0: ; Base address of pyramid "struct"
Pyramid_Start:
Pyramid_Visible: db 1 ; Boolean value. 0 means not visible.
Pyramid_X:       db 5
Pyramid_Y:       db 20
Pyramid_Height:  db 5
Pyramid_End:
; Space for second pyramid
Pyramid1:
    db 1
    db 41
    db 23
    db 14

; Add offset to base address to get address of member
PY_OFFSET_VISIBLE equ Pyramid_Visible - Pyramid_Start
PY_OFFSET_X       equ Pyramid_X       - Pyramid_Start
PY_OFFSET_Y       equ Pyramid_Y       - Pyramid_Start
PY_OFFSET_HEIGHT  equ Pyramid_Height  - Pyramid_Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Boilerplate

times 510 - ($-$$) db 0 ; Pad the remaining of the first 510 bytes with 0
dw 0xaa55               ; Magic bytes required at end of boot sector
