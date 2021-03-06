//  PUK SOURCE  6.87

/**
         NM.AUTO1 - AUTOMATIC CLASSING OPERATN FOR MAPPABLE DATA
         -------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmAUTO

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         21.03.86 1        D.R.Freed   Initial version
         ********************************
         1.7.87      3     DNH      CHANGES FOR UNI

         13.7.87     4     DNH      set32 for widen
         28.9.87     5     SRY      Set local/nat on menu bar

         g.nm.to.equal
**/

section "nmauto1"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/kdhd.h"
get "H/sihd.h"
get "H/nmhd.h"
get "H/nmclhd.h"


/**
         G.NM.TO.EQUAL - TRANSITION TO EQUAL INTERVALS
         ---------------------------------------------

         Initialisation routine for transition to equal
         classing from anywhere.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.redraw
         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.to.equal []
         -------------

         set method static to equal
         suppress Equal from menu bar
         IF scope = National THEN
            IF summary data is good THEN
               get class intervals
            ELSE
               issue error message
            ENDIF
         ELSE
            put "calculating" message in message area
            calculate equal class intervals for AOI
            reposition videodisc for underlay map
            IF able to get new intervals THEN
               load up calculated values
            ELSE
               issue error message
            ENDIF
         ENDIF

         IF able to get new intervals THEN
            set intervals changed flag
            shuffle key
            set redraw flag to get Replot on menu bar
         ELSE
            IF class intervals have already been changed THEN
               set redraw flag to get Replot on menu bar
            ELSE
               leave Equal box blank
            ENDIF
         ENDIF

         display key
**/

let g.nm.to.equal () be
$(
   let ok, diff.signs =  ?, ?
   let menu = g.nm.s+m.nm.menu
   and range   =  vec 1
   and product =  vec 1
   and i32     =  vec 1
   and upb     =  vec m.nm.max.data.size * m.nm.num.of.class.intervals

   g.nm.s!m.nm.gen.purp := m.wequal

   for i = m.box1 to m.box6 menu!i := m.sd.act
   menu!m.box3 := m.wblank
   menu!m.box6 := (g.nm.s!m.nm.scope = m.wNational) -> m.wLocal, m.wNational
   g.sc.menu(menu)

   test g.nm.s!m.nm.scope = m.wnational then
      $(
         ok := g.nm.check.summary.data (g.nm.s + m.nm.equal.classes,
                                        g.nm.s!m.nm.num.auto.cut.points)
         if ok then
            MOVE (g.nm.s + m.nm.equal.classes, g.nm.class.upb,
                  (m.nm.num.of.class.intervals + 1) * m.nm.max.data.size)
      $)
   else
      $(
         g.sc.mess ("Calculating new class intervals...")

         // find minimum and maximum values for area of interest (AOI) ;
         // for areal data, simply look at values in the areal vector
         // which had a hit in the bit map (ie. were accessed) ;
         // for grid square data, need a pass through the data with
         // appropriate drivers for the variable processor

         g.ut.set32 (m.nm.max.pos.low, m.nm.max.pos.high,
                                    g.nm.s + m.nm.local.min.data.value)
         g.ut.set32 (0, m.nm.max.neg.high,
                                    g.nm.s + m.nm.local.max.data.value)

         test (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data) then

            $(areal
               for i = 1 to g.nm.s!m.nm.nat.num.areas do
                  if g.nm.map.hit (i) then
                        nm.check (g.nm.areal + i * m.nm.max.data.size)
            $)areal
         else
            $(gridsquare

            g.nm.init.processor (g.context!m.grbleast, g.context!m.grblnorth,
                                 g.context!m.grtreast, g.context!m.grtrnorth)

            g.nm.process.variable (nm.uniform.limits, nm.fine.limits)
            g.nm.position.videodisc ()
            $)gridsquare

         // range = max - min ; check that overflow doesn't occur
         g.ut.set32 (0, 0, i32)
         diff.signs :=
            (g.ut.cmp32 (g.nm.s + m.nm.local.max.data.value, i32) =
                                                               m.lt) NEQV
             (g.ut.cmp32 (g.nm.s + m.nm.local.min.data.value, i32) = m.lt)

         g.ut.mov32 (g.nm.s + m.nm.local.max.data.value, range)
         g.ut.sub32 (g.nm.s + m.nm.local.min.data.value, range)

         ok := NOT (diff.signs &
               (g.ut.cmp32 (range, g.nm.s + m.nm.local.max.data.value) =
                                                                     m.lt) )
         ok := ok & (g.ut.cmp32 (g.nm.s + m.nm.local.max.data.value,
                                 g.nm.s + m.nm.local.min.data.value) ~=
                                                                     m.lt)

         // first ('na') and last ('>') boxes are already set up.  Just set
         // and copy the ones that need numberic values.  There are
         // '..num.of.class.intervals - 1' of them.

         for i = 1 to m.nm.num.of.class.intervals - 1 do
            $(
               // cut-point i = min + (i * range) / num.class.intervals
               g.ut.mov32 (range, product)
               g.ut.set32 (i, 0, i32)
               ok := ok & g.ut.mul32 (i32, product)
               g.ut.set32 (m.nm.num.of.class.intervals, 0, i32)
               ok := ok & nm.div32 (product, i32, upb + i * m.nm.max.data.size)
               g.ut.add32 (g.nm.s + m.nm.local.min.data.value,
                                                  upb + i * m.nm.max.data.size)
            $)

         test ok then
            MOVE (upb + m.nm.max.data.size,
                     g.nm.class.upb + m.nm.max.data.size,
                        (m.nm.num.of.class.intervals - 1) * m.nm.max.data.size)
         else
            g.nm.auto.ermess ("Can't calculate equal intervals")
      $)

   if ok
   $( g.nm.s!m.nm.intervals.changed := TRUE
      g.nm.shuffle.key ()
   $)

   // g.redraw := g.nm.s!m.nm.intervals.changed // get Replot on menu bar
   if g.nm.s!m.nm.intervals.changed
   $( menu!m.box3 := m.sd.act
      g.sc.menu(menu)
   $)

   g.nm.display.key (TRUE)
$)


