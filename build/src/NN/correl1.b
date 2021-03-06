//  PUK SOURCE  6.87

/**
         NM.CORREL1 - CORRELATE OPERATION FOR MAPPABLE DATA
         --------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmCORR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         16.06.86 1        D.R.Freed   Initial version
         *****************************
         21.7.87     2     DNH      CHANGES FOR UNI
         12.08.87 3        SRY      Modified for DataMerge

         g.nm.correlate.handler
**/

section "nmcorrel1"

get "H/libhdr.h"
$<RCP
get "H/fphdr.h"
$>RCP
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/iohd.h"
get "H/nmhd.h"

get "H/nmcphd.h"

/**
         G.NM.CORRELATE.HANDLER - THE CORRELATE SUB-OPERATION
         ----------------------------------------------------

         The guts of the correlate sub-operation.

         If it is possible, Spearman's rank correlation is
         calculated; see paper by Mike Tibbetts (July 1986)
         and "Statistical Package for the Social Sciences"
         (Nie, Hull, Jenkins, Steinbrenner, Bert)
         for full description of theory.

         Note that if one value in a pair of data points is
         "missing", then the pair is discarded before any
         ranking is performed.

         Also, for grid-mappable data, if both values are zero
         then the pair are discarded prior to ranking; this is
         because many of the datasets have zeros in the sea,
         where they should really be "missing".

         INPUTS:

         Item NAMES file record for correlate dataset

         OUTPUTS:

         Returns TRUE if the operation was successful,
                 FALSE otherwise

         GLOBALS MODIFIED:

         g.context
         g.nm.areal.map
         g.nm.areal
         g.nm.frame
         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         This routine is called indirectly by having its address
         assigned to g.nm.compare.sub.op in the .ini transition
         routine.

         PROGRAM DESIGN LANGUAGE:

         g.nm.correlate.handler [item.record] RETURNS success
         ----------------------

         IF datasets are not the same mappable type THEN
            output error message
            RETURN FALSE
         ENDIF

         save current context before manipulating new dataset
         IF areal-mappable data THEN
            cache areal map
         ENDIF
         set up missing and zero values maps for current dataset
         copy item record to g.context
         IF load new dataset is successful THEN
            IF data type = incidence OR categorised THEN
               output error message
               result is FALSE
            ELSE
               correlate the new dataset with the current dataset
               display results
               result is TRUE
            ENDIF
         ELSE
            output error message
            result is FALSE
         ENDIF
         restore context
         IF areal-mappable data THEN
            IF result THEN
               reload areal vector
            ENDIF
            restore areal map
         ENDIF
         RETURN result
**/

let g.nm.correlate.handler (item.record) = valof
$(
   let success = ?
   let current.type = g.context%m.itemtypeoff

   if current.type ~= item.record%m.type
   $( test current.type = m.nm.grid.mappable.data
      then g.sc.ermess ("Not a grid-mappable dataset")
      else g.sc.ermess ("Not an areal-mappable dataset")
      resultis FALSE
   $)

   g.nm.save.context ()
   if current.type = m.nm.areal.mappable.data then
      g.ut.cache (g.nm.areal.map, m.nm.areal.map.size, m.io.wa.nm.areal.map)

   // set up bit maps to reflect where current dataset has missing values
   // and, for grid-mappable data, zero values
   test current.type = m.nm.areal.mappable.data
   then set.up.areal.map ()
   else set.up.grid.maps (1)

   // now load up named dataset
   g.ut.movebytes(item.record,0,g.context+m.itemrecord,0,m.itemrecord.length)
   test g.nm.load.dataset()
   then test g.nm.s!m.nm.value.data.type = m.nm.incidence.type |
             g.nm.s!m.nm.value.data.type = m.nm.categorised.type
        then $( g.sc.ermess ("Can't use incidence or categorised data")
                success := FALSE
             $)
        else $( correlate (current.type)
                success := TRUE
             $)
   else $( g.sc.ermess ("Not available at same detail")
           success := FALSE
        $)

   g.nm.restore.context ()

   if current.type = m.nm.areal.mappable.data then
   $( // areal vector will contain rankings; need to reload from disc
      if success g.nm.load.areal.data ()

      // restore original map which simply indicates which areas are
      // accessed within the current area of interest
      g.ut.restore (g.nm.areal.map, m.nm.areal.map.size, m.io.wa.nm.areal.map)
   $)

   resultis success
$)


/*
      correlate

         correlates the current variable (named one) with the
         old current variable (the one in cache)
*/

