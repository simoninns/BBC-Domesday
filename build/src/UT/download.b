/**
         WRITE UTILITIES
         ---------------

         This module contains :

            G.ud.write
            G.ud.open.file
            G.ud.close.file
         NB - closely based on g.ut.* in b.write

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.download

         N.B. this file's CINTCODE to be linked to the overlay
         requiring the functions. NOT part of kernel.

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
       3.02.87    1        SRY         Adopted for User Data
      29.06.87    2        SRY         Delete file option
      24.12.87    3        MH          Modified for Arcimedes port
      05.01.88    4        MH          writeit updated. Parameter data.ptr
                                       is passed as byte addr 
**/

Section "ud.write"

get "H/libhdr.h"
get "H/syshdr.h"
get "GH/glhd.h"
get "H/sdhd.h"
get "H/uthd.h"

/**
         G.UD.OPEN.FILE - OPEN A FILE FOR 'WRITE'
         G.UD.CLOSE.FILE - CLOSE FILE FOR 'WRITE'
         ----------------------------------------

         INPUTS:

         none

         OUTPUTS:

         Flag set to m.ut.success for a succesful open or close,
         else set to disc error number.

         GLOBALS MODIFIED:

         modifies G.ut.sequence.no
         saves stream number in G.ut.stream

         SPECIAL NOTES FOR CALLERS:

         This routine outputs an error message if it can't open
         or close the file.
         Message is:

         "Error NNN in <opening><closing> floppy disc file"

         where NNN is the error number.

         PROGRAM DESIGN LANGUAGE:
**/

LET G.ud.open.file(user.string) = VALOF
$( LET returncode = ?
   LET errorcode = ?
   LET num.string = VEC 3
   LET l = user.string%0
   let handle = 0
   LET filename =
   "-ADFS-*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S"
   // compiler bug !
   FOR i = 1 TO l filename%(i+6) := user.string%i
   filename%(l + 7) := '*C' // -ADFS- takes 6
   filename%0 := l + 7

   G.ut.trap("UT",3,FALSE,1,G.ut.stream,0,0 ) // trap on non-zero stream

   UNLESS G.ut.stream = 0 g.ud.close.file()    
                                    // make sure we don't have an open file


   // Check file doesn't already exist
   handle := osfind(m.ut.open.read, filename)
   if handle ~= 0 do         // bad handle: out of range
   $( let string = vec 39/bytesperword
      let mess = "File exists: overwrite (y/n)? "
      G.sc.mess(mess)
      g.sc.movea(m.sd.message, g.sc.width(mess)+8, m.sd.mesytex)
      OSFIND(m.ut.close, handle)
      RESULTIS handle
   $)

   G.ut.stream := OSFIND(m.ut.open.write, filename) // Open file for write


   TEST G.ut.stream = 0
   THEN $( error.message()
//           RESULTIS G.ut.stream
           RESULTIS ~G.ut.stream  //only a temporary fix until error checking
                                  //from osfind is sorted out 05.01.88 MH
        $)
   ELSE RESULTIS m.ut.success
$)

AND g.ud.close.file() = VALOF
$(
   LET returncode = ?

   TEST G.ut.stream = 0
      THEN RESULTIS TRUE // no file to close
   ELSE OSFIND(m.ut.close, G.ut.stream)

   G.ut.stream := 0 // we've closed the open file
   RESULTIS m.ut.success
$)

