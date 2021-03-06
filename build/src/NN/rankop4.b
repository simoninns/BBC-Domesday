//  PUK SOURCE  6.87

/**
         NM.SORTRANK - SORT A SET OF VALUES WITH INDEX
         BASED ON NM.SORTRANK
         ---------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmRANK

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
       5.08.87    1        SRY      Initial version
       1.09.87    2        SRY      Sort bug
       2.09.87    3        SRY      Descending order
**/

section "nmrankop4"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/uthd.h"
get "H/nmhd.h"

/*
      g.nm.sort.rankop
*/

let g.nm.sort.rankop (num.data.values) be
$( // Mark frame buffer dirty, since we are about to use it as workspace
   g.nm.init.frame.buffer ()

   // The method used is to sort the areal vector, sorting an array of
   // the original positions in the vector simultaneously.
   // The frame buffer is used to record the original
   // positions of the data values.

   for i = 0 to num.data.values-1 G.nm.frame!i := i
   sort(g.nm.areal, G.nm.frame, num.data.values)
$)


/*
      sort

         Sorts an array of 32-bit values based on 'first' into
         DESCENDING order using Treesort 3;
         A corresponding array of 16-bit positions
         pointed to by 'pos.base' is rearranged in parallel with the
         values.  This latter must have been set up before Sort is
         called.

         NB: this routine is closely based on NN.B.TREESORT (S.Young);
             any modifications should be checked in both files
             and NN.B.SORTRANK
*/

and sort (first, pos.base, number) BE
$(
   let child   = ?
   let current = ?
   let next    = ?
   let topofarray = first + ((number-1) * m.nm.max.data.size)
   let second = first + m.nm.max.data.size
   let f1 = first - m.nm.max.data.size
   let halfway = f1 + (number/2)*m.nm.max.data.size
   let saved.pos = ?
   let index = ?

   let savedroot = vec 1
   let t = vec 1

// Two big FOR loops follow with the same algorithm (siftup) in the
// inner WHILE loop of both, to save procedure calls.

   FOR s = halfway TO second BY -m.nm.max.data.size DO
   $(
      current := s
      g.ut.mov32 (current, savedroot)

      child := f1 + 2 * (current - f1)
      next := child + m.nm.max.data.size
      index := (current - first)/m.nm.max.data.size
      saved.pos := pos.base!index

      $(
         UNLESS child = topofarray
            UNLESS g.ut.cmp32 (child, next) = m.lt // was gt
               child := next

         UNLESS g.ut.cmp32 (child, savedroot) = m.lt break // was gt

         g.ut.mov32 (child, current)
         pos.base!index := pos.base!((child - first)/m.nm.max.data.size)
         current := child

         index := (current - first)/m.nm.max.data.size
         child := f1 + 2 * (current - f1)
         next := child + m.nm.max.data.size

      $) REPEATUNTIL child > topofarray

      g.ut.mov32(savedroot, current)

      pos.base!index := saved.pos
   $)

   FOR temptop = topofarray TO second BY -m.nm.max.data.size DO
   $(
      current := first
      g.ut.mov32 (current, savedroot)
      child := second
      next := child + m.nm.max.data.size
      index := (current - first)/m.nm.max.data.size
      saved.pos := pos.base!index

      $( UNLESS child = temptop
            UNLESS g.ut.cmp32 (child, next) = m.lt // was gt
               child := next

         UNLESS g.ut.cmp32 (child, savedroot) = m.lt break // was gt

         g.ut.mov32 (child, current)
         pos.base!index := pos.base!((child - first)/m.nm.max.data.size)
         current := child

         index := (current - first)/m.nm.max.data.size
         child := f1 + 2 * (current - f1)
         next := child + m.nm.max.data.size

      $) REPEATUNTIL child > temptop

      g.ut.mov32 (savedroot, current)
      pos.base!index := saved.pos

      // Swap elements 1 & temptop

      g.ut.mov32 (first, t)
      g.ut.mov32 (temptop, first)
      g.ut.mov32 (t, temptop)

      !t := !pos.base
      index := (temptop - first)/m.nm.max.data.size
      !pos.base := pos.base!index
      pos.base!index := !t
   $)
$)
.