and correlate (dataset.type) = valof
$(
   let num.values = ?
   and removing.message = "Removing missing values..."
   and fp.tie.correction.a = vec FP.LEN
   and fp.tie.correction.b = vec FP.LEN

   g.sc.mess ("Loading first dataset...")
   test dataset.type = m.nm.areal.mappable.data
   then set.up.areal.map ()
   else unless set.up.grid.maps (2) resultis false

   g.sc.mess (removing.message)
   g.ut.wait (100)
   num.values := remove.missing.values (dataset.type)

   // ensure that, after removing missing data values and pairs of zeros
   // in grid-mappable data, that there are still enough pairs to derive
   // a sensible result
   if num.values < m.min.num.correl.points
   $( g.sc.mess ("Too much missing data to correlate")
      resultis true
   $)

   g.sc.mess ("Ranking first dataset...")

   // choose fast sort & rank method where the number of values is
   // small enough to allow it; otherwise use the slower method
   // (which can handle up to twice as many values)
   test num.values > m.max.num.fast.correl.points
   then g.nm.rank.data (num.values, fp.tie.correction.a)
   else g.nm.sort.rank (num.values, fp.tie.correction.a)

   // save rankings in areal vector cache area
   g.ut.cache (g.nm.frame, num.values - 1, m.io.wa.nm.areal)

   g.sc.mess ("Loading second dataset...")

   // restore context for original variable
   unless g.nm.restore.context () resultis false

   // areal vector will contain rankings; need to reload from disc
   test dataset.type = m.nm.areal.mappable.data
   then unless g.nm.load.areal.data () resultis false
   else unless unpack.data () resultis false

   g.sc.mess (removing.message)
   g.ut.wait (100)
   num.values := remove.missing.values (dataset.type)

   // rank new values
   g.sc.mess ("Ranking second dataset...")

   test num.values > m.max.num.fast.correl.points
   then g.nm.rank.data (num.values, fp.tie.correction.b)
   else g.nm.sort.rank (num.values, fp.tie.correction.b)

   // get first set of rankings back from cache for correlating
   g.ut.restore (g.nm.areal, num.values - 1, m.io.wa.nm.areal)

   g.sc.mess ("Correlating...")
   // calculate correlation coefficient and display results
   g.nm.calc.correlation (num.values, g.nm.areal, fp.tie.correction.a,
                                      g.nm.frame, fp.tie.correction.b)
   resultis true
$)


/*
      set.up.areal.map

         modifies the areal map so that areas which are accessed in the
         current area of interest but whose value is missing, are removed
         from the map
*/

and set.up.areal.map () be
$(
   let word  = 0   // first word of bitmap
   and bit   = 1   // first bit; 1 because !0 is not used in areal vector
   and index = ?   // pointer into areal vector
   and missing32 = vec 1

   g.ut.set32 (0, m.nm.max.neg.high, missing32)

   for i = 1 to g.nm.s!m.nm.nat.num.areas
   $( index := i * m.nm.max.data.size
      if (g.nm.areal.map!word & (1 << bit)) ~= 0 &
         g.ut.cmp32 (g.nm.areal+index, missing32) = m.eq
      then g.nm.areal.map!word := g.nm.areal.map!word NEQV (1 << bit)

      next.bit (@word, @bit)
   $)
$)


/*
      set.up.grid.maps

         unpacks the current dataset into the areal vector and sets up
         two bit maps, one that has a zero bit corresponding to a
         missing value, the other that has a zero bit corresponding
         to a zero value (after first pass) or a pair of zeroes (after
         second pass)

         the first bit map is built in the areal map, which is of the
         correct size and serves no use for grid-mappable data;
         the second map is build in the frame buffer and cached in the
         areal vector area
*/

