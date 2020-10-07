; General routines

PrintByteHex:                     ; Print byte in dl as 0x__
    push ax
    push cx
    ; Output the fixed "0x" string
    mov al, "0"
    call TeletypeOutput
    mov al, "x"
    call TeletypeOutput
    ; Work with high 4 bits of dl in cl reg
    mov cl, dl
    shr cl, 4
    mov ch, 0                     ; Track how many nibbles we have
                                  ;  outputted already
PrintByteHex_Nibble:
    cmp cl, 10
    jl PrintByteHex_OutputNumeral
PrintByteHex_OutputLetter:
    add cl, 55                    ; ASCII "A" is 65
    mov al, cl
    call TeletypeOutput
    inc ch                        ; Outputted a nibble
    jmp PrintByteHex_CheckIfDone
PrintByteHex_OutputNumeral:
    add cl, 48                    ; ASCII "0" is 48
    mov al, cl
    call TeletypeOutput
    inc ch                        ; Outputted a nibble
                                  ; Fall through to CheckIfDone
PrintByteHex_CheckIfDone:
    cmp ch, 2
    je PrintByteHex_Done
    mov cl, dl
    and cl, 0x0f
    jmp PrintByteHex_Nibble
PrintByteHex_Done:
    pop cx
    pop ax
    ret

TeletypeOutput:  ; Output the char in al at cursor pos
                 ; Cursor pos gets advanced (forward or to next line)
                 ; Page number is fixed at 0
    push ax
    push bx
    mov ah, 0x0e ; TTY
    mov bh, 0    ; Page number
    int 0x10
    pop bx
    pop ax
    ret

WriteChar:       ; Write char in al for cx number of times (bl is color)
                 ; Page number is fixed at 0
                 ; Window is not scrolled if write past (24, 79)
    push ax
    push bx
    mov ah, 0x0a
    mov bh, 0    ; Page number
    int 0x10
    pop bx
    pop ax
    ret

SetCursorPos:    ; Set cursor pos to (dl, dh)
                 ; Page number is fixed at 0
    push ax
    push bx
    mov ah, 0x02
    mov bh, 0    ; Page number
    int 0x10
    pop bx
    pop ax
    ret

GetCursorPos:    ; Puts cursor pos in (dl, dh)
                 ; ax = 0
                 ; ch = Start scan line
                 ; cl = End scan line
    push bx
    mov ah, 0x03
    mov bh, 0    ; Page number
    int 0x10
    pop bx
    ret

ClearScreen:
    push dx
    mov dl, 0
    mov dh, 0
    call SetCursorPos
    mov cx, 2000      ; 80 * 25 = 2000
    mov al, " "
    call WriteChar
    pop dx
    ret
