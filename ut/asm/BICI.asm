;*******************-*- Mode: Assembler -*-****************************
;*  Title:      BICI - assembler for A500 BCPL-Prolog interface       *
;*  Author:     Paul Cunnell                                          *
;*  Lastedit:   17 Aug 87 17:21:30  by Paul Cunnell (Logica)          *
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

BICIhandler     GlobNo  157

; SWI calls used in this module:

KOS_EnterOS     *       22
KOS_Claim       *       31
KOS_Release     *       32
KOS_ConvertHex8 *       &D4

; constants

Diags           *       0  ; set to 1 for some displays & messages
CliV            *       5  

        Module BICI, "17 Aug 87 12:10:02"

MajorVersion * 1
MinorVersion * 1

LocalDataP
        Address localData
        &       -1
        =       7, "Initial"


 GlobDef 158, BICIinstall
 ;
 ; install the Cli vector interception code
 ; uses the SWI OS_Claim to make our code part 
 ; of the Cli vector chain.
 ; 
 ; !!! BEWARE !!! 
 ;
 ; This routine contains a fudge factor, necessary to allow
 ; successful calls to BCPL from the BICI controller. The 
 ; value of the BCPL stack frame is reaised by 40 bytes to 
 ; prevent trashing of the original stack. 
 ;
 ; This means that the 'real' BCPL code should never call a function
 ; via the 'Oscli("BICI command.string")' route, unless you're 
 ; SURE that the current stack frame is the same as that current 
 ; when the BICI handler was installed. ( It should never be necessary
 ; to do this anyway - just call the global 'BICIhandler( string )' to
 ; achieve the desired effect. )
 ;
 ; The 'second language' wishing to use BICI is (of course), free to 
 ; do so whenever it likes.
 ;
        ADR     r0, BCPLDump            ; bcpl register dump
        MOV     r2, rts                 ; save current sp
        ADD     rts, rts, #40           ; lift it up a bit
        STMEA   r0, {rgb-r13}^          ; save bcpl environment regs
        MOV     rts, r2                 ; restore real sp

 [ Diags=1
        MOV     r6, r14
        BL      displayregs
        MOV     r14, r6
 ]

        MOV     r0, #CliV               ; vector number
        ADR     r1, clihandler          ; handler routine
        MOV     r2, #0                  ; not used by us
        SWI     KOS_Claim               ; grab the vector
        MOV     pc, r14                 ; return to caller

 GlobDef 159, BICIremove

 ; remove the BICI handler from the Cli vector
 ; uses SWI OS_Release to take it out of the 
 ; Cli vector chain.

        MOV     r0, #CliV               ; vector number
        ADR     r1, clihandler          ; handler routine
        MOV     r2, #0                  ; not used by us 
        SWI     KOS_Release             ; free the vector
        MOV     pc, r14                 ; return to caller

clihandler

 ; entry here in SVC mode,  r0 = pointer to command line
 ; first thing to do is to check the command string to see
 ; whether we recognise it. If so, then do the clever stuff.

        STMFD   r13!, {r0-r4}          ; save these regs on SVC stack
        ADR     r1, id_string          ; points at identifier
        LDRB    r2, [r1], #1           ; get length, inc. pointer

compare
        LDRB    r3, [r0], #1           ; get char from command
        BIC     r3, r3, #&20           ; 'uppercase' it
        LDRB    r4, [r1], #1           ; and char from identifier
        CMPS    r3, r4                 ; compare them
        BNE     not_ours
        SUBS    r2, r2, #1             ; see if we're at the end
        BNE     compare

 ; now we know that the command starts with the letters 'BICI',
 ; and so we're free to intercept it.
 ; First save pointer to the command tail, which is pointed to
 ; by r1.

