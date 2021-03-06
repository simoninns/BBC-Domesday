//  AES SOURCE  4.87

/**
         WRITE UTILITIES
         ---------------

         This module contains :

            G.ut.write
            G.ut.open.file
            G.ut.close.file

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.printwrite

         N.B. this file's CINTCODE to be linked to the overlay
         requiring the functions. NOT part of kernel.

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         17/2/86  1        PAC         Initial version
         26/3/86  2        PAC         Add call to close
                                       in write
         08/04/86 3        PAC         Zero stream on open fail
         15/04/86 4        PAC         Tidy up trap numbers
         24/06/86 5        PAC         Change suspect GETVEC to VEC
         27/06/86 6        PAC         Open.file deletes old file
                                       before opening new one
         15.07.86 7        PAC         Add new error message routine
         29.07.86 8        PAC         Bugfix open.file
         13.10.86 9        PAC         Tidy up error.message
         17.10.86 10       PAC         'Write finished' message
         20.10.86 11       PAC         do.32.line made global for NM
      *****************************************************************
       ARM versions beyond this point
          7.7.87  12       PAC         Bugfix for dumpit & text write
                                       & mod GBPB call
         21.7.87  13       PAC         Mod GBPB again
         7.10.87  14       PAC         
**/

Section "ut.write"

STATIC $( s.vec = 0 ; s.off = 0  $) // used for redefined WRCH

get "H/libhdr.h"
get "H/syshdr.h"
get "GH/glhd.h"
get "H/sdhd.h"
get "H/uthd.h"

/**
         G.UT.OPEN.FILE - OPEN A FILE FOR 'WRITE'
         G.UT.CLOSE.FILE - CLOSE FILE FOR 'WRITE'
         ----------------------------------------

         INPUTS:

         none

         OUTPUTS:

         Flag set to m.ut.success for a succesful open or close,
         else set to NOT m.ut.success

         GLOBALS MODIFIED:

         modifies G.ut.sequence.no
         saves stream number in G.ut.stream

         SPECIAL NOTES FOR CALLERS:

         This routine outputs an error message if it can't open
         or close the file.
         Message is:

         "Floppy error : <Error message> "

         where <Error message> is the error message string extracted
         from the I/O processor.
                        
         N.B. no error is returned from g.ut.close.file any more,
         because Osfind for close has no error indication.

         PROGRAM DESIGN LANGUAGE:


**/
LET G.ut.open.file() = VALOF
$(
   LET filename   = ?
   LET handle = ?
   LET num.string = VEC 3
   LET block      = VEC 5

   filename := "-adfs-DOM0000*c"            // raw filename: %10 first dig.

   G.vh.word.asc ( G.ut.sequence.no, num.string ) // convert the sequence number
   FOR i = 2 TO 5
      DO filename%(i+8) := num.string%i           // move least sig. digits

   G.ut.trap( "UT",3,FALSE,1,G.ut.stream,0,0 ) // trap on non-zero stream

   IF G.ut.stream ~= 0 THEN G.ut.close.file()  // ensure no file open already
                        
   Osfile( m.ut.delete.file, filename, block ) // delete any existing file

   handle := Osfind( m.ut.open.write, filename )  // then open it

   G.ut.sequence.no := G.ut.sequence.no + 1 // next file has new no.
   G.ut.stream      := 0                    // set stream zero

   if handle = 0                            // failed to open file
   then $( error.message() ; RESULTIS NOT m.ut.success $)   

   G.ut.stream := handle 
   RESULTIS m.ut.success
$)


AND G.ut.close.file() = VALOF
$(
   LET returncode = ?

   if G.ut.stream = 0 RESULTIS m.ut.success // no file to close
   
   Osfind( m.ut.close, G.ut.stream )        // close it

   G.ut.stream := 0    // we've closed the open file
   final.message()     // so tell the user where it is - added PAC 17.10.86
   RESULTIS m.ut.success
$)

//
// this routine gives the final message after a write
// it's basically a silent error message
// added 17.10.86 by PAC
//
AND final.message() BE
$(
   LET end.mess = "Data written to file DOM0000 " // message: %23 first dig.
   LET num.string  = VEC 3
   LET status = G.sc.pointer( m.sd.off )

   G.vh.word.asc( G.ut.sequence.no-1, num.string )   // convert sequence number
   FOR i = 2 TO 5 DO end.mess%(i+23) := num.string%i // move least sig. digits

   G.sc.cachemess( m.sd.save )           // save the message area
   G.sc.mess( end.mess )                 // display message
   G.sc.pointer( status )                // restore pointer
   G.ut.wait( m.sd.errdelay )            // hang around a bit
   G.sc.cachemess( m.sd.restore )        // restore message area
$)

