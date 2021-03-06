//  PUK SOURCE  6.87


/**
         NM.FPWRITE - LIBRARY FLOATING POINT NUMBER WRITE
         ------------------------------------------------

         NAME OF FILES CONTAINING RUNNABLE CODE:

         cnmRETR
         cnmCORR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         21/08/86 1        D.R.Freed   Initial version
         14.7.87     2     DNH      Remove needs & fphdr get
          3.9.87     3     SRY      Put them back!
         20.01.88    4     MH       Mode 2 display character set not used
**/

section "nmfpwrite"

$<RCP
needs "FLAR1"
needs "FLAR2"
needs "FLCONV"
needs "FLIO2"
$>RCP

get "H/libhdr.h"
$<RCP
get "H/fphdr.h"
$>RCP
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nmhd.h"

static
$(
   s.oldWRCH   =  ?  // for redefinition of MOS WRCH routine
$)


/**
         G.NM.FPWRITE - WRITE FLOATING POINT NUMBER
         ------------------------------------------

         Displays a floating point number at the current
         graphics position using the specified floating point
         procedure and temporary redefinition of the MOS
         routine WRCH.

         INPUTS:

         Pointer to floating point write routine
            (WRITEFP or WRITESG)
         3 normal arguments for the write routine

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Machine specific because of the WRCH definition and
         VDU call.

         PROGRAM DESIGN LANGUAGE:

         g.nm.fpwrite [routine.ptr, arg1, arg2, arg3]
         ------------

         turn off mouse pointer
         save old address of WRCH
         redefine WRCH
         display fp number using routine.ptr via new WRCH
         restore old WRCH
         restore mouse pointer
**/


let g.nm.fpwrite (routine.ptr, arg1, arg2, arg3) be
$(
   // turn off mouse pointer since we are not using the screen driver
  // let entry.state = g.sc.pointer (m.sd.off)

  let a = 20 // keep in for compiler bug
  G.dummy()

   // temporarily redefine the MOS write character routine to handle the
   // special mode 2 character set
 //  s.oldWRCH := WRCH
 //  WRCH := newWRCH

   // call WRITESG or WRITEFP, indirectly using routine
   // pointer parameter, with its normal parameters
   routine.ptr (arg1, arg2, arg3)

   // restore MOS routine
 //  WRCH := s.oldWRCH

   // restore mouse pointer
 //  g.sc.pointer (entry.state)
$)


/*
      newWRCH

         temporary replacement for MOS WRCH routine to allow use of fp
         output in special mode 2 character set
*/

and newWRCH (ch) be
$(
   s.oldWRCH (ch | #x80)   // set top bit for redefined character set
   VDU ("25,0,-32;0;")     // move backwards 1/2 a char
$)
.
