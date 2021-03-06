//  PUK SOURCE  6.87

/**
         NM.AUTO2 - AUTOMATIC CLASSING OPERATN FOR MAPPABLE DATA
         -------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmAUTO

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         21.03.86 1        D.R.Freed   Initial version
         ********************************
         1.7.87      2     DNH      CHANGES FOR UNI
         13.7.87     3     DNH      set32 for widen
         28.9.87     4     SRY      set local/nat on menu bar

         g.nm.to.nested
**/

section "nmauto2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sihd.h"
get "H/uthd.h"
get "H/nmhd.h"
get "H/nmclhd.h"


/**
         G.NM.TO.NESTED - TRANSITION TO NESTED MEANS
         -------------------------------------------

         Initialisation routine for transition to nested
         means classing from anywhere.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.redraw
         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.to.nested []
         --------------

         set method static to nested
         suppress Nested on menu bar
         IF scope = National THEN
            IF summary data is good THEN
               get class intervals
            ELSE
               issue error message
            ENDIF
         ELSE
            put "calculating" message in message area
            calculate nested means class intervals for AOI
            reposition videodisc for underlay map
            IF able to get new intervals THEN
               load up calculated intervals
            ELSE
               issue error message
            ENDIF
         ENDIF

         IF able to get new intervals THEN
            set intervals changed flag
            set up special colours for nested means
            shuffle numbers to fill key
            set redraw flag to get Replot on menu bar
         ELSE
            IF intervals have already been changed THEN
               set redraw flag to get Replot on menu bar
            ELSE
               leave Nested box blank
            ENDIF
         ENDIF

         display key
**/

let g.nm.to.nested () be
$( let menu = g.nm.s+m.nm.menu
   let   ok   =  ?
   let   upb  =  vec 3 * m.nm.max.data.size

   g.nm.s!m.nm.gen.purp := m.wnested

   for i = m.box1 to m.box6 menu!i := m.sd.act
   menu!m.box4 := m.wblank
   menu!m.box6 := (g.nm.s!m.nm.scope = m.wNational) -> m.wLocal, m.wNational
   g.sc.menu (menu)

   test g.nm.s!m.nm.scope = m.wnational then
      $(
         ok := g.nm.check.summary.data (
                     g.nm.s + m.nm.nested.means.classes, 3)

         if ok then
            $(
               g.nm.init.classes (m.nm.num.of.class.intervals,
                                  g.nm.class.upb)
               MOVE (g.nm.s + m.nm.nested.means.classes + m.nm.max.data.size,
                     g.nm.class.upb + m.nm.max.data.size,
                     3 * m.nm.max.data.size)
            $)
      $)
   else
      $(
         g.sc.mess ("Calculating new class intervals...")

         // find mean of non-missing values within area of interest (AOI) ;
         // then find mean of values below the mean (low.mean) and mean of
         // values above the mean (high.mean), giving three cut-points.
         // for areal data, simply look at values in the areal vector
         // which had a hit in the bit map (ie. were accessed) ;
         // for grid square data, need 2 passes through the data with
         // appropriate drivers for the variable processor

         g.ut.set48 (0, 0, 0, g.nm.s + m.nm.local.average)

         g.ut.mov48 (g.nm.s + m.nm.local.average, g.nm.s + m.low.mean)
         g.ut.mov48 (g.nm.s + m.nm.local.average, g.nm.s + m.high.mean)

         g.nm.s!m.n, g.nm.s!m.low.n, g.nm.s!m.high.n := 0, 0, 0

         test (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data) then

            $(areal
               for i = 1 to g.nm.s!m.nm.nat.num.areas do
                  if g.nm.map.hit (i) then
                        nm.sum (g.nm.areal + i * m.nm.max.data.size)

               ok := g.nm.mpdiv (g.nm.s + m.nm.local.average, g.nm.s!m.n,
                                 g.nm.s + m.nm.local.average)

               if ok then
                  for i = 1 to g.nm.s!m.nm.nat.num.areas do
                     if g.nm.map.hit (i) then
                        nm.nested.sums (g.nm.areal + i * m.nm.max.data.size)
            $)areal
         else
            $(gridsquare

            g.nm.init.processor (g.context!m.grbleast, g.context!m.grblnorth,
                                 g.context!m.grtreast, g.context!m.grtrnorth)

            g.nm.s!m.pass := 1
            g.nm.process.variable (nm.uniform, nm.fine)

            ok := g.nm.mpdiv (g.nm.s + m.nm.local.average, g.nm.s!m.n,
                            g.nm.s + m.nm.local.average)

            if ok then
               $(
                  g.nm.s!m.pass := 2
                  g.nm.process.variable (nm.uniform, nm.fine)
               $)

            g.nm.position.videodisc ()

            $)gridsquare

         ok := ok & g.nm.mpdiv (g.nm.s + m.low.mean,
                                                g.nm.s!m.low.n, upb)
         g.ut.mov32 (g.nm.s + m.nm.local.average, upb + m.nm.max.data.size)
         ok := ok & g.nm.mpdiv (g.nm.s + m.high.mean, g.nm.s!m.high.n,
                                                upb + 2 * m.nm.max.data.size)

         test ok then
            $(
               g.nm.init.classes (m.nm.num.of.class.intervals, g.nm.class.upb)
               MOVE (upb, g.nm.class.upb + m.nm.max.data.size,
                                                3 * m.nm.max.data.size)
            $)
         else
            g.nm.auto.ermess ("Can't calculate nested means")
      $)

   if ok
   $( g.nm.s!m.nm.intervals.changed := TRUE
      // set up special colours for nested means display
      g.nm.nested.colours ()
      g.nm.shuffle.key () // shuffle the upb's to fill the key
   $)

   // g.redraw := g.nm.s!m.nm.intervals.changed // get Replot on menu bar
   if g.nm.s!m.nm.intervals.changed
   $( menu!m.box4 := m.sd.act
      g.sc.menu(menu)
   $)

   g.nm.display.key (TRUE)
$)