/**
         G.UT.WRITE - WRITE DATA TO FLOPPY DISC
         --------------------------------------

         Writes data to the floppy disc file previously opened
         with G.ut.open.file in one of theree formats:
            - as a series of 16 bit numbers in ASCII
            - as a series of 32 bit numbers in ASCII
            - without modification
         The third option is for use with data that is already in
         an ASCII format: e.g. text pages, photo captions.

         INPUTS:

         pointer to data area to be written ( M/C address )
         size of area to be written ( in bytes )
         'type' of output to be used: 16 bit integers
         OR 32 bit integers OR pure binary ( a manifest from
         UTHDR )

         N.B. the pointer to data area, and the size of the area
         are in bytes, so if a vector contains the dump
         information, then its byte address and size in bytes
         must be passed.

         E.G.
          data.area := GETVEC ( vec.size )
          G.ut.write ( data.area * bytesperword,
                       vec.size  * bytesperword, 
                       m.ut.dump32 )

         OUTPUTS:

         flag set to m.ut.success for successful dump, or to the
         disc error code for failure.

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         In the cases of 16- and 32- bit integers to dump, the
         numbers are assumed to start at the WORD ADDRESS in
         memory, and to completely fill the data area. Both 16-
         and 32- bit formats are treated as signed integers, and
         the 32-bit numbers are low word then high word in
         memory.

         start address->
         < 16bit > < 16bit > < 16bit > < 16bit >
         <lo.word> <hi.word> <lo.word> <hi.word>

         PROGRAM DESIGN LANGUAGE:

         G.ut.write [ data pointer, data size, type of write ]
         ----------

         IF type of write is 'pure'
         THEN write data to disc, using OSGBPB.

         ELSE calculate required vector for the ASCII conversion
              IF required vector > max. available space
              THEN get a 40 character vector (one 'line')
                   FOR i = 1 TO number of required 'lines'
                   DO convert one 'line' of data
                      output  the 'line' to disc
                   END DO
              ELSE convert the entire buffer
                   save it onto disc
              ENDIF
         ENDIF
         IF an error occurred, give message of the form :
            "Error NNN while writing to floppy disc"
            Call close file
         ENDIF


**/

AND G.ut.write( data.ptr, data.size, type ) = VALOF
$( LET result = 0
   LET status = G.sc.pointer(m.sd.off) // 17.10.86 PAC

   $<debug
   G.ut.trap( "UT",4,FALSE,2,G.ut.stream,0,0 )    // trap on file handle zero
   $>debug

   TEST type = m.ut.text
   THEN $( LET end = TABLE m.ut.CR
           result := writeit ( data.ptr, data.size )
           result := writeit ( end*bytesperword, 1 ) // add CR to end of string
        $)
   ELSE result := dumpit ( data.ptr, data.size, type )

   G.sc.pointer( status ) // 17.10.86 PAC

   IF result ~= m.ut.success
   THEN $( result := result & #xFF
           error.message()
           G.ut.close.file()
           RESULTIS result
        $)
   // otherwise, write was successful
   RESULTIS m.ut.success
$)

AND error.message() BE
$(
   LET hed  = "Floppy error:*s" // message changed 13.10.86 PAC
   LET str  = VEC 50/bytesperword        
   LET ssiz = ?
   LET msiz = m.sd.disw - m.sd.mesXtex
   LET str  = VEC 50/bytesperword

   g.ut.get.ermess(str, 50)
                      
   g.ut.movebytes( str, 1, str, hed%0+1, str%0 )
   g.ut.movebytes( hed, 1, str, 1,       hed%0 )

   str%0 := str%0 + hed%0

   $( ssiz := G.sc.width( str )             // ensure message doesn't
      IF ssiz > msiz                        // overflow the message area
      THEN str%0 := str%0 - 1               // added 13.10.86 PAC
   $) REPEATUNTIL ssiz <= msiz

   G.sc.ermess( str )
$)                          

