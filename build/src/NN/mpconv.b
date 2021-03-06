//  PUK SOURCE  6.87

/**
         NM.MPCONV - LIBRARY NUMBER CONVERSION ROUTINE
         ---------------------------------------------

         NAME OF FILES CONTAINING RUNNABLE CODE:

         cnmAUTO
         cnmRETR
         cnmCORR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         21/08/86 1        D.R.Freed   Initial version
         ********************************
         3.7.87      2     DNH      CHANGES FOR UNI

         g.nm.int48.to.fp
**/

section "nmmpconv"

$<RCP
needs "FLAR1"
needs "FLAR2"
needs "FLCONV"
$>RCP


get "H/libhdr.h"
$<RCP
get "H/fphdr.h"
$>RCP
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/nmhd.h"

/**
      g.nm.int48.to.fp

         converts a 48 bit integer to floating point format
**/

let g.nm.int48.to.fp (int.ptr, fp.ptr) be
$(
   let   fp.num = vec FP.LEN
   and   fp.2.to.8 = vec FP.LEN
   and   fp.2.to.16 = vec FP.LEN
   and   fp.2.to.32 = vec FP.LEN
   and   fp.temp = vec FP.LEN
   and   neg   =  ?           // boolean
   and   bot16, mid16, top16 = ?, ?, ?

   bot16 := g.ut.get48 (int.ptr, @mid16, @top16)
   neg := (top16 & #x8000) ~= 0

   if neg then
      $(
         let temp32  = vec 1
         let one32   = vec 1

         g.ut.set32 (1, 0, one32)

         // negate by two's complement
         bot16 := bot16 NEQV #xffff
         mid16 := mid16 NEQV #xffff
         top16 := top16 NEQV #xffff
         g.ut.set32 (bot16, mid16, temp32)

         if g.ut.add32 (one32, temp32) then
            top16 := top16 + 1               // preserve the carry
      $)

   // generate powers of 2
   FFLOAT (256, fp.2.to.8)
   FMULT (fp.2.to.8, fp.2.to.8, fp.2.to.16)
   FMULT (fp.2.to.16, fp.2.to.16, fp.2.to.32)

   // convert ls 32 bits a byte at a time to handle 16-bit unsigned quantity
   convert (bot16, fp.ptr)
   FPLUS (FMULT (convert (mid16, fp.temp), fp.2.to.16, fp.num),
          fp.ptr, fp.ptr)
   FPLUS (FMULT (fp.2.to.32, FFLOAT (top16, fp.temp), fp.num),
          fp.ptr, fp.ptr)

   if neg then
      FNEG (fp.ptr, fp.ptr)
$)


/*
      convert

         converts a 16-bit unsigned value into a floating point number;
         returns the address of the result parameter as do the FP routines
*/

and convert (v16, fp.ptr) = valof
$(
   let fp.temp =  vec FP.LEN

   FFLOAT ( (v16 >> 8) & #Xff, fp.ptr)  // high byte
   FMULT (fp.ptr, FFLOAT (256, fp.temp), fp.ptr)
   FPLUS (fp.ptr, FFLOAT (v16 & #Xff, fp.temp), fp.ptr)  // add in low byte
   resultis fp.ptr
$)

.
