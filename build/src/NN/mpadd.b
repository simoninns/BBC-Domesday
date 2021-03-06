//  PUK SOURCE  6.87

/**
         NM.MPADD - LIBRARY MULTIPLE PRECISION ADDITION
         ----------------------------------------------

         NAME OF FILES CONTAINING RUNNABLE CODE:

         cnmAUTO
         cnmRETR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         22/04/86 1        D.R.Freed   Initial version
         ********************************
         3.7.87      2     DNH      CHANGES FOR UNI
         20.7.87     3     DNH      fix with get32 of temp32


         g.nm.mpadd
**/

section "nmmpadd"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/uthd.h"
get "H/nmhd.h"


/**
      g.nm.mpadd

         multiple precision addition

         adds the 32 bit value at a.ptr into the 48 bit
         value at sum.ptr
**/

let g.nm.mpadd (a.ptr, sum.ptr) be
$(
   let bot16, mid16, top16 = ?, ?, ?
   let temp32  =  vec 1
   let zero32  =  vec 1

   g.ut.set32 (0, 0, zero32)

   bot16 := g.ut.get48 (sum.ptr, @mid16, @top16)
   g.ut.set32 (bot16, mid16, temp32)

   if g.ut.add32 (a.ptr, temp32) then    // if sum gives carry
      top16 := top16 + 1                 //      propagate it

   // add in the sign extension if a.ptr was negative
   if ( g.ut.cmp32 (a.ptr, zero32) = m.lt ) then
      top16 := top16 + #Xffff

  
   bot16 := g.ut.get32 (temp32, @mid16)  // get results of sum
   g.ut.set48 (bot16, mid16, top16, sum.ptr)
$)

.
