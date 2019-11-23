;*******************-*- Mode: Assembler -*-****************************
;*  Title:      GrafLib - assembler for A500 graphics                 *
;*  Author:     Paul Cunnell                                          *
;*  Lastedit:   28 Sep 87 17:23:14  by Paul Cunnell (Logica)          *
;**********************************************************************

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

result2         GlobNo  13

; SWI calls used in this module:

KOS_BreakPt      *       &17
KOS_Mouse        *       &1C
KOS_SpriteOp     *       &2E
KOS_ReadPalette  *       &2F

        Module Graf, "28 Sep 87 17:23:14"

MajorVersion * 0
MinorVersion * 1

LocalDataP
        Address localData
        &       -1
        =       7, "Initial"

 GlobDef 154,OsMouse

 ; result := OsMouse( parameter block )
 ;
 ; parameter block is updated to contain:
 ;
 ; block!0 = current mouse X position (BBC graphics units)
 ; block!1 = current mouse Y position (BBC graphics units)  
 ; block!2 = mouse keys pressed information:
 ;           bit 0 = right button pressed
 ;           bit 1 = centre button
 ;           bit 2 = left button
 ;
 ; the result is the same as block!2
 ;

        MOV      r5, a1, ASL #2      ; save M/C address of block
        SWI      KOS_Mouse           ; get the information
        STMEA    r5, {r0-r2}         ; save the information
        MOV      r1, #0              ; set result2 if V flag set
        MOVNVS   r1, r1              ; 
        STR      r1, [rg, #G_result2]
        MOV      a1, r2              ; return value : key presses
        MOVS     pc, r14


 GlobDef 155,OsSprite

 ; result := OsSprite( opcode, parameter block )
 ;
 ; performs an SWI OS_SpriteOp, setting registers R0-R7 from the
 ; parameter block.
 ; the parameter block is updated on exit to contain the returned
 ; registers. 
 ;
 ; return value is FALSE if the call failed, TRUE otherwise
 ;
        STMEA   rts!,{r7,r14}        ; save linkage & r7
        MOV     r0, a1               ; opcode in a1
        MOV     rb, a2               ; parameter block in arg 2
        MOV     rb, rb, ASL #2       ; machine address of block
        STMEA   rts!, {rb}           ;
        LDMIA   rb, {r1-r7}          ; pick up the parameter block
        SWI     KOS_SpriteOp         ; do the SWI
        LDMEA   rts!, {rb}           ; recover old RB
        STMIA   rb, {r1-r7}          ; update parameter block
        MVN     a1, #0               ; return TRUE if no error
        MOVVS   a1, #0               ;
        LDMEA   rts!, {r7,pc}^       ; and return to caller   



 GlobDef 156,OsPlot

 ; OsPlot( opcode, x, y )
 ;
 ; does a "VDU 25, opcode, x; y;"
 ; - the fastest way to do plotting.
 ; Used by NN.plot
 ;

        MOV     r0, #25              
        SWI     KWrch
        AND     r0, a1, #&FF
        SWI     KWrch
        AND     r0, a2, #&FF
        SWI     KWrch
        MOV     r0, a2, LSR #8
        SWI     KWrch
        AND     r0, a3, #&FF
        SWI     KWrch
        MOV     r0, a3, LSR #8
        SWI     KWrch
        MOVS    pc,r14

 GlobDef 166,OsWimpG
 
 ; General Wimp routine
 ;
 ; result := OsWimpG( SWI.number, block, r0.value )
 ;
 ; on entry, R1 is pointed to block, which contains
 ; the parameters for the Wimp function.
 ; r0 is set to r0.value
 ; on exit result is R0, Result2 set to R1

        LDR     rb, Ge_SWI           ; get SWI opcode
        AND     rb, rb, #&FF000000   ; mask current value
        ORR     rb, a1, rb           ; set up new SWI
        STR     rb, Ge_SWI           ; and set up the opcode
        MOV     r1, a2, ASL #2       ; parameter block in arg 2
        MOV     r0, a3               ; set up R0
Ge_SWI  SWI     KOS_BreakPt          ; do the (modified) SWI
        STR     r1, [rg, #G_result2] ; r1 goes to result2
        MOV     a1, r0               ; r0 is result
        MOV     pc, r14              ; and return to caller   

 GlobDef 167,OsWimpS
                                                                        
 ; 'Special' Wimp routine
 ;
 ; ok := OsWimpS( SWI.number, reg.block )
 ;
 ; on exit result is TRUE if no error, else FALSE
 ; block contains the register values for the
 ; Wimp function. (i.e. R0 = block!0, etc.)
 ; the block is updated to contain the returned
 ; registers. Must be a VEC 6

        STMEA   rts!,{r7,r14}        ; save linkage
        LDR     rb, Sp_SWI           ; get SWI opcode
        AND     rb, rb, #&FF000000   ; mask current value
        ORR     rb, a1, rb           ; set up new SWI
        STR     rb, Sp_SWI           ; and set up the opcode
        MOV     rb, a2               ; parameter block in arg 2
        MOV     rb, rb, ASL #2       ; machine address of block
        STMEA   rts!, {rb}           ;
        LDMIA   rb, {r0-r6}          ; pick up the parameter block
Sp_SWI  SWI     KOS_BreakPt          ; do the (modified) SWI
        LDMEA   rts!, {rb}           ; recover old RB
        STMIA   rb, {r0-r6}          ; update parameter block
        MVN     a1, #0               ; return TRUE if no error
        MOVVS   a1, #0               ;
        LDMEA   rts!, {r7,pc}^       ; and return to caller   

 GlobDef 168,OsFont
 
 ; Font manager/painter interface routine
 ;
 ; ok := OsFont( SWI.number, reg.block )
 ;
 ; Block contains the register values for the
 ; Font function. (i.e. R0 = block!0, etc.)
 ; On exit, the block is updated to contain the 
 ; returned registers. (Must be a VEC 6)
 ; The result is TRUE if no error, else FALSE

        STMEA   rts!,{r7,r14}        ; save linkage
        LDR     rb, Fo_SWI           ; get SWI opcode
        AND     rb, rb, #&FF000000   ; mask current value
        ORR     rb, a1, rb           ; set up new SWI
        STR     rb, Fo_SWI           ; and set up the opcode
        MOV     rb, a2               ; parameter block in arg 2
        MOV     rb, rb, ASL #2       ; machine address of block
        STMEA   rts!, {rb}           ;
        LDMIA   rb, {r0-r6}          ; pick up the parameter block
Fo_SWI  SWI     KOS_BreakPt          ; do the (modified) SWI
        LDMEA   rts!, {rb}           ; recover old RB
        STMIA   rb, {r0-r6}          ; update parameter block
        MVN     a1, #0               ; return TRUE if no error
        MOVVS   a1, #0               ;
        LDMEA   rts!, {r7,pc}^       ; and return to caller   

 GlobDef 169,OsPalette
 
 ; Access to palette reader SWI
 ;
 ; colour := OsPalette( logical.colour, which.colour )
 ; Result2 is set to value of second flash colour 
 ; 

        MOV      r0, a1              ; logical colour
        MOV      r1, a2              ; which colour to read
        SWI      KOS_ReadPalette     ; get the information
        MOV      a1, r2              ; return value from r2
        STR      r3, [rg, #G_result2]; save r3 in Result3
        MOVS     pc, r14             ; return to caller

localData
        = "VERN"
        = MinorVersion
        = MajorVersion
        ALIGN 4

        EndModule

        END
