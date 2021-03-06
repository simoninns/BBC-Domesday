
// AES Acorn Risc Machine Development source
// module Debug - run-time debugger
//
// Version of mapstore, etc. considerably modified by 
// Paul Cunnell (Logica) for use in testing Domesday port
// software. It hangs around after an Abort, and lets you
// look at things. 
//
// Amended 12.6.87 - made debug() a global, so we can get at
// it from the top level loop of the retrieval software
//
// Also added breakpointing onto global procedures.
//
// 5.8.87  PAC - add %F output
// 14.8.87 PAC - improve screen save, etc.

SECTION "Debugger"

get "H/libhdr"

STATIC
$( /* Version of 2 Jun 87 11:13:20
   */
   dummy = VersionMark;
   version = 1*256 + 3

   STYLE = 0; A = 0          // A is current variable
   REC.P = 0; REC.L = 0
   CH    = 0; VARS  = 0       

   s.mode = 0   // used by savescreen, etc.
   s.pal  = 0 
   s.cpos = 0
   
   s.pv       = 0
   s.oldp     = 0     // procedure addresses used for breakpoints 
   s.breakno  = 0     // flag for current breakpoint
   s.retbreak = FALSE // flag for break on return 
   s.aptr     = 0
$)

GLOBAL 
$(
   TopOfStore : 148
$)  

MANIFEST
$( SectionStart       = #x4c504342;
   StartRelocation    = #x12345678;
   EndRelocation      = #x87654321;
   EndMark            = 1002;
   HunkMark           = 1001;
   linelength         = 80;
   UnsetGlobalMask    = #xFFFF0000;
   UnsetGlobalValue   = #xAE950000; 
   PCMask             = #x03FFFFFC
$)
                              
