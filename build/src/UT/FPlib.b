                                      
//  AES SOURCE  4.87

/**
         UT.FPlib - FP EMULATION LIBRARY
         --------------------------------
                                 
         This file contains the BCPL sections required to emulate
         some of the RCP routines used by overlays to do floating
         point arithmetic.

         Routines:

         ffloat 
         fplus
         fminus
         fmult
         fdiv
         fsqrt
         fabs
         fcomp
         fsgn
         fint
         fln
         fexp
         fneg

         sin 
         cos
         asn
         sqr

         writesg
         flit
         writefp (++++++++++++++ hacked version for the moment )

         NAME OF FILE CONTAINING RUNNABLE CODE:

         $.Alib.Lib.xfplib

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         2.6.87   1        PAC      Initial version
         12.6.87  2        PAC      Added intcalc
         22.6.87  3        PAC      Added flit from MP       
         10.7.87  4        PAC      Dummy version of writefp
         13.7.87  5        PAC      Added fsgn, fint, fln, 
                                     fexp, fneg
         20.7.87  6        DNH      Fix fdiv for /0 handling
**/
                   
Section "FPlib"

get "H/libhdr.h"

STATIC $( s = 0; i = 0; ch = 0 $) // used by flit, etc.

/**                                                           
         FLOATING POINT ROUTINES
         -----------------------

         These routines have been put together to look 
         like the RCP calculatins package. They generally
         return a pointer to the result vector, as the 
         procedure result. A global, fpexcep, is used to
         keep track of errors and exceptions. See the 
         documentation for RCP package for a full explanation.

**/

LET ffloat( value, vptr ) = VALOF
$( !vptr := FLOAT value
   RESULTIS vptr
$)