AND dumpit( byte.ptr, data.size, type ) = VALOF
$( LET req.vec = 0
   LET no.of.lines = ?
   LET success = FALSE
   LET source.ptr = byte.ptr / bytesperword
   LET convert  = ?
   LET stepsize = ?
   LET numbers  = ?
   LET n.p.l    = ?
   LET number.size = ?

                   // decide which conversion we're going to use

   TEST type = m.ut.dump16bit
      THEN $( convert     := do.16.line
              number.size := 2            // bytes     
              n.p.l       := 5   
           $)
      ELSE $( convert     := G.ut.do.32.line
              number.size := 4            // bytes 
              n.p.l       := 3
           $)

   stepsize := n.p.l * number.size / bytesperword 

                  // calculate number of numbers

   numbers := data.size / number.size      // this is the number of values
                                           // to be written 

                  // calculate required vector size

   no.of.lines := (numbers + n.p.l) / n.p.l   // round up to nearest number
   req.vec     := (no.of.lines * m.ut.chars.per.line) / bytesperword

   $<debug
   // G.sc.ermess("In write: max = %n, req = %n",MAXVEC(),req.vec)
   $>debug

   TEST req.vec > MAXVEC() // do it line by line
      THEN 
      $( 
         LET buffer = VEC( m.ut.chars.per.line/bytesperword )

         FOR i = 1 TO no.of.lines DO
         $( 
            convert( buffer, source.ptr, numbers )
            numbers    := numbers - n.p.l
            source.ptr := source.ptr + stepsize
            success    := writeit ( buffer*bytesperword, m.ut.chars.per.line )
            UNLESS success = m.ut.success RESULTIS success
         $)
      $)
      ELSE 
      $( 
         LET buffer     = GETVEC( req.vec )
         LET output.ptr = buffer     

         FOR i = 1 TO no.of.lines DO
         $(
            convert( output.ptr, source.ptr, numbers )
            numbers    := numbers - n.p.l
            output.ptr := output.ptr + m.ut.chars.per.line/bytesperword
            source.ptr := source.ptr + stepsize
         $)
         success := writeit ( buffer*bytesperword, req.vec*bytesperword )
         FREEVEC( buffer )
      $)
      RESULTIS success
$)

AND do.16.line ( out.ptr, src.ptr, numbers ) BE
$( 
   LET byteoff  = 0                 // byte offset into output vector
   LET limit    = numbers < 5 -> numbers, 5
   LET old.WRCH = WRCH                                    

   s.vec := out.ptr ; s.off := 0 ; WRCH := newWRCH

   FOR j = 1 TO limit DO
   $( LET number = g.ut.unpack16.signed( src.ptr, byteoff )
                     
      Writed( number, m.ut.chars16 ) // a number has max 7 chars + a space

      byteoff := byteoff + 2 // point to next number
   $)

   Wrch( '*C' )        // final c/r    
   WRCH := old.WRCH    // restore wrch
$)              

AND G.ut.do.32.line ( out.ptr, src.ptr, numbers ) BE
$( 
   LET off      = 0                 // word offset into output vector
   LET limit    = numbers < 3 -> numbers, 3
   LET old.WRCH = WRCH                                    

   s.vec := out.ptr ; s.off := 0 ; WRCH := newWRCH

   FOR j = 1 TO limit DO
   $( LET number = src.ptr!off
                     
      Writed( number, m.ut.chars32 ) // a number has max 12 chars + a space

      off := off + 1 // point to next number
   $)

   Wrch( '*C' )        // final c/r    
   WRCH := old.WRCH    // restore wrch
$)              

AND newWRCH( ch ) BE $( s.vec%s.off := ch ; s.off := s.off+1 $)

AND writeit( MC.ptr, byte.size ) = VALOF
$(
   LET pb = VEC 6
                 
   pb!0 := G.ut.stream
   pb!1 := MC.ptr
   pb!2 := byte.size
   pb!3 := 0

   Osgbpb( m.ut.write.op, pb )                // opcode

   unless Result2 = 0 resultis NOT m.ut.success

   resultis m.ut.success
$)



/*

AND G.ut.do.32.line ( out.ptr, src.ptr, numbers ) BE
$( LET byteoff = 0 // byte offset into o/p vector
   LET limit   = m.ut.32bit.nos.per.line

   IF numbers < m.ut.32bit.nos.per.line THEN limit := numbers

   FOR i = 0 TO m.ut.chars.per.line DO out.ptr%i := ' '

   FOR i = 1 TO limit DO
   $( LET ten      = TABLE 10,0 // 32 bit value of 10
      LET negative = FALSE      // flag negative number
      LET digits   = 0          // count of digits
      LET fraction = VEC 1
      LET number   = VEC 1      // copy of the number

      // check for negative number
      TEST (src.ptr!1 & #x8000) ~= 0 // top bit set
      THEN $( negative := TRUE
              number!0 := src.ptr!0 NEQV #xFFFF
              number!1 := src.ptr!1 NEQV #xFFFF
              TEST number!0 = #xFFFF
                 THEN $( number!1 := number!1 + 1
                         number!0 := 0
                      $)
                 ELSE number!0 := number!0+1
           $)
      ELSE $( number!0 := src.ptr!0     // transfer it as it stands
              number!1 := src.ptr!1
           $)

      FOR j = 11 TO 2 BY -1 // max 10 digits
      $( G.ut.div32( ten, number, fraction )
         out.ptr%(byteoff+j) := fraction!0 + '0'
         digits   := digits + 1
         IF (number!0=0) & (number!1=0) THEN BREAK // early exit
      $)

      IF negative THEN out.ptr%(byteoff+11-digits) := '-' // tidy string - add minus sign

      byteoff := byteoff + m.ut.chars32
      src.ptr := src.ptr + 2
   $)
   out.ptr%(m.ut.chars.per.line-1) := m.ut.CR

$)

*/


.
