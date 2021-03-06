//  PUK SOURCE  6.87

/**
         NM.RANK - LIBRARY ROUTINE TO RANK A SET OF VALUES
         -------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmCORR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         31.07.86 1        D.R.Freed   Initial version
         ********************************
         7.7.87      2     DNH      CHANGES FOR UNI

         g.nm.rank.data
**/

section "nmrank"

$<RCP
needs "FLCONV"
$>RCP

get "H/libhdr.h"
$<RCP
get "H/fphdr.h"
$>RCP
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/uthd.h"
get "H/nmhd.h"

/*
      g.nm.rank.data

         calculates a set of rankings in the frame buffer
         for the data in the areal vector.

         Each ranking value is one word, since we need less than
         16 bits max.

         outputs a running status in the message area of how far
         through (number of passes) the ranking it has reached

         the rankings are all shifted left by 1 bit so that ties
         can be correctly handled (they always give a value ending
         in .0 or .5)

         also calculates a tie correction factor which is returned
         in a FP vector
*/

let g.nm.rank.data (num.data.values, fp.tie.factor) be
$(
   let pass, num.ties, counter, index, rank, result, vec.i, entry.state =
                                                   ?, ?, ?, ?, ?, ?, ?, ?
   and max.value = vec 1

   // mark frame buffer dirty, since we are about to use it as workspace
   g.nm.init.frame.buffer ()

   // initialise rankings to zero; this indicates that a value has not
   // yet been ranked
   g.nm.frame!0 := 0
   MOVE (g.nm.frame, g.nm.frame + 1, num.data.values - 1)

   // initialise tie correction factor
   FFLOAT (0, fp.tie.factor)

   entry.state := g.sc.pointer (m.sd.off)
   pass := 1
   counter := 9

   // on each pass, find the largest unranked value, and the
   // number of times it occurs (ties) - then assign the rank(s)
   $(repeat
      g.ut.set32 (0, m.nm.max.neg.high, max.value)
      num.ties := 0
      vec.i := 0

      counter := counter + 1
      if counter >= 10 then
         $(
            counter := 0
            g.nm.running.status (pass, num.data.values)
         $)

      for i = 0 to num.data.values - 1 do

         $(
            if (g.nm.frame!i = 0) then
               $(
                  result := g.ut.cmp32 (g.nm.areal + vec.i, max.value)
                  test (result = m.gt) then
                     $(
                        g.ut.mov32 (g.nm.areal + vec.i, max.value)
                        index := i
                        num.ties := 1
                     $)
                  else if (result = m.eq) then
                        num.ties := num.ties + 1
               $)

            vec.i := vec.i + m.nm.max.data.size
         $)

      // now assign rank(s); if there is only one value we can assign it
      // directly using the index, but if there are several ties we must
      // calculate the average rank and pass through once again to assign
      // it to all occurrences; also the tie correction factor must be
      // adjusted. Note that the ranking is always shifted
      // once left to enable averages to be accurately stored

      // it can be proven that the average rank of n ties on pass p =
      //    p + (n - 1) / 2
      // since we shift the rank left (multiply by 2), we get
      //    2p + n - 1

      rank := (num.ties = 1) -> pass << 1,
                               (pass << 1) + num.ties - 1

      test (num.ties = 1) then
         g.nm.frame!index := rank

      else if (num.ties > 1) then
         $(
            vec.i := 0

            for i = 0 to num.data.values - 1 do
               $(
                  if (g.ut.cmp32 (g.nm.areal + vec.i, max.value) = m.eq) then
                     g.nm.frame!i := rank

                  vec.i := vec.i + m.nm.max.data.size
               $)

            // adjust tie correction factor
            g.nm.calc.tie.correction (num.ties, fp.tie.factor)
         $)

      pass := pass + num.ties

   $)repeat    repeatuntil (num.ties = 0) | (pass > num.data.values)

   g.sc.pointer (entry.state)
$)

.
