;*******************-*- Mode: Assembler -*-****************************
;*  Title:      FP functions for BCPL                                 *
;*  Author:     Harry Meekings                                        *
;*  Lastedit:   15 Jul 87 22:15:29 by Harry Meekings                  *
;*              Copyright (c) 1986 by Acorn Computers Ltd             *
;**********************************************************************

        GET     $.Alib.BCPLMacs

        Module FPMath, "15 Jul 87 21:56:09"

MajorVersion * 1
MinorVersion * 0

LocalDataP
        Address localData
        &       -1
        =       7, "Initial"

f0      FN      0
f1      FN      1

        MACRO
        RToF    $f, $r
        STR     $r, [rts]
        LDFS    $f, [rts]
        MEND

        MACRO
        FToR    $r, $f
        STFS    $f, [rts]
        LDR     $r, [rts]
        MEND

        GlobDef 120,SSin
; a1 := Sin(a1)
        RToF    f0, a1
        SINS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 121,SCos
; a1 := Cos(a1)
        RToF    f0, a1
        COSS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 122,STan
; a1 := Tan(a1)
        RToF    f0, a1
        TANS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 123,SASin
; a1 := ASin(a1)
        RToF    f0, a1
        ASNS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 124,SACos
; a1 := ACos(a1)
        RToF    f0, a1
        ACSS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 125,SATan
; a1 := Atan(a1)
        RToF    f0, a1
        ATNS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 126,SLogE
; a1 := Log(a1) (base e)
        RToF    f0, a1
        LGNS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 127,SLog10
; a1 := Log(a1) (base 10)
        RToF    f0, a1
        LOGS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 128,SExp
; a1 := Exp(a1)
        RToF    f0, a1
        EXPS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 129,SPower
; a1 := a1**a2
        RToF    f0, a1
        RToF    f1, a2
        POWS    f0, f0, f1
        FToR    a1, f0
        MOVS    pc, r14

        GlobDef 130,SSqrt
; a1 := Sqrt(a1)
        RToF    f0, a1
        SQTS    f0, f0
        FToR    a1, f0
        MOVS    pc, r14

localData
        = "VERN"
        = MinorVersion
        = MajorVersion
        ALIGN 4

        EndModule

        END