after_compare

        STR     r0, command_tail    ;
        STR     r14, pcdump         ; save r14 (not sure about this) ???
        LDMFD   r13!, {r0-r4}       ; recover our cached registers
        ADR     r14, RegDump        ; point at save block
        STMEA   r14, {r0-r14}^      ; save all the user registers
        LDMFD   r13!, {r0}          ; pop the return address for CliV
        STR     r0, retaddr         ; save this as well
        TEQP    pc, #0              ; back to user mode
        MOVNV   r0, r0              ; a necessary dummy instruction

 [ Diags=1
        ADR     r0, ours_str         
        SWI     KWrite0
 ]

        ADR     r0, BCPLDump        ; point at BCPL dump 
        LDMFD   r0, {rgb-r13}^      ; load environment regs
 [ Diags=1 
        BL      displayregs       
 ]
 ;
 ; now we are clear to call the BCPL handler
 ;
        LDR     rb, [rg, #G_BICIhandler]
        LDR     a1, command_tail    ; and recover command line
        MOV     a1, a1, LSR #2      ; as BCPL address
        MOV     r14, pc             ; manually save link reg.
        MOV     pc, rb              ; call BCPL handler
 ;
 ; on return, restore the old environment - we don't care about
 ; any return codes at the moment. N.B. Entered in user mode.
 ;
 [ Diags=1  
        ADR     r14, RegDump
        LDMFD   r14, {r0-r14}^      ; pick up previous register set
        BL      displayregs
 ]

        SWI     KOS_EnterOS         ; into SVC mode again    
        ADR     r14, RegDump
        LDMFD   r14, {r0-r14}^      ; pick up previous register set
        LDR     pc, retaddr         ; jump to return address

 ; ********** the old way of exiting *********
     ;   LDR     r14, pcdump         ; the last value of r14
     ;   ADR     r0, nullcommand     ; set command string to a null
     ;   MOVS    pc, r14             ; and go down the chain

not_ours
        LDMFD   r13!, {r0-r4}       ; recover regs
        MOV     pc, r14             ; pass on the call

 ;
 ; statics - register dumps, etc.
 ;
BCPLDump
        %       15*4
RegDump
        %       15*4
pcdump
        &       0
retaddr
        &       0
command_tail
        &       0

 ;
 ; This is the string that identifies a command to be
 ; recognised by the BICI interface. The string should
 ; be like a BCPL string, with the length byte before
 ; the text. The string here should be in uppercase. 
 ;
id_string
        =       4, "BICI"
        ALIGN

nullcommand
        =       " ",13
        ALIGN

 ;
 ; diagnostics - display registers, etc.
 ; call with r0 pointing at the block
 ; trashes r0-r5
 ;
 [ Diags=1
displayregs
        ADR     r0, rbuff
        STMEA   r0, {r0-r14}
        MOV     r4, r0             ; pointer to block
        MOV     r5, #16            ; convert 16 values
disp    LDR     r0, [r4], #4       ; first value
        ADR     r1, dbuff          ; buffer
        MOV     r2, #9             ; buffer size
        SWI     KOS_ConvertHex8    ; convert to ascii
        SWI     KWrite0            ; print it
        SWI     KNewline           ; print newline
        SUBS    r5, r5, #1         ; see if we're at the end
        BNE     disp
        MOV     pc, r14            ; return to caller

dbuff   = "00000000 ",0
        ALIGN
rbuff   %       15*4

 ;
 ; diagnostic strings - use SWI OS_WriteO for them
 ;
not_str =       "past vector",10,13,0
        ALIGN
ours_str =      "claim vector",10,13,0
        ALIGN
aft_str =       "past CLI",10,13,0
        ALIGN
aft_str2 =      "past restores",10,13,0
        ALIGN
aft_str3 =      "about to return",10,13,0
        ALIGN
 ]

 ; New version of OSCLI which cures the 're-entrancy' bug.
 ;
 ; The problem arises because BCPL called from BICIhandler 
 ; may well use Oscli, which needs to remember whether it
 ; is ALREADY running a subprogram before it tries running 
 ; a second one. The proper way to do this is to stack the 
 ; old environment values, instead of merely saving them.
 ; However, the Domesday stuff never needs the subprogram 
 ; facility, so a simple flag will suffice.
 ;

 GlobDef 101,OSCLI

 ; oscli command
 ; command is a BCPL string (so needs conversion)
 ; Returns False if the command fails, True otherwise
 ; If the base of this program is not 8000, then it
 ; tries to run the command as a sub-program.

        STMEA   rts!, {r14}
        MOV     r1, a1, ASL #2
        MOV     r2, #0
        BL      crterm
        MOV     r0, r1
        LDR     r4, osclixp
        SUBS    r5, pc, r4
        BEQ     oscli_no_subp
        LDR     r4, already_running   ; addition by PAC 17.8.87
        MOVS    r4, r4                ; to allow re-entry
        BNE     oscli_no_subp         ; for BICI interface

osclix  STMEA   rts!, {r14}
        STMEA   rts!, {r0 - r3, r6, r7, rg}

        MVN     r0, #0                ; set flag to show that we're
        STR     r0, already_running   ; running a subprogram - PAC 17.8.87

        ADR     r0, oscli_exit
        ADD     r1, r5, #&8000        ; new memory limit
        MOV     r2, #0 ; no change to real memory end
        MVN     r3, #1 ;           or local buffering
        MOV     r4, #0
        MOV     r5, #0
        MOV     r6, #0
        MOV     r7, #0
        SWI     KSetEnv

        ADR     r14, cli_save
        STMIA   r14!, {r0 - r7}
        LDMEA   rts!, {r6, r7, rg}

        MOV     r0, #0
        MOV     r1, #0
        SWI     KCallBack
        STMIA   r14!, {r0, r1}

        MOV     r0, #0
        MOV     r1, #0
        MOV     r2, #0
        MOV     r3, #0
        SWI     KControl
        STMIA   r14!, {r0 - r3}

        MOV     r2, #&40
        LDR     r0, SWIBranch
FindSWIBranch
        LDR     r1, [r2], #+4
        CMPS    r1, r0
        BNE     FindSWIBranch

        LDR     r1, [r2, #KControl*4]
        ADR     r3, MyControlHandler
        STR     r3, [r2, #KControl*4]
        STMIA   r14!, {r1, r2}

        ADR     r0, return_code
        STR     r0, HisEventHandler

        LDMEA   rts!, {r0 - r3}
        ADR     r14, R1_to_r13_save
        STMIA   r14!, {r1 - r13}
        SWI     KCLI
        MVN     r0, #0
        MOVVS   r0, #0
        B       oscli_exit_2

oscli_exit
        MVN     r0, #0
oscli_exit_2
        STR     r0, cli_status        ; return value from OsCli
        ADR     r0, return_code
        STR     r0, HisEventHandler
        TSTP    pc, #0                ; back to user mode
        MOVNV   r0, r0                ; dummy instruction

 [ Diags=1
        ADR     r0, aft_str
        SWI     KWrite0
 ]
        ADR     r14, R1_to_r13_save
        LDMIA   r14, {r1 - r13}
        LDMEA   rts!, {r14}
        STMEA   rts!, {r1 - r3, r6, r7}
        ADR     r5, OriginalControl
        LDMIA   r5, {r1, r2}
        STR     r1, [r2, #KControl*4]

 [ Diags=1    
        ADR     r0, aft_str2
        SWI     KWrite0
 ]
        ADR     r5, cli_save
        LDMIA   r5, {r0 - r7}
        SWI     KSetEnv
        ADR     r5, cli_save+32
        LDMIA   r5!, {r0, r1}
        SWI     KCallBack
        LDMIA   r5!, {r0 - r3}
        SWI     KControl
        LDMEA   rts!, {r1 - r3, r6, r7}

 [ Diags=1    
        ADR     r0, aft_str3
        SWI     KWrite0
 ]
        MOV     r0, #0               ; reset 'already running' flag
        STR     r0, already_running  ; PAC 17.8.87

        LDR     r0, cli_status
        B       afterosf

oscli_no_subp
        SWI     KCLI
        MVN     r0, #0
        MOVVS   r0, #0
        B       afterosf

SWIBranch
        LDR     pc, [rp, r11, LSL #2]

osclixp & osclix+&8000

cli_save
        % 14*4
OriginalControl
        % 2*4
R1_to_r13_save
        % 13*4

cli_status      & 0
already_running & 0    ; new flag added by PAC 17.8.87

HisEventHandler
        Address return_code

return_code
        MOV     pc, r14

MyControlHandler
        MOV     r2, #0
        CMPS    r3, #0
        STRNE   r3, HisEventHandler
        MOV     r3, #0
        LDR     pc, OriginalControl

 ;
 ;  All stuff below extracted from the BCPL MCLIB code,
 ;  but not altered at all. Only Oscli uses it in this module.
 ;
afterosf
        CMPS    r2, #0          ; r2 non-zero means an argument string needs
        MOVEQ   a1, r0          ; shuffling up again
        LDMEQEA rts!, {pc}^
 ; r3 points to the last byte of the string as was, now its
 ; terminating CR.  r1 points to the first byte (was the
 ; length). r2 is the length.
osfc2
        LDRB    r4, [r3, #-1]
        STRB    r4, [r3], #-1
        CMPS    r3, r1
        BGT     osfc2
        STRB    r2, [r3]
        MOV     a1, r0
        LDMEA   rts!, {pc}^

crterm
        LDRB    r2, [r1, #0]    ; length of filename
        AND     r3, r2, #3
        CMPS    r3, #3
        BEQ     osfdown
        MOV     r3, #&0D        ; if there's room, add a terminating
        ADD     r1, r1, #1      ; CR on the end of the string
        STRB    r3, [r1, r2]
        MOV     r2, #0
        MOV     pc, r14

osfdown                         ; otherwise, shuffle the string down
        MOV     r3, r1          ; one byte (remembering the length) and plant
        ADD     r5, r1, r2      ; a CR at the end
osfcopy
        LDRB    r4, [r3, #1]
        STRB    r4, [r3], #1
        CMPS    r3, r5
        BLT     osfcopy
        MOV     r5, #&0D
        STRB    r5, [r3]
        MOV     pc, r14

localData
        = "VERN"
        = MinorVersion
        = MajorVersion
        ALIGN 4

        EndModule

        END
