//  AES SOURCE  4.87

/**
         UT.RCPlib - RCP EMULATION LIBRARY
         ---------------------------------
                                 
         This file contains the BCPL sections required to emulate
         some of the RCP routines used by the lower level kernel.

         Routines:

         vdu
         move

         NAME OF FILE CONTAINING RUNNABLE CODE:

         $.Alib.Lib.xrcp

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         11.5.87  1        PAC      Initial version
         20.5.87  2        PAC      VDU - Trailing ';' bug fixed
         17.7.87     3     DNH      fix MOVE for MoveWords bug
         23.7.87     4     PAC      fix filetovec's Getvec
**/
                   
Section "RCPlib"

get "H/libhdr.h"

STATIC $( s.s = 0 ; s.p = 0 ; s.WRCH = 0 $) // used by RunProg

/**
         VDU - Send command to VDU driver
         --------------------------------

         This routine works as per the RCP spec, with the exception
         of hex numbers within the command string.

         INPUTS:

         command string + up to 10 parameters

         OUTPUTS:

         Result2 set 0 for success, non-zero otherwise

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Used only by the lower level graphics driver. Not for
         general use by overlays. Only real errors are when the
         string contains illegal characters.

         PROGRAM DESIGN LANGUAGE:

         String is a list of numbers or '%' characters, separated
         by ',' or ';', which may be preceded or followed by any 
         number of spaces.

         Each item of the string is processed in turn. If it is a 
         number terminated by ',' or end of string, it is written 
         as a byte to the VDU drivers using OsWrch. If terminated 
         by ';', it is written as 2 bytes, low byte first. If the 
         'number' is a '%' character, then the value to be sent is
         obtained from the next parameter.
**/

Let VDU( str,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 ) be
$(
   LET t,p,len = @p1,1, str%0
  
   result2 := 0

   WHILE p <= str%0 DO
   $(
      LET ch, sum, neg = 0,0,FALSE
lab:  ch := str%p 

      IF p > len BREAK

      UNLESS ('0'<=ch<='9') SWITCHON ch INTO
      $( DEFAULT:  result2 := -1; BREAK // abort the routine 
         CASE '*S':
         CASE '*T':
         CASE '*N': p := p + 1 ; GOTO lab
         CASE '-' : neg := TRUE
         CASE '+' : $( p := p + 1 ; ch := str%p $)  // next char
         IF p > len BREAK
         ENDCASE

         CASE '%' : 
         $( LET arg = t!0      
            p := p + 2        // point p at next char after ',' or ';'
            Send.( arg, str, p-1 )
            t := t + StackFrameDirection  // increment arg pointer
            GOTO lab 
         $) ENDCASE 
      $)
      WHILE '0'<=ch<='9' DO
      $( sum := 10*sum+ch-'0' ; p := p + 1 ; ch := str%p $)
      IF neg THEN sum := -sum
      Send.( sum, str, p )
      p := p + 1
   $)    
                        
$) 

AND Send.( arg, s, p ) BE
$(                                   
/*   Writef("*nVDU: Send %n (%x4) as %s",arg, arg, 
                             (s%p=';') & (p<=s%0) -> "word","byte")
*/
   OsWrch( arg & #xFF ) // do low byte
   IF (s%p = ';') & (p <= s%0)
   THEN OsWrch( (arg >> 8) & #xFF) // do high byte (16 bits)
$)   

/**
         MOVE - Block move operation
         ---------------------------

         INPUTS:

         move( from, to, words )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:
           
         Always moves forwards.  Emulates RCP 'MOVE'.
         Has a diagnostic for negative 'words' under DEBUG tag
         MoveWords, which it uses, has a bug.
         It does not behave correctly if 'words' is zero.                       
         PROGRAM DESIGN LANGUAGE:
         
         IF words > 0 DO
            call assembler MoveWords                       
         RETURN
**/

AND move( from.vec, to.vec, words ) BE
$( 
   $<debug
      IF words < 0 DO 
      $( Writef("*nMove : bad arg %n*n",words) 
         Oswrch(7) ; Abort(999) 
      $)
   $>debug                

   if words > 0 do
      MoveWords( 1, words, from.vec, to.vec )
$)

/**
         RUNPROG - Parameterised call to OSCLI
         -------------------------------------

         INPUTS:

         runprog( string, p1, p2, p3, p4 )

         OUTPUTS:

         TRUE if command succeeded

         GLOBALS MODIFIED:

         varied

         SPECIAL NOTES FOR CALLERS:

         This is a limited version of RunProg, similar to that
         found on the standalone RCP system. Useful for Oscli's
         Does a slight 'dirty' in that it uses Writef to generate 
         its command string, after redirecting Wrch

         PROGRAM DESIGN LANGUAGE:  
                                                  
         allocate space for string
         redirect Wrch to put chars into my string
         call writef with params
         tidy up Wrch 
         send string to Oscli -> returns TRUE if O.K.      
**/      

AND runprog( str, p1, p2, p3, p4 ) = VALOF  
$(
   LET ts = VEC 80/bytesperword // max 80 chars
   LET my.wrch( ch ) BE 
   $( s.s%s.p := ch ; s.p := s.p+1 
 $<debug
   IF s.p > 80 DO 
      $( WRCH := s.WRCH // restore it !
         Writef("*nRunprog : overflow %n*n",s.p)  
         OsWrch(7) ; Abort(999)     // fall over
      $) $>debug 
   $)
         
   s.s := ts ; s.p := 1        // set up the statics
   s.WRCH := WRCH
   WRCH   := my.wrch           // redirect routine
   Writef( str, p1,p2,p3,p4 )  // generate string
   WRCH   := s.WRCH            // restore routine

   ts%s.p := '*c'              // C/R termination
   ts%0   := s.p               // set length

   RESULTIS Oscli( ts )        // send it to Oscli - returns TRUE/FALSE
$)

/**
         FILETOVEC - Read a file to a vector
         -----------------------------------

         INPUTS:

         Current filing system file name

         OUTPUTS:

         Address of vector obtained, or 0 if failed
         If it fails, result2 has an error code.

         Format of returned vector is :
         
         word 0      : not used
         word 1      : number of bytes of data in vector
         word 2 on.. : data.

         GLOBALS MODIFIED:

         Result2 - if an error occurs

         SPECIAL NOTES FOR CALLERS:

         Watch out for those odd words at the front !!!

         PROGRAM DESIGN LANGUAGE:

         
**/
         
And FiletoVec( filename ) = VALOF
$(
   Let pb        = VEC 5
   Let dest.vec  = ? 
   Let file.size = ?
   Let res       = ?            
                                   
   res := Osfile( 5, filename, pb )

   If res = 0 DO $( Result2 := 27 ; RESULTIS 0 $)  // not found
   
   file.size := pb!2                               // in bytes
   dest.vec  := GETVEC( file.size/bytesperword+2 ) 
   
   If dest.vec = 0 DO $( Result2 := 51 ; RESULTIS 0 $)  // no room
                              
   dest.vec!1 := file.size                       // set up size in vec!1
   pb!1 := 0; pb!0 := (dest.vec+2)*bytesperword  // set up vector
   Osfile( #xFF, filename, pb )                  // load it
                                            
   If result2 ~= 0 DO $( FREEVEC( dest.vec ) ; RESULTIS 0 $)

   RESULTIS dest.vec
$)
.                    
