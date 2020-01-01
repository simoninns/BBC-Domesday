//  PUK SOURCE  6.87
// $MSC

/**
         NM.CLASSIFY - CLASSIFY FOR MAPPABLE DATA DISPLAY
         ------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmDISP

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         8.7.87      1     DNH      CREATED FOR 32 BIT UNI

         g.nm.square.colour
**/

section "nmclass32"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nmhd.h"


/**
         G.NM.SQUARE.COLOUR
         -----------------

         SEE G.NM.CLASS.COLOUR IN FILE 'A.CLASSIFY'
         FOR UNI 16 BIT

         Note that this version is 32 bit only, not UNI BCPL.  It
         accesses 32 bit values via the '!' operator, not using
         get, set, cmp 32.

**/

let g.nm.square.colour (value.ptr) = valof
$(
   let class = 0

   while !value.ptr > g.nm.class.upb!class do
   $(
      class := class + 1
      if class > m.nm.num.of.class.intervals do    // error: return 'black'
         RESULTIS m.sd.black2
   $)

   resultis g.nm.class.colour!class
$)

.