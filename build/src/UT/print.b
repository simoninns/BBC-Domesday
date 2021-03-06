//  AES SOURCE  4.87

/**
         PRINT UTILITY
         -------------

         This module contains :

            G.ut.print

         NAME OF FILE CONTAINING RUNNABLE CODE:

         linked to overlays that need it.
         file l.printwrite

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         17/02/86 1        PAC         Initial version
         08/05/86 2        PAC         Allow 55 char lines
         28/07/86 3        PAC         Use FX3, not FINDOUTPUT
         14.10.86 4        PAC         Less flushes.
         17.10.86 5        PAC         Pointer off during print
         12.5.87  6        PAC         Adopted for AES
         31.7.87  7        PAC         Fix timeout bug
**/

Section "ut.print"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/uthd.h"
get "H/sdhd.h"
/**
         G.UT.PRINT - PRINT A STRING
         ---------------------------

         This routine outputs a string to the currently selected
         printer stream, checking for printer hanging.

         INPUTS:

         Pointer to string to be output
         (Maximum 55 chars)

         OUTPUTS:

         Returns TRUE if the string was printed successfully,
         FALSE otherwise.
         Gives error message "Printer not ready" if it fails.

         GLOBALS MODIFIED:

         None

         SPECIAL NOTES FOR CALLERS:

         The string is truncated to 55 characters when output

         PROGRAM DESIGN LANGUAGE:

         G.ut.print [ stringptr,-> result ]
         ----------

         set up delay time
         find out current printer type
         IF printer is not 'printer sink'
            THEN flush printer buffer
                 save old output stream
                 select "/L" as current output stream
                 output string to printer, truncating to 55 chars
                 output "C/R" to printer

                 WHILE printer buffer is not empty AND delay > 0
                   DO IF buffer space is not increasing
                        THEN decrease time limit
                      ENDIF
                 ENDWHILE

                 flush printer buffer
                 reselect old output stream
            ENDIF
         IF delay > 0
            THEN result is TRUE  { success }
            ELSE give error message "Printer not ready"
                 result is FALSE { failure }
**/

LET G.ut.print( stringptr ) = VALOF
$(
   LET new.output   = ?
   LET old.output   = ?
   LET old.length   = ?
   LET buffer.space = ?
   LET old.buffer.space = m.ut.emptybuff
   LET status = G.sc.pointer( m.sd.off )  // PAC 17.10.86

   IF (OSByte(#xF5,0,#xFF) & #xFF) ~= 0 // printer type not 'sink'
   THEN
   $(
      old.output := OSByte(3,10) & #xFF // enable printer, disable VDU
      old.length := stringptr%0        // check string length

      IF old.length > m.ut.maxchars
      THEN stringptr%0 := m.ut.maxchars

      WRITEF("%s*n",stringptr)    // output the string
      stringptr%0 := old.length   // restore old length

      set.timer.to.zero()  

      // loop until either timeout or empty buffer
      $(
         buffer.space := ( OSByte(#x80,#xFC,#xFF) & #xFF ) // find free space

         IF buffer.space > old.buffer.space
         THEN set.timer.to.zero()

         old.buffer.space := buffer.space

      $) REPEATUNTIL (buffer.space >= m.ut.emptybuff) | (time() > m.ut.maxtime)

      OSByte(3,old.output)          // tidy up the output stream
   $)
   G.sc.pointer( status )          // PAC 17.10.86
   IF buffer.space >= m.ut.emptybuff THEN RESULTIS TRUE  // success
   G.sc.ermess ("Printer not ready")
   OSByte(21,3)                           // flush printer buffer
   RESULTIS FALSE                        // failure
$)

AND set.timer.to.zero() BE 
$( LET v = VEC 2
   v!0 := 0 ; OSWord(4,v) // zero interval timer
$)

.