/* Min./Max. detection routines, for grid square data, to be used by
   g.nm.process.variable follow
*/

/*
      nm.uniform.limits

         checks the value of a uniform block for min./max.
*/

and nm.uniform.limits (record.number, offset, east, north, block.size) be
$(
   let value = vec m.nm.max.data.size

   // ignore missing data
   if (record.number = m.nm.uniform.missing) then
         return

   test g.nm.dual.data.type (g.nm.s!m.nm.raster.data.type) then
      g.ut.set32 (offset, 0, value)
   else
      g.ut.set32 ( - record.number, 0, value)

   nm.check (value)
$)


/*
      nm.fine.limits

         checks all the values in the fine block which fall
         within the AOI for min./max.
*/

and nm.fine.limits (start.east, start.north) be
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
               nm.check (g.nm.values + index)
            $)inside
         $)square
$)


/*
      nm.check

         checks given value against local min & max data values - updates
         them accordingly

         missing values are ignored
*/

and nm.check (value.ptr) be
$(
   let max.neg32 = vec 1
   g.ut.set32 (0, m.nm.max.neg.high, max.neg32)

   if ( g.ut.cmp32 (value.ptr, max.neg32) = m.eq ) then
      return

   test (g.ut.cmp32 (value.ptr, g.nm.s + m.nm.local.min.data.value) =
                                                                  m.lt) then
      g.ut.mov32 (value.ptr, g.nm.s + m.nm.local.min.data.value)

   else if (g.ut.cmp32 (value.ptr, g.nm.s + m.nm.local.max.data.value) =
                                                                  m.gt) then
      g.ut.mov32 (value.ptr, g.nm.s + m.nm.local.max.data.value)
$)


/*
      nm.div32

         32 bit division:  quot = ROUND (a / b)
         returns FALSE if an error occurred, TRUE otherwise
*/

and nm.div32 (a.ptr, b.ptr, quot.ptr) = valof
$(
   let ok, neg =  ?, ?
   and zero  = vec 1
   and two   = vec 1
   and dividend = vec 1
   and round = vec 1
   and remdr   = vec 1

   // deal with positive numbers throughout, use unsigned ut routines and
   // recover sign at the end

   ok := TRUE

   g.ut.set32 (0, 0, zero)
   neg := (g.ut.cmp32 (a.ptr, zero) = m.lt)

   if neg then
      ok := ok & nm.neg32 (a.ptr)

   if (g.ut.cmp32 (b.ptr, zero) = m.lt) then
      $(
         neg := NOT neg                // (this is not the same as FALSE)
         ok := ok & nm.neg32 (b.ptr)
      $)

   // add divisor / 2 to dividend to give proper rounding
   g.ut.mov32 (b.ptr, round)
   ok := ok & g.ut.div32 ( g.ut.set32 (2, 0, two), round, remdr)
   g.ut.mov32 (a.ptr, dividend)
   g.ut.add32 (round, dividend)

   // if addition of two +ve numbers gives -ve result then it has overflowed
   ok := ok & (NOT g.ut.cmp32 (dividend, zero) = m.lt)

   g.ut.mov32 (dividend, quot.ptr)
   ok := ok & g.ut.div32 (b.ptr, quot.ptr, remdr)

   if neg then
      ok := ok & nm.neg32 (quot.ptr)

   resultis ok
$)


/*
      nm.neg32

         32 bit negation
         returns TRUE if ok,
                 FALSE if number = max. neg. value (since max. pos.
                     value = ABS (max. neg.) - 1)
*/

and nm.neg32 (vec.ptr) = valof
$(
   let low16, high16 = ?, ?
   let one32     =  vec 1
   let max.neg32 =  vec 1

   g.ut.set32 (1, 0, one32)
   g.ut.set32 (0, m.nm.max.neg.high, max.neg32)

   if ( g.ut.cmp32 (vec.ptr, max.neg32) = m.eq ) then
      resultis FALSE

   // negate signed 32-bit number by two's complement

   low16 := g.ut.get32 (vec.ptr, @high16) NEQV #Xffff
   high16 := high16 NEQV #Xffff
   g.ut.set32 (low16, high16, vec.ptr)
   g.ut.add32 (one32, vec.ptr)
   resultis TRUE
$)
.