//
// entry point is via an Abort
// - reports the error
// - possibly changes into mode 0
// 
LET Abort(n) BE
$( LET pc   = (VCAR[Level()+12])&PCMask;
   LET mode = ?
   LET wait.() BE
   $( LET ch = ? ; 
      Osbyte(21,0)
      Writes("*n*nPress SPACE to continue...*n")
      ch := Osbyte(#x81,0,0) REPEATUNTIL (Result2 = 0) | (Result2 = #x1B)
      IF (ch = 13) | (ch=27) | (Result2 = #x1B) Stop(256)
      OsWrch( ch ) // echo it (allows printer on, etc)
   $)

   Osbyte(#x87)
   mode := RESULT2 & #xF

   OSByte(#xDA, 0, 0 )  // Abort any VDU parameters still needed
 
   UNLESS mode = 0 
   $( OsWrch(7); OsWrch(7);                  // long beep
      wait.();                               // pause
      save.screen() 
   $)
                           
   Osbyte(20)  // reset character set
   Osbyte(4,0) // cursor editing

   SWITCHON n INTO
   $( CASE 1: WriteS("*nUndefined Instruction"); ENDCASE
      CASE 2: WriteS("*nPrefetch Abort"); ENDCASE
      CASE 3: WriteS("*nData Abort"); ENDCASE
      CASE 4: WriteS("*nAddress Exception"); ENDCASE
      CASE 5: WriteS("*nUndefined Global"); ENDCASE  
      DEFAULT:WriteF("*nUnexpected abort code %n", n)
   $);
   WriteF(" at %x8", pc);
   IF (pc&UnsetGlobalMask)=(UnsetGlobalValue&PCMask) | n=5 THEN
      WriteF("*nIs Global %N defined?", [(pc&~UnsetGlobalMask)>>2]-1);
   
   Debug(999)   // special flag 'cos we've already saved the screen

   Stop(256)
$)  
  
//                 
// this screen protection stuff assumes that we've got VDU from RCPlib
// if this isn't possible, then use multiple oswrch calls
//
AND save.screen() BE 
$(                       
   Let blk = VEC 2
   LET name = "debugscrn*c"
   LET pb   = VEC 7    

   Osbyte(#x87)
   s.mode := RESULT2 & #xF

   IF s.mode = 0 return

   Osbyte( 106,0,0 ) // turn off mouse pointer

   name   := name * bytesperword + 1  // m/c address

   s.pal  := TABLE 0,0,0,0,  // 16 entries
                   0,0,0,0,
                   0,0,0,0,
                   0,0,0,0

   s.cpos := TABLE 0,0,0,0 ; Osword(#x0d, s.cpos)

   For i = 0 to 15 do 
   $(
      blk%0 := i ; blk!1 := 0    // set up required colour
      Osword( #x0B, blk )        // get physical colour
      s.pal!i := blk%1
   $)

   pb!0 := 0                             // unused if system sprite
   pb!1 := name                          // sprite name
   pb!2 := 0                             // exclude palette
   pb!3 := 0                             // lh edge
   pb!4 := 0                             // bottom edge
   pb!5 := 1280                          // rh edge
   pb!6 := 1024                          // top edge
  
   OsSprite( 16, pb ) // save screen

   VDU("22,0")    // change mode, unlink cursors   
   OsByte( 4,0 )  // set cursor editing

   VDU("19,1,7;0;") // foreground white
   VDU("19,0,4;0;") // background dk. blue

   OsByte( 106,1,0 ) // turn on mouse pointer

   // ...now we are safe to call the debugger
$)

AND restore.screen() BE
$(
   LET name = "debugscrn*c"
   LET pb   = VEC 7    

   IF s.mode = 0 RETURN

   name   := name * bytesperword + 1  // m/c address  

   Osbyte( 106,0,0 ) // turn off mouse pointer

   OsByte( 4,2 )                         // reset cursor keys
   VDU("22,%,5", s.mode )                // return to previous mode

   pb!0 := 0                             // unused if system sprite
   pb!1 := name                          // sprite name

   OsSprite( 24, pb )
  
   pb!0 := 0                             // to be safe !
   pb!1 := name                          // sprite name  
   pb!2 := 0                             // lh edge   
   pb!3 := 0                             // bottom edge  
   pb!4 := 0                             // GCOL action

   OsSprite( 34, pb )

   For i = 15 to 0 by -1 DO VDU("19,%,%;0;",i, s.pal!i ) 

   VDU ("25,4,%;%;25,4,%;%;", s.cpos!0, 
                              s.cpos!0>>16, 
                              s.cpos!1, 
                              s.cpos!1>>16 )
   
   OsByte( 106,1,0 ) // turn on mouse pointer
$)

//          
// these are the break routines, and they allow a call to debug()
// before doing whatever the original global procedure was 
// supposed to do. 
//
AND break1( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) = VALOF
$( s.aptr := @p1
   debug(1)
   s.pv := (s.oldp!1)( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) 
   IF s.retbreak debug(10)
   RESULTIS s.pv
$)

AND break2( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) = VALOF
$( s.aptr := @p1
   debug(2)
   s.pv := (s.oldp!2)( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) 
   IF s.retbreak debug(10)
   RESULTIS s.pv
$)

AND break3( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) = VALOF
$( s.aptr := @p1
   debug(3)
   s.pv := (s.oldp!3)( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) 
   IF s.retbreak debug(10)
   RESULTIS s.pv
$)
AND break4( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) = VALOF
$( s.aptr := @p1
   debug(4)
   s.pv := (s.oldp!4)( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) 
   IF s.retbreak debug(10)
   RESULTIS s.pv
$)
AND break5( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) = VALOF
$( s.aptr := @p1
   debug(5)
   s.pv := (s.oldp!5)( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) 
   IF s.retbreak debug(10)
   RESULTIS s.pv
$)

AND Debug(callcode) = VALOF
$(  
    LET cis = INPUT()
    LET cos = OUTPUT()
    LET vduin = FINDINPUT("VDU:")
    LET vduout= FINDOUTPUT("VDU:")  
                      
    s.oldP := TABLE 0,0,0,0,0,0,0,0,0,0
    VARS   := TABLE 0,0,0,0,0,0,0,0,0,0
    REC.P, REC.L := LEVEL(), NXTC
    IF STYLE = 0 $( STYLE := 'D' ; A := 0 $) // initialise    
            
    UNLESS callcode = 999 save.screen()  // and save our display
    Writes("*nEntering debug")

    IF callcode ~= 0 THEN 
    TEST callcode < 10
    $( Writef(" from break point %n : ",callcode)
       Writearg( s.oldp!callcode, 0 )
    $)       
    ELSE IF callcode = 10 THEN
    Writef(" on return; result = %n (&%x8)",s.pv,s.pv)
    
    NEWLINE()
                  
    ENDREAD(); ENDWRITE()
    SELECTINPUT( vduin ) ; SELECTOUTPUT( vduout )

    RCH() REPEATUNTIL CH='*N' | CH=ENDSTREAMCH

// Start of main loop.

NXTC: WRCH('$')  
NXT:  RCH()

SW: 
SWITCHON CH INTO
$( DEFAULT: IF CH<32 GOTO NXT
            XERROR("BAD COMMAND %C", CH)

   CASE '*N': GOTO NXTC 
   CASE '*S': GOTO NXT

   CASE '*'':CASE 'V':CASE 'G':
         A := RBEXP()
         GOTO SW

   CASE '#':
   CASE '0':CASE '1':CASE '2':CASE '3':CASE '4':
   CASE '5':CASE '6':CASE '7':CASE '8':CASE '9':
             A := RBEXP()
             IF CH = 'H'
                THEN RCH() // get rid of 'H' rubbish
             GOTO SW

   CASE '.':CASE '!':CASE '+':CASE '-':CASE '**':
   CASE '/':CASE '%':CASE '<':CASE '>':      
   CASE '&':CASE '|':
            A := REXP(A)
            GOTO SW

   CASE '$': RCH()
             UNLESS CH='C' | CH='X' | CH='D' | CH='O' | CH='S' | CH='F' DO
                    XERROR("BAD STYLE CHAR %C", CH)
             STYLE := CH
             GOTO NXT

   CASE '=': OUT(A)
             NEWLINE()
             GOTO NXT

   CASE ':': RCH()
             $( LET N= '0'<=CH<='9' | CH='#' -> RBEXP()-1, 7
                FOR I = 0 TO N DO
                $( IF I REM 4 = 0 DO
                    $( IF CHECKESC() BREAK
                       PRADDR(A+I)
                    $)
                   OUT(A!I)  
                   IF STYLE = 'S' BREAK // for strings - only do one
                $)          
                NEWLINE()    
             $)
             GOTO SW
                
   CASE 'A': // display breakpoint arguments
   $( 
      LET n = 5
    
      UNLESS ( 1 <= callcode < 10 ) XERROR("NOT AT A BREAKPOINT")             

      RCH(); IF '1'<=CH<='9' DO $( n := CH-'0'; RCH() $)
    
      FOR i = 0 TO n-1 DO  $( WRITEF("*nP%n : ",i); OUT( s.aptr!i ) $)
      NEWLINE()
      GOTO SW
   $)
  
   CASE 'B': // 0 B      UNSET ALL BREAK POINTS
             // 0 BN     UNSET BREAK POINT N
             // A BN     SET BREAK POINT N AT M/C ADDR A
   $( LET N  = 0            
      LET gv = @G0
      RCH()

      IF '1'<=CH<='9' DO $( N := CH-'0'; RCH() $)
      TEST A=0 // A must have been set 0 this line
      THEN // clear breakpoints
      $(
         FOR i = 1 TO 5 DO 
         TEST (i = callcode = N) THEN WRITES("CAN'T UNSET CURRENT BREAK*n")
         ELSE IF (i=N | N=0) & (s.oldp!i ~= 0) THEN
         $( 
            Writef("*nUnset BP %n on G%n to %X8*n",i,s.oldp!(i+5),s.oldp!i )
            gv!(s.oldp!(i+5)) := s.oldp!i; s.oldp!i := 0 
         $)
      $)
      ELSE  // set global number A to breakpoint N
      $( IF N=0 THEN N := 1  // break 1 is default to set
        
         Writef("*nSet BP %n at G%n*n",N,A)

         UNLESS (0<A<=G0)  DO XERROR("MAX GLOBAL %n",G0)
         UNLESS (1<=N<=5)  DO XERROR("MAX BREAK NO. IS 5")
         UNLESS s.oldp!N=0 DO XERROR("BREAK %n ALREADY SET")

         s.oldp!(n+5) := A    // save global number
         s.oldp!n     := gv!A // save procedure address  

         gv!A := VALOF SWITCHON N INTO      // ugly, I know
                 $( CASE 1: RESULTIS break1
                    CASE 2: RESULTIS break2
                    CASE 3: RESULTIS break3
                    CASE 4: RESULTIS break4
                    CASE 5: RESULTIS break5
                 $)
      $)
      GOTO SW
   $)
              
   CASE 'R': $( s.retbreak := (A~=0) // break on return
                Writef("%Set BP on return*n",s.retbreak->"S","Uns")
                GOTO NXT  
             $)

   CASE 'S': $( LET UPDTADDR = ?    // addr to update
                LET DODISP = ?      // true if doing display
                LET ISGLB, ISV = FALSE, FALSE

                RCH()
                UPDTADDR := VALOF SWITCHON RSIGCH() INTO
                $( DEFAULT: IF '0' <= CH <= '9' | CH = '#' THEN
                               RESULTIS RBEXP()
                            XERROR("BAD ADDRESS")

                   CASE 'G': ISGLB := TRUE
                             RCH()
                             RESULTIS (@G0)+RDN(10)

                   CASE 'V': ISV := TRUE
                             RCH()
                             RESULTIS VARS+RDN(10)
                $)
                DODISP := RSIGCH() = '*N'

                $( IF ISGLB & UPDTADDR > (@G0)+G0 THEN
                      XERROR("MAX GLOBAL %N", G0)
                   IF ISV & UPDTADDR > VARS+9 THEN
                      XERROR("ONLY 10 VARIABLES")
                   IF RSIGCH() = '*N' THEN
                      TEST DODISP THEN
                      $( LET V = !UPDTADDR
                         PRADDR(UPDTADDR)
                         WRITEF("%IB %X8 %C%C%C%C :", V, V, 
                                 SPCHAR(V),     SPCHAR(V >> 8),
                                 SPCHAR(V>>16), SPCHAR(V >> 24) )
                         RCH(); RSIGCH()
                       $)
                       ELSE
                         GOTO NXTC
                   UNLESS CH = '*N' DO
                      !UPDTADDR := REXP(RBEXP())
                   UPDTADDR := UPDTADDR + 1
                $) REPEAT
             $)              

   CASE 'O': OScommand()
             GOTO NXT

   CASE 'D': Backtrace()
             GOTO NXT

   CASE 'H': ShowBlocks()
             GOTO NXT

   CASE 'C': DescribeCode(loadPoint)
             GOTO NXT

   CASE 'P': ShowGlobs()
             GOTO NXT
   
   CASE '?': DoHelp(callcode)
             GOTO NXT
  
   CASE 'M': Mapstore()
             GOTO NXT
   
   CASE 'F':
   CASE 'X': restore.screen(); RESULTIS TRUE // Exit from debug()

   CASE 'Q': WRITES("*nQuit Debug*n"); stop(256)

$)  // end of switch

GOTO NXT

$)  // end of Debug()

AND DoHelp(code) BE
$(
   Writes("*nARM BCPL debugger V2.1 PAC*n")
   Writes("*nWorks like DEBUG, but has following options :*n")
   Writes("*nX - Exit, ? - Help, H - show heap, C - show code")
   Writes("*nD - Backtrace, P - Show Global Procedures")    
   Writes("*nB - Set breakpoint on global, R - break on return")
   Writes("*nA - Show Args, M - Mapstore, O*"str*" - OS command")  
   Writes("*nS - Modify memory, Q - Quit (completely)")
   Writes("*n*n...plus all normal expression evaluation*n")     

   // report current breakpoints
   Writes("*nCurrently set breakpoints :")
   FOR i = 1 TO 5 DO  
   UNLESS s.oldp!i = 0 DO
   $( Writef("*nNo. %n G%n Addr %x8 : ",i,s.oldp!(i+5),s.oldp!i)
      Writearg( s.oldp!i, 0 )
   $)                        
   NEWLINE()

   IF code ~= 0 THEN 
   TEST code < 10 THEN
   $( Writef("*nCurrent break point %n : ",code)
      Writearg( s.oldp!code, 0 )     
      NEWLINE()
   $)       
   ELSE IF code = 10 THEN
   Writef("*nBreak on return; result = %n (&%x8)*n",s.pv,s.pv)
$)
                     
AND OScommand() BE
$( LET str = VEC 20
   RDITEM( str, 20 )
   OsByte(229,0)
   UNLESS OsCli( str ) Writef("%s*n", TKRERR( str, 20*bytesperword ))
   OsByte(229,1)
$)

AND OUT(V) BE SWITCHON STYLE INTO
$( DEFAULT:
   CASE 'D': WRITEF("%IB ", V); RETURN
   CASE 'C': OUTW(V);           RETURN
   CASE 'F': WRITEF("%F ", V) ; RETURN 
   CASE 'X': WRITEF("%X8 ", V); RETURN
   CASE 'O': WRCH('*S')
             WROCT(V, 6)
             WRCH('*S')
             RETURN
   CASE 'S': $( LET l = !A & #xff; IF l > 80 DO l:= 80 
                WRITEF("<%n> ",l)  // show length
                FOR i = 0 TO l/bytesperword DO OUTW(A!i) 
             $)
$)

AND OUTW(C) BE 
$(
   WRITEF(" %C ", SPCHAR(C))
   WRITEF(" %C ", SPCHAR(C>>8))
   WRITEF(" %C ", SPCHAR(C>>16))
   WRITEF(" %C ", SPCHAR(C>>24))
$)

AND SPCHAR(C) = VALOF
$( C := C & #X7F
   IF 32 <= C < 127 THEN
      RESULTIS C
   IF C='*C' | C='*N' THEN
      RESULTIS '**'
   RESULTIS '.'
$)

AND PRADDR(A) BE
$(  LET GLOBBASE = @g0
    WRCH('*n')
    TEST GLOBBASE<=A<=(GLOBBASE+g0)
    THEN WRITEF(" G%I3 ", A-GLOBBASE)
    ELSE TEST VARS<=A<=VARS+9
         THEN WRITEF(" V%I2  ", A-VARS)
         ELSE WRITEF("%I9", A)
    WRITEF(" (%X8):  ", A)  $)

AND RCH() BE $( CH := CAPCH( RDCH()) $)

AND RDN(RADIX) = VALOF
$(  LET A, GOODN = 0, FALSE

    $( LET D = -1
       IF '0'<=CH<='9' DO D := CH-'0'
       IF 'A'<=CH<='F' DO D := 10+CH-'A'
       UNLESS 0<=D<RADIX BREAK
       GOODN := TRUE
       A := A*RADIX + D
       RCH()  $) REPEAT

    UNLESS GOODN DO XERROR("BAD NUMBER")
    RESULTIS A 
$)

AND RSIGCH() = VALOF
$( WHILE CH='*S' DO RCH()
   RESULTIS CH
$)

AND WROCT(N, D) BE
   FOR I = 1 TO D DO
      WRCH('0'+( (N >> (3*(D-I))) & 7 ))


AND XERROR(S, A) BE
$(  WRITEF(S, A)
    NEWLINE()
    UNRDCH()
    RCH() REPEATUNTIL CH='*N'
    LONGJUMP(REC.P, REC.L)
$)

AND REXP(A) = VALOF
$(1 SWITCHON CH INTO

    $( DEFAULT:   RESULTIS A

       CASE '.':
       CASE '!': A := !A;            ENDCASE
       CASE '+': A := A+RBEXPB();    LOOP
       CASE '-': A := A-RBEXPB();    LOOP
       CASE '**':A := A*RBEXPB();    LOOP
       CASE '/': A := A/RBEXPB();    LOOP
       CASE '%': A := A REM RBEXPB();LOOP
       CASE '<': A := A<<1;          ENDCASE
       CASE '>': A := A>>1;          ENDCASE
       CASE '&': A := A&RBEXPB();    LOOP
       CASE '|': A := A|RBEXPB();    LOOP
    $)
    CH := CAPCH(RDCH())
$)1 REPEAT


AND RBEXP() = VALOF SWITCHON CH INTO
$(1 DEFAULT:  XERROR("BAD EXPRESSION")

    CASE '0':CASE '1':CASE '2':CASE '3':CASE '4':
    CASE '5':CASE '6':CASE '7':CASE '8':CASE '9':
              RESULTIS RDN(10)

    CASE '*'': $( LET K = RDCH()
                  RCH()
                  RESULTIS K
               $)

    CASE '#': RCH()
              IF CH='X' DO
              $( RCH()
                 RESULTIS RDN(16)
              $)
              RESULTIS RDN(8)

    CASE 'G': RCH()
              UNLESS '0'<=CH<='9' RESULTIS @g0
              $( LET N=RDN(10)
                 IF N<=g0
                    RESULTIS (@g0)!N
              $)
              XERROR("MAX GLOBAL %N",g0)

    CASE 'V': RCH()
              UNLESS '0'<=CH<='9' RESULTIS VARS
              RESULTIS VARS!RDN1()

    CASE '-': RESULTIS -RBEXPB()
    CASE '+': RESULTIS  RBEXPB()
$)1


AND RBEXPB() = VALOF $( RCH()  REPEATWHILE CH = '*S'
                   RESULTIS RBEXP()  $)

AND RDN1() = VALOF
$(1 LET A = CH-'0'
    UNLESS 0<=A<=9 DO XERROR("BAD NUMBER")
    RCH()
    RESULTIS A  $)1


AND CHECKESC() = VALOF
$(
   LET r = OsByte( #x81, -113, #xFF )
   RESULTIS (r = Result2 = #xFF)
$)

AND backtrace() BE
$( LET firstloc = 0       // first local variable in stack
   LET sb = stackBase;
   stackBase!4 := Level();
   WriteS("*NBacktrace called*N")

   $( LET base = (sb+6)<<2
      LET lastp = sb!4;
      LET newp = ?
      LET p = VCAR[lastp+4]
      LET topframe = lastp-4

      TEST sb!5 = -1
         THEN writes("*NRoot stack:*N")
         ELSE $( newline()
                 writearg(sb!5, p)
                 writes(" coroutine stack:*N")
              $)

      IF topframe>[(sb!2)<<2]
         THEN writes("WARNING: Stack has overflowed or been corrupted*N");

      WriteS("*NStack-frame     Function    Arg 1     Arg 2     Arg 3     .....*N")

      FOR i = 1 TO 50 DO
      $( WriteF("%x6/%x6:  ", p, p>>2)  // stack frame
         WriteFName(VCAR p, p)
         WriteS("  ")
         FOR j = p+16 TO topframe BY 4 DO
         $( WriteArg(VCAR j, p)
            IF ((j-p-16) REM 20)=16 & (j~=topframe)
               THEN WriteS("*n                            ")
         $)
         newline();
         topframe := p-4;
         newp := VCAR[p+4]
         IF newp=p THEN $( WriteS("Base of stack*N")
                           BREAK
                        $);
         p := newp;
         UNLESS base<=p<=topframe THEN
         $( WriteF("Improper link %X8 %X8 %X8*N", base, p, topframe)
            BREAK
         $)
         IF topframe-p>200 THEN topframe := p+200  // not more than 50 args
      $)
      sb := sb!1
   $) REPEATUNTIL sb=-1;
   WriteS("*NEnd of backtrace*N")
$)

AND WriteFName(n, p) BE
   TEST n=-1
      THEN WriteS("ROOT      ")
      ELSE WriteArg(n, p)  // function name


AND WriteArg(n,p) BE  // Writes a hex no./function name in a 10 char field
$( // P is BCPL stack pointer
   LET f = n-8

   IF #x1000<f<=topOfStore & 0%f=7 & VCAR[f-4]=-1 THEN
   $( WriteF("%s   ", f>>2)
      RETURN
   $);

   IF -1000<n<1000 THEN
   $( WriteF("%x3(%i4) ", n, n)
      RETURN
   $)

   p := p>>2;
   IF p+4<=n<=p+54 THEN  // does n point to an item in this stack frame?
                         // (first 50 args)
   $( n := n-p-3
      WriteF("-> Arg%I2  ", n)
      RETURN
   $)

   WriteF("%x8  ", n)
$)

AND mapstore() BE
$(
   writes("*NMapstore called*N")

   DescribeCode(loadPoint)

   ShowGlobs()

   ShowBlocks()

   writes("*NEnd of mapstore*N")
$)

AND DescribeCode(q) BE
$( LET column = 0;
   LET sectionEnd = q;
   writes("Program code")
   UNTIL q>=sectionEnd & !q=EndMark DO
   $( LET word = !q;
      TEST q>=sectionEnd & word=SectionStart
         THEN $( LET name = VEC 2
                 AND date = VEC 2
                 AND time = VEC 2
                 AND unsetstring = "<unset>";
                 LET namel = 8;
                 LET versionWord = q!9;
                 sectionEnd := q+[(q!1)>>2];
                 FOR i = 0 TO 7 DO
                 $( LET c = q%(i+8);
                    IF c=0 & namel=8 THEN $( namel := i; BREAK $);
                    name%(i+1) := c
                 $);
                 name%0 := namel;
                 TEST q%16='<'
                    THEN date, time := unsetstring, unsetstring
                    ELSE $( FOR i = 0 TO 8 DO
                            $( date%(i+1) := q%(i+16);
                               time%(i+1) := q%(i+26)
                            $);
                            date%0 := 9;
                            time%0 := 8
                         $);
                 WriteF("*n*n%X6  Section %s", q<<2, name);
                 IF q!11=-1 & q%48=7 THEN
                 $( LET local = q!10;
                    IF VCAR local = VersionMark THEN
                    $( LET n = VCAR(local+4);
                       WriteF("  version %n.%n", n>>8, n&255)
                    $)
                 $)
                 WriteF("*n    compiled on %s at %s", date, time);
                 IF versionWord~=0 THEN
                    WriteF(" using CG version %n.%n",
                             versionWord>>24, (versionWord>>16)&255);
                 NewLine();
                 q := q+10;
                 column := 0
              $)

      ELSE TEST q=SectionEnd
         THEN // skip global initialisations
              q := q+2 REPEATWHILE (-1)!q~=0

      ELSE TEST q>=SectionEnd & word=StartRelocation
         THEN q := q+1 REPEATWHILE !q~=EndRelocation

      ELSE TEST word=-1 & q%4=7
         THEN $( LET procStart = q+2;
                 IF [(!procstart)>>24]=0
                    THEN procStart := procStart+1;
                 IF column>=linelength-16 THEN
                 $( newline()
                    column := 0
                 $);
                 writef("  %x6: %s", procStart<<2, q+1);
                 column := column+17;
                 q := procStart
              $)
         ELSE q := q+1   

      IF CHECKESC() $( NEWLINE(); BREAK $)
   $)
   newline()
$)

AND ShowGlobs() BE
$( 
   LET g = @G0
   LET nglobs = G0
   LET column = 0

   TEST ug<=nglobs<=10000
      THEN writef("*N%N globals allocated*N", nglobs)
      ELSE $( writes("Global zero is corrupted*N"); nglobs := 250 $)

   writef("*NValues set in Global Vector (%X6/%X6):*N", g, g<<2)

   FOR t = 0 TO nglobs DO
   $( LET val = g!t;
      IF [val&UnsetGlobalMask]~=UnsetGlobalValue THEN
      $( IF column>linelength-20 THEN
         $( newline()
            column := 0
         $)
         TEST t>=1000
            THEN writef("%i4: ",t)
            ELSE writef("G%I3: ", t)
         writearg(val, 0)
         writes("   ")
         column := column+20
      $)            
      IF CHECKESC() $( NEWLINE(); BREAK $)
   $)
   NEWLINE()
$)

AND ShowBlocks() BE
$(
   LET g = @G0
   LET p = blocklist

   writes("Memory blocks:*n")

   UNTIL !p=0 DO
   $( LET len = !p;
      writef("*n%x6/%x6: ", p+1, (p+1)<<2)
      TEST len<0 THEN  // used block
      $( TEST g = p+1
            THEN writes("Global vector")
         ELSE TEST stackbase = p+1
            THEN writes("Current stack")
         ELSE TEST p!1=HunkMark
            THEN DescribeCode(p)
            ELSE writef("Allocated Block of %N BCPL words", -len-1);
         len := -len
      $)

      ELSE  // freeblock
         writef("Free Block of %N BCPL words", len-1)

      p := p+len  // next block
   $)        
   NEWLINE()   
$)
.

