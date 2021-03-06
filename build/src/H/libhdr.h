// libhdr for the ARM BCPL System
//
// 10 Jul 87 13:20:42
//
//  Modified by PAC 11.5.87 - New routines
//  from UT.b.RCPlib and UT.a.OSgbpb 
//  All new globals are above 150 
//  Added floating point & intcalc
//
// Revision History
// ----------------
//  Include extra FP globals                                13.7.87 PAC
//  Change FEXP to G181 to avoid clash with SIN at G189     20.7.87 DNH
//  Swap around the system library globals to tidy up a bit 25.7.87 PAC
//  Add BICI stuff, and wimp/font globals                   18.8.87 PAC
//  Add palette read : OsPalette                            28.9.87 PAC
//  Add SWI and OsByte2                                     31.3.88 PAC
//

GLOBAL
$( globsize             : 0
   G0                   : 0
   start                : 1
   HostProcessor        : 2

//3-12
   result2              : 13
   PutByte              : 14
   BytePut              : 14
   GetByte              : 15
   ByteGet              : 15
   MulDiv               : 16
   lineBuff             : 17
   WriteS               : 18
   WriteF               : 19
   CapitalCh            : 20
   CapCh                : 20 // = CapitalCh - PAC
   CompCh               : 21
   CompString           : 22
   NewLine              : 23
   RdCh                 : 24
   UnRdCh               : 25
   WrCh                 : 26
   Input                : 27
   Output               : 28
   SelectInput          : 29
   SelectOutput         : 30
   cis                  : 31
//   cos                  : 32 - removed to avoid conflict with fpmaths

//33-34
   Stop                 : 35
   NewPage              : 36
   GBytes               : 37
   PBytes               : 38
   returnCode           : 39
   stackBase            : 40
   Level                : 41
   LongJump             : 42
   Aptovec              : 43
   RdBin                : 44
   BinRdCh              : 44 // = rdbin
   WrBin                : 45
   BinWrCh              : 45 // = wrbin
   FindInput            : 46
   FindOutput           : 47

   CreateCo             : 48;
   DeleteCo             : 49;
   CallCo               : 50;
   ResumeCo             : 51;
   CoWait               : 52;

//53
   GetVec               : 54
   FreeVec              : 55
   MaxVec               : 56
   blockList            : 57
   freeStore            : 57
//58
   Read.Offset          : 59
   Set.Offset           : 60
   Extent               : 61
//62
   Abort                : 63
   BackTrace            : 64
   MapStore             : 65
   ReadBytes            : 66 
   WriteBytes           : 67 
//66-68
   PackString           : 69
   UnpackString         : 70
//71-75
   EndRead              : 76
   EndWrite             : 77
   ReadN                : 78
   WriteD               : 79
   WriteN               : 80
   WriteHex             : 81
   WriteOct             : 82
   RdArgs               : 83
   RdItem               : 84
   FindArg              : 85
//86-88
   random.state         : 89
   Random               : 90
//91-92    
   OsByte2              : 93
   SWI                  : 94
   Fault                : 95
   OSArgs               : 96
   OSBGet               : 97
   OSBPut               : 98
   OSFind               : 99
   OSFile               : 100
   OSCLI                : 101
   OSWrch               : 102
   OSRdCh               : 103
   OSByte               : 104
   OSWord               : 105
   TKRerr               : 106

//107
   Time                 : 108
   TimeOfDay            : 109
   Date                 : 110
   Lib.InitIO           : 111

//SetEventHandler : 112 

//112-119
   SSin                 : 120
   SCos                 : 121
   STan                 : 122
   SASin                : 123
   SACos                : 124
   SATan                : 125
   SLogE                : 126
   SLog10               : 127
   SEXP                 : 128
   SPower               : 129
   SSqrt                : 130

//131-139                        

// MakeNewStream : 135
// EndStream : 136

   MoveWords            : 140
   FillWords            : 141
   loadPoint            : 142
   Lib.TerminateIo      : 143
   vdustream            : 144
   errorstream          : 145
   streamchain          : 146
   describestream       : 147
//148-149                         

// globals 150-200 claimed for ARM system 
                             
// n.b. these routines defined in UT.a.VFSlib
// - do not move without updating the aasm code
   OSgbpb               : 150
   OsReadFcode          : 151
   OsWriteFcode         : 152
   OsSCSILoad           : 153

// more assembler code - in UT.a.GrafLib
   OsMouse              : 154
   OsSprite             : 155
   OsPlot               : 156

// the BICI interface - in UT.a.BICI
   BICIhandler          : 157
   BICIinstall          : 158
   BICIremove           : 159 
 
// RCPlib things 
   FiletoVec            : 160
   RunProg              : 161
   Vdu                  : 162
   Move                 : 163
   Debug                : 164 // diagnostics      
   Undefined.Global     : 165 // error handling

// more assembler stuff from Graflib
   OSWimpG              : 166
   OSWimpS              : 167
   OSFont               : 168
   OSPalette            : 169

// floating point library   
   FPEXCEP              : 170 // data - FP error indicator
   FABS                 : 171
   FCOMP                : 172
   FDIV                 : 173
   FFIX                 : 174
   FFLOAT               : 175
   FLIT                 : 176
   FMINUS               : 177
   FMULT                : 178
   FNEG                 : 179
   FPLUS                : 180
   WRITEFP              : 181
   FINT                 : 182
   FSGN                 : 183
   FEXP                 : 184
   FLN                  : 185
   FSQRT                : 186
   WRITESG              : 187
   SIN                  : 188 // fast integer procedures
   COS                  : 189
   ASN                  : 190
   SQR                  : 191

// these routines not needed for Domesday
//   READFP               :    
//   FRND                 :    
//   FSIN                 :    
//   FCOS                 :    
//   FTAN                 :    
//   FASIN                :    
//   FACOS                :    
//   FATAN                :
//   FDEG                 :    
//   FRAD                 :    
//   FPI                  :    
//   FE                   :    

$)

MANIFEST
$( VersionMark          = #x4e524556;

   EndStreamCh          = #x1FE
   BytesPerWord         = 4
   BitsPerWord          = 32
   BitsPerByte          = 8
   MaxInt               = #x7FFFFFFF
   MinInt               = #x80000000
   mcaddrinc            = 4

   StackFrameDirection  = 1 // later variables are at higher addresses

   ug                   = 200
//   fg                   = ug
   firstfreeglobal      = ug

   fp.len               = 1
   fpd.len              = 2
$)
