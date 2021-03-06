//  AES SOURCE  4.87

/**
         B.KERNEL1 - SPECIALLY WRITTEN BCPL CODE FOR KERNEL
         --------------------------------------------------

         This module only contains g.dummy.  It used to contain
         the BCPL Start() procedure, which has now moved to
         root, where it used to be called g.ov.cntrl.

         LOCATION OF RUNNABLE CODE:

         s.kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         23.4.87   1        PAC        ADOPTED FOR AES SYSTEM
                                       Added G.dummy, tidied up
                                       startup stuff
         *****************************************
         1.5.87      2     DNH      Removed start for UNI
**/

SECTION "b.Kernel1"

get "H/libhdr.h"
get "GH/glhd.h"


/**
         G.DUMMY - DUMMY PROCEDURE
         -------------------------

         This procedure does nothing.

         It is used for dummy init routines, etc. by the state
         machine. Included from OV.B.root1 on 23.4.87

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:

         G.dummy[]
         -------
         Return to caller
**/
LET G.Dummy() BE RETURN
.