and set.up.grid.maps (pass) = valof
$( let word = 0
   and bit  = 0
   and index = ?
   and missing32 = vec 1
   and zero32 = vec 1

   g.ut.set32 (0, m.nm.max.neg.high, missing32)
   g.ut.set32 (0, 0, zero32)

   unless unpack.data () resultis false

   // make buffer dirty before writing to it
   g.nm.init.frame.buffer ()

   test pass = 1
   then $( // initialise both maps to all 1's
           g.nm.areal.map!0 := (#Xffff << 16) | #Xffff
              // 16/32 bit independent
           MOVE (g.nm.areal.map, g.nm.areal.map + 1, m.nm.areal.map.size)
           MOVE (g.nm.areal.map, g.nm.frame, m.nm.areal.map.size + 1)

           // note that element 0 is used for grid-mappable data
           for i = 0 to g.nm.s!m.next - 1
           $( index := i * m.nm.max.data.size
              test g.ut.cmp32 (g.nm.areal + index, missing32) = m.eq
              then g.nm.areal.map!word := g.nm.areal.map!word & (NOT (1 << bit))
              else if g.ut.cmp32 (g.nm.areal + index, zero32) = m.eq
                      g.nm.frame!word := g.nm.frame!word & (NOT (1 << bit))
              next.bit (@word, @bit)
           $)

           g.ut.cache (g.nm.frame, m.nm.areal.map.size, m.io.wa.nm.areal)
        $)
   else $( g.ut.restore (g.nm.frame, m.nm.areal.map.size, m.io.wa.nm.areal)

           for i = 0 to g.nm.s!m.next - 1
           $( index := i * m.nm.max.data.size
              test g.ut.cmp32 (g.nm.areal + index, missing32) = m.eq
              then g.nm.areal.map!word := g.nm.areal.map!word & (NOT (1 << bit))
              else if g.ut.cmp32 (g.nm.areal + index, zero32) ~= m.eq &
                      (g.nm.frame!word & (1 << bit)) = 0
                   g.nm.frame!word := g.nm.frame!word | (1 << bit)

              next.bit (@word, @bit)
           $)

           // AND the two maps together to remove all pairs of values
           // where either at least one value is missing or both values are 0
           for w = 0 to m.nm.areal.map.size
              g.nm.areal.map!w := g.nm.areal.map!w & g.nm.frame!w
        $)
   resultis true
$)


/*
      remove.missing.values

         applies the modified areal map to the areal vector to
         remove all values whose bit in the map is zero

         returns the number of remaining values
*/

and remove.missing.values (dataset.type) = valof
$( let last, word, bit = -1, 0, 0

   if dataset.type = m.nm.areal.mappable.data then
      resultis (g.nm.apply.areal.map (FALSE) + 1)

   // apply the map starting at element 0 of the areal vector
   for i = 0 to g.nm.s!m.next - 1 do
   $( if (g.nm.areal.map!word & (1 << bit)) ~= 0
      $( last := last + 1
         g.ut.mov32 (g.nm.areal + i * m.nm.max.data.size,
                     g.nm.areal + last * m.nm.max.data.size)
      $)
      next.bit (@word, @bit)
   $)
   resultis last + 1
$)


/*
      next.bit

         increments word, bit pair to access next bit in a map
*/

and next.bit (word.ptr, bit.ptr) be
$( !bit.ptr := !bit.ptr + 1
   if !bit.ptr = BITSPERWORD
   $( !word.ptr := !word.ptr + 1
      !bit.ptr := 0
   $)
$)


/*
      unpack.data

         unpacks grid-mappable data into the areal vector
         on exit, g.nm.s!m.next gives the number of values
         in the areal vector
*/

and unpack.data () = valof
$(
   g.nm.s!m.next := 0
   g.nm.init.processor (g.context!m.grbleast, g.context!m.grblnorth,
                        g.context!m.grtreast, g.context!m.grtrnorth)

   resultis g.nm.process.variable (unpack.uniform, unpack.fine)
$)


/* Unpacking routines, for grid square data, to be used by
   g.nm.process.variable follow ; they unpack the data into the areal vector,
   which is available as workspace since it serves no function for grid data
*/

/*
      unpack.uniform

         unpacks the values of a uniform block which fall in the AOI
         into the areal vector
*/

and unpack.uniform (record.number, offset, east, north, block.size) be
$(
   let value = vec m.nm.max.data.size
   and num.e, num.n, num = ?, ?, ?

   if record.number = m.nm.uniform.missing offset := record.number

   test g.nm.dual.data.type (g.nm.s!m.nm.raster.data.type)
   then g.ut.set32 (offset, 0, value)
   else g.ut.set32 ( - record.number, 0, value)

   // calculate the number of squares that actually lie within the
   // area of interest

   num.e := g.nm.min (east + block.size, g.nm.s!m.nm.grid.sq.top.e) -
                                g.nm.max (east, g.nm.s!m.nm.grid.sq.low.e)

   num.n := g.nm.min (north + block.size, g.nm.s!m.nm.grid.sq.top.n) -
                                 g.nm.max (north, g.nm.s!m.nm.grid.sq.low.n)

   num := g.nm.max (num.e, 0) * g.nm.max (num.n, 0)

   if num > 0
   $( g.ut.mov32 (value, g.nm.areal + g.nm.s!m.next * m.nm.max.data.size)
      if num > 1   // replicate the value into adjacent cells
         MOVE (g.nm.areal + g.nm.s!m.next * m.nm.max.data.size,
               g.nm.areal + (g.nm.s!m.next + 1) * m.nm.max.data.size,
               (num - 1) * m.nm.max.data.size)
      g.nm.s!m.next := g.nm.s!m.next + num
   $)
$)


/*
      unpack.fine

         unpacks the values in the fine block which fall
         within the AOI into the areal vector
*/

and unpack.fine (start.east, start.north) be
$(
   let curr.e, curr.n = ?, ?

   // see if whole fine block is within area of interest - if it is
   // then processing of the block can be performed more quickly

   let wholly.within =
         (start.east >= g.nm.s!m.nm.grid.sq.low.e) &
         (start.east + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.e) &
         (start.north >= g.nm.s!m.nm.grid.sq.low.n) &
         (start.north + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.n)

   // process block

   let index = m.nm.max.data.size

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
               g.ut.mov32 (g.nm.values + index,
                           g.nm.areal + g.nm.s!m.next * m.nm.max.data.size)

               g.nm.s!m.next := g.nm.s!m.next + 1
            $)inside

         index := index + m.nm.max.data.size
         $)square
$)
.