// ffix rounds the number up/down:
//  8.7 ->  9,  8.3 ->  8
// -8.7 -> -9  -8.3 -> -8
//
AND ffix( value ) = VALOF
$(                         
   IF (FLOAT MININT) #<= !value #<= (FLOAT MAXINT) 
   THEN RESULTIS (FIX !value)

   fpexcep := 2  // overflow - set result to max- or min-int, and flag error

   RESULTIS (!value #< 0.0) -> MININT, MAXINT
$)
                                 
// fint truncates the value
//  0.0 ->  0  
//  8.7 ->  8,  8.3 ->  8
// -8.7 -> -9, -8.3 -> -9 
//
AND fint( value ) = VALOF
$(                         
   IF (FLOAT MININT) #<= !value #<= (FLOAT MAXINT) THEN
      TEST !value #> 0 THEN
         RESULTIS FIX (!value #- 0.5)
      ELSE
         RESULTIS FIX (!value #- 0.4999999999)   // how many 9's ??? ++++

   fpexcep := 2  // overflow - set result to max- or min-int, and flag error

   RESULTIS (!value #< 0.0) -> MININT, MAXINT
$)
         
AND fplus ( pt1, pt2, pt3 ) = VALOF
$( !pt3 := !pt1 #+ !pt2   
   RESULTIS pt3
$)

AND fminus( pt1, pt2, pt3 ) = VALOF
$( !pt3 := !pt1 #- !pt2      
   RESULTIS pt3    
$)

AND fmult( pt1, pt2, pt3 ) = VALOF   
$( !pt3 := !pt1 #* !pt2    
   RESULTIS pt3 
$)
  
                                                          
/*
   FDIV  Now modded to avoid trap on divide by 0.
         Returns immediately if pt2, the 16 bit 
         divisor, is 0.  20.7.87
*/

AND fdiv ( pt1, pt2, pt3 ) = VALOF   
$( 
   let a, b = !pt1, !pt2               

   test b #= 0.0 then
      fpexcep := ( a #= 0.0 ) -> 7,1
   else
      !pt3 := a #/ b     

   RESULTIS pt3
$)   
    
AND fsqrt( pt1, pt2 ) = VALOF      
$(
   LET a = !pt1

   IF a #< 0.0 THEN $( fpexcep := 5; a := #ABS a $)
             
   !pt2 := SSqrt( a )

   RESULTIS pt2
$)
             
AND fabs( pt1, pt2 ) = VALOF
$(
   !pt2 := #ABS !pt1
   RESULTIS pt2
$)

AND fcomp( pt1, pt2 ) = VALOF
$(          
   LET a,b = !pt1, !pt2

   RESULTIS a #< b -> -1,    // a > b result -1 (greater)
            a #> b ->  1, 0  // a < b result  1 (less)
                             // otherwise, must be same (0)
$)
                        
// fsgn - a fcomp with zero
//
AND fsgn( pt1 ) = VALOF
$(
   LET zero = FLOAT 0
   RESULTIS fcomp( pt1, @zero )
$)
         
AND fln( pt1, pt2 ) = VALOF
$(               
   LET a = !pt1

   IF a = 0.0 THEN 
   $( fpexcep := 8; !pt2 := 0.0; RESULTIS pt2 $)

   IF a #< 0.0 THEN
   $( fpexcep := 8; a := #-a $)

   !pt2 := SlogE( a ) 
    
   RESULTIS pt2
$)

AND fexp( pt1, pt2 ) = VALOF
$(
   !pt2 := Sexp( !pt1 ); RESULTIS pt2
$)

AND fneg( pt1, pt2 ) = VALOF
$(                        
   !pt2 := #- !pt1; RESULTIS pt2
$)
                                                    
/**
         'FAST' INTEGER ROUTINES
         -----------------------

         Emulation of RCP INTCALC package
   
         routines are SIN, COS, ASN, SQR

         values returned are 16 bit integers representing
         the appropriate value scaled by 10,000.

**/                                      

AND sin( ang ) = calc.( ang, SSin )

AND cos( ang ) = calc.( ang, SCos )

AND asn( ang ) = calc.( ang, SASin )

AND calc.( ang, op. ) = FIX ( op.( (FLOAT ang) #/ 10000.0 ) #* 10000.0 )     

AND sqr( scaled.arg, scale ) = VALOF
$(
   LET real.arg = 0.0 
   LET fl.scale = FLOAT scale

   real.arg := (FLOAT scaled.arg ) #/ fl.scale

   RESULTIS FIX ( SSqrt( real.arg ) #* fl.scale )
$)

       
/**
         FLOATING POINT NUMBER OUTPUT
         ----------------------------

         The routines WRITESG and WRITEFP.

**/


/**
         WRITESG - FP WRITE SPECIFIED SIGNIFICANT FIGURES
         ------------------------------------------------

         Emulation of RCP routine

         INPUTS:

         pointer to fp number
         field width in chars
         number of significant digits

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Works as per RCP specification described in the 
         Calculations package user guide.

         PROGRAM DESIGN LANGUAGE:

         Writesg [ Nptr, width, digits ]                
         -------

         limit number of digits to value between 2 & 12.
     
         extract sign of number.
      
         split number into integer part, fractional part
         and exponent.
      
         convert number into a series of digits in buffer
         adjust exponent, and round up to 'digits'
         significant digits. 

         strip trailing zeroes.
                
         decide upon print format.
         
         this is done by:
   
         a) testing for an integer ( i.e. decimal point comes
               after the last non-zero digit )
      
         b) testing for a number of the form nnn.ffff This is
               determined by the decimal point ocurring within the
               'string' of significant digits.

         c) otherwise, number must be of type 0.00ffff

         calculate the required width to print the number in the 
         given format.

         if there's enough room, then go ahead and print it
         else print in scientific format. 

                                <-digits->
         scientific format is 'sn.nnnnn000Esee' - s is sign
**/
AND writesg( nptr, width, digits ) BE
$(
   LET number = !nptr
   LET ipart, fpart, expo = ?,?,?   // the components of the number
   LET buffer = VEC 24/bytesperword // somewhere to put the digits
   LET sign, nzdigit, req.width, where = FALSE,0,0,0

   FOR i = 0 to 24 buffer%i := '.' // debug line - initialise buffer

   // stage 1 - limit digits to sensible value
   //
   digits := ( digits > 12 ) -> 12, 
             ( digits <  2 ) ->  2, digits
   
   IF number #<0.0 THEN sign := TRUE
   number := #ABS number

   // stage 2 - split up the number into its component parts
   //
   split.number( number, @ipart, @fpart, @expo )

   // stage 3 - convert number to decimal, giving 'digits' 
   //           significant figures, adjust exponent and
   //           return a pointer to last non-zero digit.
   //
   nzdigit := number.to.digits( @expo, ipart, fpart, buffer, digits )
                      
   /* diagnostics - display buffer                      
      Wrch('*n')
      FOR i = 0 TO 23 DO
      $( LET ch = buffer%i + '0'
         IF '0'<=ch<='9' Wrch(ch)
      $)
   */  

   // N.b. nzdigit is <= digits - it is number of digits with 
   // trailing zeroes suppressed.

   // stage 4 - decide upon the print format
   //   
   TEST (expo > nzdigit-2 )                 // print in integer format
   THEN $( req.width := expo + 2    
           TEST req.width <= width    
           THEN $(               
                   header.(width - req.width, sign)
                   FOR i = 0 TO expo
                   WrNum.( (i<nzdigit) -> buffer%(i+4),0 )   
                $)
           ELSE sci.print( expo, buffer, digits, width, sign )    
        $)

   ELSE TEST 0<=expo<=(nzdigit-2)        // number is 'nnn.fffff' type
        THEN $( req.width := nzdigit + 2; where := expo
                TEST req.width <= width
                THEN $(
                        header.(width - req.width, sign) 
                        FOR i = 0 to nzdigit-1 
                        $( WrNum.( buffer%(i+4) )
                           IF i = where Wrch('.')
                        $)    
                     $)
                ELSE sci.print( expo, buffer, digits, width, sign )   
             $)
        ELSE $( req.width := nzdigit + 3 -( expo + 1 )  // type 0.00ffff
                TEST req.width <= width    // n.b. -(exp+1) is number of
                THEN $(                    // ZEROES after '0.'
                        header.(width - req.width, sign)   
                        WrNum.( 0 ); Wrch('.')
                        FOR i = 1 to -(expo + 1) WrNum.( 0 )
                        FOR i = 0 to nzdigit-1 WrNum.( buffer%(i+4) )
                     $)
                ELSE sci.print( expo, buffer, digits, width, sign )
             $)
$) 
         
AND header.( leading.space, sign ) BE
$( FOR i = 1 TO leading.space Wrch('*S')     
   Wrch( sign -> '-','*s') 
$)     

AND WrNum.(n) BE Wrch( '0' + n )
  
AND split.number( num, iptr, fptr, exptr ) BE
$(
   LET bx = (num & #X7F800000) >> 23        // binary exponent
   LET dx = (16103*(bx-#X7F)+8051)/53493    // decimal exponent
                               // 16103/53493 = log10(2) to about 8 decimals
   LET n = 0
   LET fpnumbase = 1e9

   TEST bx=0 THEN IF num=0 THEN dx := 0 // special case with 0.0   
   ELSE 
   $(                                        

      TEST dx<3 THEN   // Input number is smallish   
      $(   
         dx := dx-3; n := -dx
         UNTIL n<9 DO $( num := num#*fpnumbase; n := n-9 $)
         UNTIL n=0 DO $( num := num#*10.0; n := n-1 $) 
      $)

      ELSE TEST dx<6 THEN dx := 0 // up to about a million

      ELSE              // Big numbers
      $(
         dx := dx-3; n := dx
         UNTIL n<9 DO $( num := num#/fpnumbase; n := n-9 $)
         UNTIL n=0 DO $( num := num#/10.0; n := n-1 $) 
      $) 
   $)

   n   := Truncate(num)
   num := num #- FLOAT n

// Now I have split the number into its sign, an integer N that is in
// the range 100 to 1000000, and a fraction (num). The fraction may
// occasionally be -ve or >=1.0 here, so adjust for same. I only expect
// the fraction to be wrong occasionally, and then only by + or -1.

   WHILE num#<0.0  DO $( n := n-1; num := num#+1.0 $)
   WHILE 1.0#<=num DO $( n := n+1; num := num#-1.0 $)

   // return values
   //
   !iptr  := n     // integer part
   !fptr  := num   // fractional part
   !exptr := dx    // exponent
                                 
   // note that the exponent is now roughly Log10( number ),
   // BUT the number has been split into an integer & fraction
   // thus the value of the exponent will need adjusting.
$)


// Convert number to decimal in given buffer   
//
AND number.to.digits( exptr, ipart, fpart, buffer, digits ) = VALOF
$(
   // put the integer part into the buffer at offset 4

   LET p = PackNum(ipart, Buffer, 4)   

   !exptr := !exptr + p-5 // adjust exponent to allow for
                          // number of 10's before the point
   FOR i = 1 TO digits DO        
   $(                             // now convert the fractional part
      fpart := fpart#*10.0        // this converts 9 digits of the 
      ipart := Truncate(fpart)    // fraction into FPBuffer
      fpart := fpart#-FLOAT ipart 
      Buffer%p := ipart
      p := p+1 
   $) 
                                             
//
// Now buffer looks like this :
//
//  xxxx123467.54854865    * 10^ <exp>
//            ^ point is t.b.d.      
// 'digits' points into the buffer from the start of
// the numbers towards the last significant digit.
//                   
// Next round up last sig. digit in Buffer   

   IF Buffer%(digits+4)>=5       // last digit is more than 5
   THEN                          // so...
   $( 
      LET d = ?
      p := digits+3             // add one to the penultimate digit
      $(
         d := Buffer%p
         TEST d = 9 
         THEN TEST p=4          // highest number - increment exponent
              THEN $( Buffer%p := 1; !exptr := !exptr+1; BREAK $)
              ELSE $( Buffer%p := 0;  p := p-1 $)
         ELSE $( Buffer%p := d+1; BREAK $)  

      $) REPEAT 
   $)
                    
   // strip trailing zeroes    

   WHILE digits>(1+!exptr) & (Buffer%(digits+3)=0) DO
     digits := digits-1

   RESULTIS digits

$)

// print the number in scientific format
//           
AND sci.print( expo, buffer, digits, width, sign ) BE   
$( 
   FOR i = 1 TO width - (digits + 6) Wrch('*s') // leading space
   Wrch( sign -> '-','*s')
   WrNum.( buffer%4 )
   Wrch('.')
   FOR i = 1 TO digits-1 WrNum.( buffer%(i+4) )
   Wrch('E')

   TEST expo < 0 THEN $( WrCh('-'); expo := -expo $) ELSE Wrch('+')
   IF expo < 10 Wrch('0'); WriteN(expo) 
$)

// Packnum() puts digits in the range 0-9 into the given
// buffer. Works like Writeoct, but the values that it 
// inserts are binary values (so add '0' to make chars).
// Return value is the offset of next space in buffer.
//
AND PackNum(n, buff, offset) = VALOF 
$(
   IF n>=10 THEN offset := PackNum(n/10, buff, offset)
   buff%offset := n REM 10
   RESULTIS offset+1 
$)
             
//                              
// Truncate(n)
// ensure n is positive before calling this    
// 
AND Truncate(n) = VALOF 
$(        
   LET i = FIX n
   RESULTIS (FLOAT i) #> n -> i-1, i 
$)
             

/**
         WRITEFP - FP WRITE WITH SPECIFIED DECIMAL PLACES
         ------------------------------------------------

         Emulation of RCP routine

         INPUTS:

         pointer to fp number
         field width in chars
         number of decimal places

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Works as per RCP specification described in the 
         Calculations package user guide.

         PROGRAM DESIGN LANGUAGE:

         Writefp [ Nptr, width, places ]                
         -------

         limit number of digits to value between 2 & 12.
     
         extract sign of number.
      
         split number into integer part, fractional part
         and exponent.
      
         convert number into a series of digits in buffer
         adjust exponent, and round up to 'digits'
         significant digits. 

         strip trailing zeroes.
                
         decide upon print format.
         
         this is done by:
   
         a) testing for an integer ( i.e. decimal point comes
               after the last non-zero digit )
      
         b) testing for a number of the form nnn.ffff This is
               determined by the decimal point ocurring within the
               'string' of significant digits.

         c) otherwise, number must be of type 0.00ffff

         calculate the required width to print the number in the 
         given format.

         if there's enough room, then go ahead and print it
         else print in scientific format. 

                                <-digits->
         scientific format is 'sn.nnnnn000Esee' - s is sign
**/
                              
AND writefp( nptr, width, places ) BE
$(
   LET number = !nptr
   LET ipart, fpart, expo = ?,?,?   // the components of the number
   LET buffer = VEC 24/bytesperword // somewhere to put the digits
   LET sign, nzdigit, req.width, where = FALSE,0,0,0
   LET digits = ?                  

   FOR i = 0 to 24 buffer%i := '.' // debug line - initialise buffer

   // stage 1 - limit digits to sensible value
   //
   digits := ( places > 12 ) -> 12, 
             ( places <  2 ) ->  2, places
   
   IF number #<0.0 THEN sign := TRUE
   number := #ABS number

   // stage 2 - split up the number into its component parts
   //
   split.number( number, @ipart, @fpart, @expo )

   // stage 3 - convert number to decimal, giving 'digits' 
   //           significant figures, adjust exponent and
   //           return a pointer to last non-zero digit.
   //
   nzdigit := number.to.digits( @expo, ipart, fpart, buffer, digits )
                      
   /* diagnostics - display buffer                      
      Wrch('*n')
      FOR i = 0 TO 23 DO
      $( LET ch = buffer%i + '0'
         IF '0'<=ch<='9' Wrch(ch)
      $)
   */  

   // N.b. nzdigit is <= digits - it is number of digits with 
   // trailing zeroes suppressed.

   // stage 4 - decide upon the print format
   //   
   TEST (expo > nzdigit-2 )                 // print in integer format
   THEN $( req.width := expo + 2    
           TEST req.width <= width    
           THEN $(               
                   header.(width - req.width, sign)
                   FOR i = 0 TO expo
                   WrNum.( (i<nzdigit) -> buffer%(i+4),0 )   
                $)
           ELSE sci.print( expo, buffer, digits, width, sign )    
        $)

   ELSE TEST 0<=expo<=(nzdigit-2)        // number is 'nnn.fffff' type
        THEN $( req.width := nzdigit + 2; where := expo
                TEST req.width <= width
                THEN $(
                        header.(width - req.width, sign) 
                        FOR i = 0 to nzdigit-1 
                        $( WrNum.( buffer%(i+4) )
                           IF i = where Wrch('.')
                        $)    
                     $)
                ELSE sci.print( expo, buffer, digits, width, sign )   
             $)
        ELSE $( req.width := nzdigit + 3 -( expo + 1 )  // type 0.00ffff
                TEST req.width <= width    // n.b. -(exp+1) is number of
                THEN $(                    // ZEROES after '0.'
                        header.(width - req.width, sign)   
                        WrNum.( 0 ); Wrch('.')
                        FOR i = 1 to -(expo + 1) WrNum.( 0 )
                        FOR i = 0 to nzdigit-1 WrNum.( buffer%(i+4) )
                     $)
                ELSE sci.print( expo, buffer, digits, width, sign )
             $)
$) 

/**
         FLIT - CONVERT LITERAL STRING TO FP NUMBER
         ------------------------------------------

         Emulation of RCP routine

         INPUTS:

         string pointer
         pointer to vector to store number (1 32-bit word)

         OUTPUTS:

         pointer to result vector, just as passed

         GLOBALS MODIFIED:

         fpexcep - sets to 9 if an error is detected
         whilst parsing the string.

         SPECIAL NOTES FOR CALLERS:

         see RCP documentation. 

         If an error is detected, the return value is the value
         of the string up to the point where the error occurred

         This routine differs from the RCP one in that it allows
         the string to have trailing spaces without setting FPEXCEP.
         Any other characters after the number set FPEXCEP, however.

         PROGRAM DESIGN LANGUAGE:

         FLIT [ string, vptr ] = 

         convert string to FP number

         place number in destination vector

         return pointer to destination vector
**/

AND r.() be // pick up first non-space from string
$( test i = s%0 then ch := -1 or $( i := i + 1; ch := s%i $)
$) repeatwhile ch = '*s'

AND flit( s0, v ) = VALOF
$(    
   LET ten = 10.0
   LET negative = FALSE
   LET exp = 0

   s,i   := s0,0 // set up statics
   !v    := 0.0  // and result

   r.()             
   if ch < 0  $( FPEXCEP := 9 ; resultis v $) // nothing in string
   if ch ='-' $( negative := TRUE; r.() $)
   test ch = 'E' | ch = 'e' then !v := 1.0 or
   $( let pointfound = FALSE
      !v := 0.0
      $( test ch = '.' then
         $( if pointfound $( FPEXCEP := 9 ; resultis v $) // 2 decimal points  
            pointfound := TRUE
         $) or test '0' <= ch <= '9' then
         $( 
            !v := !v #* ten 
            !v := !v #+ float( ch-'0') 
            if pointfound do exp := exp-1
         $) or break
         r.()
      $) repeat
   $)
   if ch = 'E' | ch = 'e' do
   $( let sign,n  = 1,0
      r.()
      if ch = '-' do $( sign := -1; r.() $)
      while '0' <= ch <= '9' do $( n := n * 10 + ch - '0'; r.() $)
      exp := exp+sign*n
   $)                   
   ten := Spower( ten, FLOAT exp )

  // diagnostics ... Writef("*nnum = %f, exp = %n, pow = %f*n",!v,exp,ten)     

   !v  := ten #* !v
   if negative do !v := #- !v
   unless ch < 0 FPEXCEP := 9 // invalid char in string

   resultis v
$)
                     


/* ***********************************************
// test section for flit

AND start() BE
$(
   LET n,ch = ?,?
   LET str  = VEC 20                              
                     
   ENDREAD();ENDWRITE();
   SELECTINPUT(FINDINPUT("VDU:"));
   SELECTOUTPUT(FINDOUTPUT("VDU:"));

   $(rpt
     
   ch := RDCH() REPEATUNTIL ch='*N' | ch=ENDSTREAMCH

   Writes("Enter number : ")                                       
   RDITEM( str, 20 )

   IF checkesc() BREAK 
   
   FPEXCEP := 0

   Writef("string is :<%s>",str)                                 

   flit( str, @n )  

   Writef("*n number is : %f , fpexcep = %n*n*n",n, fpexcep)

   $)rpt REPEAT

$)
  
AND checkesc() = VALOF
$(
   LET r = OsByte( #x81, -113, #xFF )
   RESULTIS (r = Result2 = #xFF)                  
$)

*************************************/

/***********************************************
//// test section for writesg
//
//AND start() BE
//$(
//   LET n,ip,fp,ep = ?,?,?,?
//                                             
//   ENDREAD();ENDWRITE();
//   SELECTINPUT(FINDINPUT("VDU:"));
//   SELECTOUTPUT(FINDOUTPUT("VDU:"));
//   
//   $(rpt
//
//   Writes("*nEnter int. part :"); ip := READN()
//   Writes("Enter frac part :"); fp := READN()   
//   Writes("Enter exp. part :"); ep := READN()    
// 
//   n := (FLOAT ip) #+ (FLOAT fp #/ 1000.0) 
//   While ep > 0 DO $( n := n #* 10.0; ep := ep -1 $)
//   While ep < 0 DO $( n := n #/ 10.0; ep := ep +1 $)                          //  
//   Writef("*n******** number is : %f*n*n",n)
//  
//   FOR digits = 12 TO 2 BY -1 DO 
//   $(
//      Writef("*n%i2>",digits)
//      
//      FOR width  = 20 TO 2 BY -1 DO 
//      $(
//         Writesg( @n, width, digits )
//         NEWLINE() 
//         IF checkesc() stop(256) 
//      $)           
//   $)
//   NEWLINE()   
//
//   $)rpt REPEAT
//$)
//     
//AND checkesc() = VALOF
//$(
//   LET r = OsByte( #x81, -113, #xFF )
//   RESULTIS (r = Result2 = #xFF)
//$)
//
// old flit bits
//   LET sum, ch, neg = 0, 0, FALSE
//   LET p, max = 0, s%0
//        
//   !vptr #= 0.0 // initialise result
//
//l: p  := p+1
//   ch := s%p
//
//   UNLESS ('0'<=ch<='9') SWITCHON ch INTO
//   $( DEFAULT: fpexcep := 9    // error detected early
//               RESULTIS vptr  
//      CASE '*S':
//      CASE '*T':
//      CASE '*N': GOTO l
//      CASE '-':  neg := TRUE
//      CASE '+':  p := p + 1; ch := s%p
//   $)
//
//   WHILE '0'<=ch<='9' DO
//   $( sum := 10*sum+ch-'0'  
//      p := p+1; ch  := s%p $)
//
//   IF neg THEN sum := -sum
//
//
//
//
//
//   !vptr := sum
//
//   RESULTIS vptr
//$)
//
    ****************************************************** 
*/
