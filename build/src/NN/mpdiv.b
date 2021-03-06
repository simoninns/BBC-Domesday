//  PUK SOURCE  6.87

/**
         NM.MPDIV - LIBRARY MULTIPLE PRECISION DIVISION
         ----------------------------------------------

         NAME OF FILES CONTAINING RUNNABLE CODE:

         cnmAUTO

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         22/04/86 1        D.R.Freed   Initial version
         ********************************
         3.7.87      2     DNH      CHANGES FOR UNI

         g.nm.mpdiv
**/

section "nmmpdiv"

$<RCP
needs "FLAR1"
needs "FLAR2"
needs "FLIO1"
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
      g.nm.mpdiv

         multiple precision division

         a.ptr / b = c.ptr

         where a.ptr points to a 48 bit dividend,
               b is 16 bit divisor,
               c.ptr is the address of a 32 bit result vector
**/

let g.nm.mpdiv (a.ptr, b, c.ptr) = valof
$(
   let   fp.num = vec FP.LEN
   and   fp.result = vec FP.LEN
   and   fp.div = vec FP.LEN
   and   fp.2.to.8 = vec FP.LEN
   and   fp.2.to.16 = vec FP.LEN
   and   fp.temp = vec FP.LEN
   and   low16, high16 = ?, ?
   and   neg   =  ?

   FPEXCEP := 0

   // convert 32 bit integer to floating point number
   g.nm.int48.to.fp (a.ptr, fp.num)

   // convert 16 bit divisor to fp
   FFLOAT (b, fp.div)

   // do the division
   FDIV (fp.num, fp.div, fp.result)

   // convert fp result into 32 bit integer
   neg := FSGN (fp.result) < 0
   if neg then
      FABS (fp.result, fp.result)

   // multiply by a correction factor to ensure correct rounding for numbers
   // of all magnitudes - this compensates for the loss of accuracy after
   // floating point division ; the correction factor is derived as follows:-
   //    let i = original number
   //        n = normalising factor
   //    result = i/n + (i/n * 1e-10)
   //           = i/n * (1 + 1e-10)

   FLIT ("10000000001e-10", fp.temp)
   FMULT (fp.result, fp.temp, fp.result)

   // generate powers of 2
   FFLOAT (256, fp.2.to.8)
   FMULT (fp.2.to.8, fp.2.to.8, fp.2.to.16)

   //    get ms 16 bits
   FDIV (fp.result, fp.2.to.16, fp.div)
   high16 := FINT (fp.div)

   //    get ls 16 bits
   FMULT (FFLOAT (high16, fp.temp), fp.2.to.16, fp.num)
   FMINUS (fp.result, fp.num, fp.result)

   // convert ls 16 bits byte by byte to handle unsigned numbers

   //    get ms byte of ls 16 bits
   FDIV (fp.result, fp.2.to.8, fp.div)
   low16 := FINT (fp.div) << 8

   //    get ls byte of ls 16 bits
   FMULT (FFLOAT (low16 >> 8, fp.temp), fp.2.to.8, fp.num)
   FMINUS (fp.result, fp.num, fp.result)
   low16 := low16 | FFIX (fp.result)

   test neg then
      $(
         let one32 = vec 1
         g.ut.set32 (1, 0, one32)

         // negate signed 32-bit number by two's complement
         low16  := low16  NEQV #Xffff
         high16 := high16 NEQV #Xffff
         g.ut.set32 (low16, high16, c.ptr)
         g.ut.add32 (one32, c.ptr)
      $)
   else
      g.ut.set32 (low16, high16, c.ptr)

   resultis (FPEXCEP = 0)
$)

.