/**
         g.ud.WRITE - WRITE DATA TO FLOPPY DISC
         --------------------------------------

         Writes data to the floppy disc file previously opened
         with g.ud.open.file in one of theree formats:
            - as a series of 16 bit numbers in ASCII
            - as a series of 32 bit numbers in ASCII
            - without modification
         The third option is for use with data that is already in
         an ASCII format: e.g. text pages, photo captions.

         INPUTS:

         pointer to data area to be written ( 16 bit integer )
         size of area to be written ( 16 bit integer )
         'type' of output to be used: 16 bit integers
         OR 32 bit integers OR pure binary ( a manifest from
         UTHDR )

         N.B. the pointer to data area, and the size of the area
         are in bytes, so if a vector contains the dump
         information, then its byte address and size in bytes
         must be passed.

         E.G.
          data.area := GETVEC ( vec.size )
          g.ud.write ( data.area <<1, vec.size <<1, m.ut.dump32 )

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

         g.ud.write [ data pointer, data size, type of write ]
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

AND g.ud.write( data.ptr, data.size, type ) = VALOF
$( LET result = 0
   LET status = G.sc.pointer(m.sd.off) // 17.10.86 PAC

   $<debug
   G.ut.trap( "UT",4,FALSE,2,G.ut.stream,0,0 )    // trap on file handle zero
   $>debug
   TEST type = m.ut.text
   THEN $( LET end = TABLE m.ut.CR
           result := writeit ( data.ptr, data.size )
           result := writeit ( end * bytesperword, 1 ) 
                                                  // add a CR to end of string
        $)
   ELSE TEST type = m.ut.dump16bit
        THEN result := dumpit ( data.ptr, data.size, m.ut.16bit.nos.per.line )
        ELSE result := dumpit ( data.ptr, data.size, m.ut.32bit.nos.per.line )

   G.sc.pointer( status ) // 17.10.86 PAC

   IF result ~= m.ut.success
   THEN $( result := result & #xFF
           error.message()
           g.ud.close.file()
           RESULTIS result
        $)
   // otherwise, write was successful
   RESULTIS m.ut.success
$)

AND error.message() BE
$(
   LET head     = "Floppy error:  " // message changed 13.10.86 PAC
   LET hlen     = head%0
   LET hsiz     = hlen>>1
   LET ssiz     = ?
   LET msiz     = m.sd.disw - m.sd.mesXtex
   LET string   = VEC 25
   LET length   = G.ut.get.ermess( string+hsiz , 50-hlen )

   FOR i = 1 TO hlen-1 DO string%i := head%i

   string%0 := length+hlen

   $( ssiz := G.sc.width( string )          // ensure message doesn't
      IF ssiz > msiz                        // overflow the message area
      THEN string%0 := string%0 - 1         // added 13.10.86 PAC
   $) REPEATUNTIL ssiz <= msiz

   G.sc.ermess( string )
$)

AND dumpit( byte.pointer, data.size, nos.per.line ) = VALOF
$( LET req.vec = 0
   LET no.of.lines = ?
   LET buffer = ?
   LET success = FALSE
   LET vec.size = data.size / bytesperword
   LET data.pointer = byte.pointer / bytesperword
   LET convert.line = ?
   LET stepsize = ?
   LET numbers  = ?

   // decide which conversion we're going to use

   TEST nos.per.line = m.ut.16bit.nos.per.line
      THEN $( convert.line := do.16.line
              stepsize := nos.per.line
           $)
      ELSE $( convert.line := g.ud.do.32.line
              stepsize := (4/bytesperword)*nos.per.line
           $)

   // calculate number of numbers
   numbers := (vec.size * nos.per.line) / stepsize

   // calculate required vector size

   IF (numbers REM nos.per.line) >0
      THEN req.vec := 1
   no.of.lines := req.vec + numbers / nos.per.line
   req.vec     := no.of.lines * m.ut.words.per.line

   TEST req.vec >= MAXVEC() // do it line by line
      THEN $( LET tvec = VEC( m.ut.words.per.line ) // one line = 20 words
              buffer  := tvec
              FOR i = 1 TO no.of.lines DO
                 $( LET output.pointer = buffer
                    convert.line ( output.pointer, data.pointer, numbers )
                    numbers := numbers - nos.per.line
                    data.pointer := data.pointer + stepsize
                    success := writeit ( buffer * bytesperword, 
                                                          m.ut.chars.per.line )
                    IF success ~= m.ut.success  // early exit
                       THEN RESULTIS success
                 $)
           $)

      ELSE $( LET output.pointer = ?
              buffer   := GETVEC( req.vec )
              output.pointer := buffer
              FOR i = 1 TO no.of.lines DO
                 $(
                    convert.line ( output.pointer, data.pointer, numbers )
                    numbers := numbers - nos.per.line
                    output.pointer := output.pointer + m.ut.words.per.line
                    data.pointer := data.pointer + stepsize
                 $)
              success := writeit ( buffer * bytesperword, 
                                                    req.vec * bytesperword )
              FREEVEC( buffer )
           $)
      RESULTIS success
$)

AND do.16.line ( out.ptr, src.ptr, numbers ) BE
$( LET byteoff = 0  // byte offset into output vector
   LET limit   = m.ut.16bit.nos.per.line

   IF numbers < m.ut.16bit.nos.per.line THEN limit := numbers

   FOR i = 0 TO m.ut.chars.per.line DO out.ptr%i := ' '

   FOR j = 1 TO limit DO
   $( LET number = src.ptr!0
      LET negative = FALSE
      LET digits   = 0
      IF number < 0 THEN $( number := -number; negative := TRUE $)

      FOR j = 5 TO 1 BY -1 DO  // convert to string
      $( out.ptr%(byteoff+j) := (number REM 10) + '0'
         number := number / 10
         digits := digits + 1
         IF number = 0 THEN BREAK    // early exit
      $)

      IF negative THEN out.ptr%(byteoff+5-digits) := '-' // add minus sign

      byteoff := byteoff + m.ut.chars16
      src.ptr := src.ptr + 1
   $)
   out.ptr%(m.ut.chars.per.line-1) := m.ut.CR
$)

AND g.ud.do.32.line ( out.ptr, src.ptr, numbers ) BE
$( LET byteoff = 0 // byte offset into o/p vector
   LET limit   = m.ut.32bit.nos.per.line

   IF numbers < m.ut.32bit.nos.per.line THEN limit := numbers

   FOR i = 0 TO m.ut.chars.per.line DO out.ptr%i := ' '

   FOR i = 1 TO limit DO
   $( LET ten      = vec 1
      LET zero     = vec 1
      LET negative = FALSE      // flag negative number
      LET digits   = 0          // count of digits
      LET fraction = VEC 1
      LET number   = VEC 1      // copy of the number

      G.ut.set32(10, 0, ten) // 32 bit value of 10
      G.ut.set32(0, 0, zero) // 32 bit value of 10
      // check for negative number
      TEST (G.ut.unpack16(src.ptr, 2) & #x8000) ~= 0 // top bit set
      THEN $( negative := TRUE
              G.ut.set32(G.ut.unpack16(src.ptr, 0) NEQV #xFFFF, 
                          G.ut.unpack16(src.ptr, 2) NEQV #xFFFF, number)
              TEST G.ut.unpack16(number, 0) = #xFFFF
                 THEN G.ut.set32(G.ut.unpack16(number, 0),
                                     G.ut.unpack16(number, 2) + 1, number)
                 ELSE G.ut.set32(G.ut.unpack16(number, 0) + 1,
                                     G.ut.unpack16(number, 2), number)
           $)
      ELSE G.ut.mov32(src.ptr, number)  // transfer it as it stands

      FOR j = 11 TO 2 BY -1 // max 10 digits
      $( G.ut.div32( ten, number, fraction )
         out.ptr%(byteoff+j) := fraction!0 + '0'
         digits   := digits + 1
         IF G.ut.cmp32(zero, number) = m.eq THEN BREAK // early exit
      $)

      IF negative THEN out.ptr%(byteoff+11-digits) := '-' // tidy string - add minus sign

      byteoff := byteoff + m.ut.chars32
      src.ptr := src.ptr + (4/bytesperword)
   $)
   out.ptr%(m.ut.chars.per.line-1) := m.ut.CR

$)


AND writeit( byte.ptr, byte.size ) = VALOF
$( LET wcb = VEC 6   // write control block

   wcb!0 := G.ut.stream   // file handle
   wcb!1 := byte.ptr // 2nd processor main address  // 05.01.88 MH
   wcb!2 := byte.size     // size in bytes

   osgbpb(m.ut.write.op, wcb)
   resultis (wcb!1 - byte.ptr) = byte.size -> m.ut.success, ~m.ut.success
                 // above updated 05.01.88 MH
$)
.


