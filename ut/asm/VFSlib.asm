;*******************-*- Mode: Assembler -*-****************************
;*  Title:      Extra interface to VFS SWI's for ARM BCPL             *
;*  Author:     Paul Cunnell                                          *
;*  Lastedit:   25 Jul 87 17:21:30  by Paul Cunnell (Logica)          *
;**********************************************************************

;
;  This module contains the routines:
;     OSGbPb 
;     OSReadFcode
;     OSWriteFcode
;     OsSCSILoad
;
;  OSGbpb is a general routine; the others are specific to VFS
;

        GET     :4.Alib.BCPLMacs

r1              RN      1
r2              RN      2
r3              RN      3
r4              RN      4
r5              RN      5
r6              RN      6
r7              RN      7
r13             RN      13
r11             RN      11
r12             RN      12

; SWI numbers for video commands

KSCSI_Load        *      &403C1      
KVideo_WriteFcode *      &40440     
KVideo_ReadFcode  *      &40441

result2         GlobNo  13

        Module VFSlib, "25 Jul 87 12:10:02"

MajorVersion * 0
MinorVersion * 1

LocalDataP
        Address localData
        &       -1
        =       7, "Initial"

 GlobDef 150,OSgbpb 

; result := Osgbpb( opcode, parameter block )
; result is bytes/filenames transferred, result2 is non-zero if carry set

        STMEA   rts!,{r14}           ; save linkage
        MOV     r0, a1               ; opcode in a1
        MOV     rb, a2               ; parameter block in arg 2
        MOV     rb, rb, ASL #2       ; machine address of block
        STMEA   rts!, {rb}           ;
        LDMIA   rb, {r1-r6}          ; pick up the parameter block
        SWI     Kgbpb
        LDMEA   rts!, {rb}           ; recover old RB
        STMIA   rb, {r1-r4}          ; update parameter block
        MOV     r2, #0               ; the carry flag goes to result2
        MVNCS   r2, r2
        STR     r2, [rg, #G_result2]
        MOV     a1, r3               ; bytes transferred
        LDMEA   rts!, {pc}^          ; and return    

 GlobDef 151, OSReadFcode

; result := OSReadFcode( buffer )
; reads the current Fcode reply into the buffer
; result is TRUE if no error
; no check of buffer size is done - but 20 bytes will 
; always be adequate. Uses SWI Video_ReadFcode.


        STMEA   rts!,{rb,rp,rl,r14}  ; save linkage
        SUB     rp,rts,#16 
        MOV     r0, a1, ASL #2       ; machine address  
        SWI     KVideo_ReadFcode     ;
        MVN     a1, #0               ; return TRUE if no error
        MOVVS   a1, #0               ;
        MOV     rts,rp
        LDMIB   rp,{rp,rl,pc}^       ; restore linkage

 GlobDef 152, OSWriteFcode

; result := OSWriteFcode( command )
; writes the given Fcode command - a BCPL string
; make sure the command is C/R terminated before calling this
; result is TRUE if no error. Uses SWI Video_WriteFcode.

        MOV     r0, a1, ASL #2       ; machine address
        ADD     r0, r0, #1           ; skip length byte
        SWI     KVideo_WriteFcode    ;
        MVN     a1, #0               ; return TRUE if no error
        MOVVS   a1, #0               ;
        MOV     pc, r14              

 GlobDef 153, OsSCSILoad

; result := OsSCSILoad( start, end, start.sect, control )
; reads VFS sectors into memory
; start = start of memory, end is end of memory (BCPL addresses)
; start.sect is first disc sector to read
; control holds target, LUN & 2 other flags
; setting it to 0 'seems to work' for VFS
;
; result is TRUE if no error
; N.B. no check of buffer size is done
;
; Uses SWI SCSI_Load

        STMEA   rts!,{rb,rp,rl,r14}  ; save linkage
        SUB     rp,rts,#16 

        MOV     r0, a1, ASL #2       ; start (machine address)
        MOV     r1, a2, ASL #2       ; end   (machine address)
        MOV     r2, a3               ; number of sectors      
        MOV     r3, a4               ; control word           
        SWI     KSCSI_Load           ;
        MVN     a1, #0               ; return TRUE if no error
        MOVVS   a1, #0               ;
        MOV     rts,rp
        LDMIB   rp,{rp,rl,pc}^       ; restore linkage

localData
        = "VERN"
        = MinorVersion
        = MajorVersion
        ALIGN 4

        EndModule

        END
