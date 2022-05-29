;; This is a quick hack done on Dark Stalker's Check DS-Crypt
;; Work's only with files (COM/EXE) smaller than 63 KB!

.model  tiny
include dos.inc
.code
Org     100h
.startup
        cld
        Mov     Dx,OffSet Intro
        Call    Print
        Call    GetParam
        Mov     Ax,3D00h                ; fopen
        Mov     Dx,FName
        Int     21h
        Jnc     Next
        Mov     Dx,OffSet FoErr
        Jmp     Short Print
Next:
        XChg    Ax,Bx
        Mov     Ah,3Fh
        Mov     Dx,OffSet Buf
        Mov     Cx,0FF00h
        sub     cx, dx
        Int     21h
        Push    Ax
        Mov     Ah,3Eh
        Int     21h
        Pop     Si
        Add     Si,OffSet Buf-9
        LodSw
        Cmp     Ax,'SH'
        Jne     NotDsc
        LodSw
        Mov     VerHi,Al
        Mov     VerLo,Ah
        lodsw
        cmp     ax, "sM"
        jne     NotDsc
        @ShowStr "Found HackStop "
        sub     ax, ax
        mov     al, VerHi
        call    WriteDecimal
        @ShowChar '.'
        sub     ax, ax
        mov     al, VerLo
        call    WriteDecimal
        @ShowChar 13, 10
        .exit   0
NotDsc:
        Mov     Dx,OffSet NoDsd
        call    Print
        .exit   3

Print   Proc
        Mov     Ah,9
        Int     21h
        Ret
Print   EndP

GetParam Proc
        Mov     Cl,Ds:[80h]             ; Grab the command line length in CL
        Or      Cl,Cl                   ; Check to see if it's 0
        Jz      Short NoCmd             ; No, get the commandline
ScnCmd:
        Mov     Si,81h                  ; Load command offset into SI
ScanLp:
        LodSb                           ; Load a byte from SI into AL
        Cmp     Al,20h                  ; Remove the leading spaces, Is it a space?
        Jne     Short Found             ; No, stop this loop and save the starting point
        Loop    ScanLp                  ; Yes, loop ScanLp until its not a space.
NoCmd:
        Mov     Ah,9
        Mov     Dx,OffSet Usage         ; Display the usage message
        Int     21h
        .exit   2
Found:
        Dec     Si                      ; Subtract 1 from the offset of commandline
        Push    Si
ScnEnd:
        LodSb                           ; Load a byte from SI
        Cmp     Al,0Dh                  ; Search for CR
        Jne     Short ScnEnd            ; CR not found so keep scanning
        Mov     Byte Ptr Ds:[Si-1],0    ; Replace CR with nul char (ASCIIZ)
        Pop     FName
        Ret
GetParam EndP

;; ************************************************************************

WriteDecimal proc near uses bx cx ax dx,

        test    ax, 8000h               ; negative
        je      short @@3
        neg     ax                      ; reverse the number
        push    ax
        mov     ah, 02h
        mov     dl, '-'                 ; print a '-'
        int     21h
        pop     ax

@@3:
        mov     bx, 10
        xor     cx, cx

@@1:    xor     dx, dx
        idiv    bx                      ; (dx:ax) / 10
        push    dx                      ; the lowest decimal number
        inc     cx
        or      ax, ax                  ; eax=0 ?
        jne     @@1

        mov     ah, 02h
@@2:    pop     dx                      ; number into DL
        add     dl, '0'
        int     21h
        loop    @@2

        ret
WriteDecimal endp



.data
        Intro   Db 13,10,'---=[ Check-HackStop v1.0 by ROSE, Concept by Dark Stalker ]=-----------------',13,10,13,10,'$'
        NoDsd   Db '[Not HS-Protected]',13,10,'$'
        FoErr   Db 'File open error',13,10,'$'
        Usage   Db ' USAGE: ChkHS <FileName>',13,10,'$'
        FName   Dw 0
        VerHi   Db 0
        VerLo   Db 0
        Buf     Equ $
.stack
end
