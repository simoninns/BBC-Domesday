//  AES SOURCE  6.87

/**
         UT.HELPLNK - MACHINE SPECIFIC HELP ROUTINES
         -------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel (in the AES system)

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.8.86   1        PAC         Initial version
         18.6.87  2        PAC         ADOPTED FOR UNI
                                       Moved to UT
**/

Section "help.links"

get "H/libhdr.h"

get "GH/glhd.h"
get "H/sdhd.h"
get "H/kdhd.h"

///////////////////////////////////////////////////////////////
//        the two routines below are machine specific        //
///////////////////////////////////////////////////////////////

/**
         G.UT.SET.TEXT.WINDOW - SETUP TEXT WINDOW
         -----------------------------------------

         Sets up restriced area of display for text output.
         ( roughly the same as the display area )
         Also 'homes' the TEXT cursor to top LH of display.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Only used in helpC - the help SYSTEM function.

         PROGRAM DESIGN LANGUAGE:

         Set text window using VDU 28
         Window coords are:
            Bottom left : 0,28
            Top right   : 39,3
         These are character cell positions, and the BBC screen
         has dimensions 39x31 cells, (0,0 being TOP left)
         Home cursor to top left of the new window.
**/
LET G.ut.set.text.window() BE VDU("28,0,28,39,3,4,30,5")

/**
         G.UT.SEND.TO.OS - SEND COMMAND TO OPERATING SYSTEM
         --------------------------------------------------

         Sends command string to the operating system, and
         displays error message if necessary.

         INPUTS:

         BCPL string

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Note that the BBC has separate colours for text and
         graphics : hence the need to use VDU 17 to set up the
         colours properly.

         The text window is used to display the operating
         system's reply to the command (e.g. a directory listing)
         and also to show any error message if a fault condition
         was detected during the command. This is why VDU 4 is
         executed on entry to the routine, and VDU 5 on exit.

         PROGRAM DESIGN LANGUAGE:

         set text colour to cyan and unlink cursors
         text now all appears in the text window

         terminate string properly

         send it to the operating system CLI

         IF a fault condition is detected
         THEN
            find the error message
            set text colour to yellow
            indicate fault by beeping
            print error string

         relink the cursors

**/
AND G.ut.send.to.OS( string ) BE
$(
                                        
  LET fault = FALSE

   VDU("4,17,%",m.sd.cyan)  // set text colour to cyan and unlink cursors
                            // text now all appears in the text window

   string%(string%0+1) := m.kd.return      // terminate string properly

   fault := G.vh.call.oscli( string ) ~= 0 // send it to the OS CLI

   IF fault
   THEN
      $( LET error.str = VEC 25
         LET maxlength = 50

         G.ut.get.ermess( error.str, maxlength )  // find the error message

         VDU("17,%",m.sd.yellow)           // set text colour to yellow

         G.sc.beep()                       // indicate fault by beeping

         WRITEF("*n%s*n",error.str )       // print error string
      $)

   VDU("5")  // relink the cursors (i.e. back to normal operation)

$)
.