/* Summing routines, for grid square data, to be used by g.nm.process.variable
   follow ; during pass 1 they find the sum of all non-missing values and the
   count of these to enable the overall mean (average) to be calculated.
   During the second pass they find the sum and count of all non-missing values
   above and below the overall mean, to enable the low mean and high mean to
   be calculated. The nested means class intervals are:
         low mean, overall mean, high mean
*/

/*
      nm.uniform

         During pass 1:
            adds the values of a non-missing uniform block into the overall
            sum of values and counts them ;

         During pass 2:
            adds the values of a non-missing uniform block into the sum of
            values below the mean or sum above the mean and counts them
*/

and nm.uniform (record.number, offset, east, north, block.size) be
$(
   let value = vec m.nm.max.data.size
   and num.e, num.n = ?, ?

   // ignore missing data
   if (record.number = m.nm.uniform.missing) then
         RETURN

   test g.nm.dual.data.type (g.nm.s!m.nm.raster.data.type) then
      g.ut.set32 (offset, 0, value)
   else
      g.ut.set32 ( - record.number, 0, value)

   // calculate the number of squares that actually lie within the
   // area of interest

   num.e := g.nm.min (east + block.size, g.nm.s!m.nm.grid.sq.top.e) -
                                g.nm.max (east, g.nm.s!m.nm.grid.sq.low.e)

   num.n := g.nm.min (north + block.size, g.nm.s!m.nm.grid.sq.top.n) -
                                 g.nm.max (north, g.nm.s!m.nm.grid.sq.low.n)

   // next loop inefficient - but multiplying value by square of size
   // would require 3-word multiply in case of overflow
   for i = 1 to g.nm.max (num.e, 0) * g.nm.max (num.n, 0) do
      test g.nm.s!m.pass = 1 then
         nm.sum (value)
      else
         nm.nested.sums (value)
$)


/*
      nm.fine

         During pass 1:
            adds all the non-missing values in the fine block which fall
            within the AOI into the overall sum and counts them ;

         During pass 2:
            adds all the non-missing values in the fine block which fall
            within the AOI into the sum of values below the mean or sum
            above the mean, and counts them
*/

and nm.fine (start.east, start.north) be
$(
   let wholly.within, curr.e, curr.n, index =  ?, ?, ?, ?

   // see if whole fine block is within area of interest - if it is
   // then processing of the block can be performed more quickly

   wholly.within :=
         (start.east >= g.nm.s!m.nm.grid.sq.low.e) &
         (start.east + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.e) &
         (start.north >= g.nm.s!m.nm.grid.sq.low.n) &
         (start.north + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.n)

   // process block

   for north = 1 to m.nm.fine.blocksize do

      for east = 1 to m.nm.fine.blocksize do

         $(square
         curr.e := start.east + east - 1
         curr.n := start.north + north - 1

         // see if this square is within area of interest;
         // NOTE that since BCPL evaluates conditional expressions from
         //      left to right and stops as soon as value is known, then
         //      blocks wholly within the area will only perform the first
         //      part of the test

         if wholly.within |
               ( (curr.e >= g.nm.s!m.nm.grid.sq.low.e) &
                 (curr.e < g.nm.s!m.nm.grid.sq.top.e) &
                 (curr.n >= g.nm.s!m.nm.grid.sq.low.n) &
                 (curr.n < g.nm.s!m.nm.grid.sq.top.n) )   then
            $(inside
               index := ((north-1) * m.nm.fine.blocksize + east) *
                                                         m.nm.max.data.size
               test g.nm.s!m.pass = 1 then
                  nm.sum (g.nm.values + index)
               else
                  nm.nested.sums (g.nm.values + index)
            $)inside
         $)square
$)


/*
      nm.sum

         adds given value into cumulative sum of non-missing values and
         counts the number of values
*/

and nm.sum (value.ptr) be
$(
   let max.neg32 = vec 1

   g.ut.set32 (0, m.nm.max.neg.high, max.neg32)

   // ignore missing values
   if g.ut.cmp32 (value.ptr, max.neg32) = m.eq then
      return

   g.nm.mpadd (value.ptr, g.nm.s + m.nm.local.average)
   g.nm.s!m.n := g.nm.s!m.n + 1
$)


/*
      nm.nested.sums

         adds given value into appropriate cumulative sum of non-missing
         values, depending on whether it lies below or above the mean ;
         also counts the number of values below and above the mean
*/

and nm.nested.sums (value.ptr) be
$(
   let max.neg32 = vec 1

   g.ut.set32 (0, m.nm.max.neg.high, max.neg32)

   // ignore missing values
   if g.ut.cmp32 (value.ptr, max.neg32) = m.eq then
      return

   test (g.ut.cmp32 (value.ptr, g.nm.s + m.nm.local.average) = m.gt) then
      $(
         g.nm.mpadd (value.ptr, g.nm.s + m.high.mean)
         g.nm.s!m.high.n := g.nm.s!m.high.n + 1
      $)
   else
      $(
         g.nm.mpadd (value.ptr, g.nm.s + m.low.mean)
         g.nm.s!m.low.n := g.nm.s!m.low.n + 1
      $)
$)

.
