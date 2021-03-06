//  PUK SOURCE  6.87

/**
         NM.LINK - LINK OPERATION FOR MAPPABLE DATA
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmLINK

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         16.06.86 1        D.R.Freed   Initial version
         09.10.86 2        DRF         Optimised
         21.11.86 3        DRF         Bug fix
         ********************************
         7.7.87      2     DNH      CHANGES FOR UNI
         13.7.87     3     DNH      set32 for widen

         g.nm.link.handler
**/

section "nmlink"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nmhd.h"

get "H/nmcphd.h"

/**
         G.NM.LINK.HANDLER - THE LINK SUB-OPERATION
         ------------------------------------------

         The guts of the link sub-operation.

         INPUTS:

         Item NAMES file record for link dataset

         OUTPUTS:

         Returns TRUE if the operation was successful,
                 FALSE otherwise

         GLOBALS MODIFIED:

         g.context
         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         This routine is called indirectly by having its address
         assigned to g.nm.compare.sub.op in the .ini transition
         routine.

         PROGRAM DESIGN LANGUAGE:

         g.nm.link.handler [item.record] RETURNS success
         -----------------

         IF datasets are not the same mappable type THEN
            output error message
            RETURN FALSE
         ENDIF

         save current context before manipulating new dataset
         copy item.record to g.context
         IF load new dataset is successful THEN
            IF data type = incidence THEN
               IF display is not already linked THEN
                  clear message area
                  save screen
               ENDIF
               assign logical colours for link displays
               display link key
               initialise the variable processor
               link the dataset with the current display
               result is TRUE
            ELSE
               output error message
               result is FALSE
            ENDIF
         ELSE
            output error message
            result is FALSE
         ENDIF
         restore context
         IF result is TRUE THEN
            set linked.display flag
         ENDIF
         IF data is areal-mappable THEN
            reload areal vector
         ENDIF
         re-initialise the variable processor
         RETURN result
**/

let g.nm.link.handler (item.record) = valof
$(
   let success, current.type = ?, ?

   current.type := g.context%m.itemtypeoff

   if current.type ~= item.record%m.type then
      $(
         test (current.type = m.nm.grid.mappable.data) then
            g.sc.ermess ("Not a grid-mappable dataset")
         else
            g.sc.ermess ("Not an areal-mappable dataset")

         resultis FALSE
      $)

   g.nm.save.context ()

   g.ut.movebytes (item.record, 0,
                   g.context + m.itemrecord, 0, m.itemrecord.length)
   test g.nm.load.dataset () then
      test g.nm.s!m.nm.value.data.type = m.nm.incidence.type then
         $(
            // save the original screen the first time a link is done, so
            // that it can be easily restored later, after linking displays
            // NB: the screen save uses the areal vector's cache area as
            //     intermediate workspace, so areal vector needs to be
            //     reloaded from  disc at the end

            if (NOT g.nm.s!m.linked.display) then
               $(
                  // clear message area to prevent weird palette effects
                  // when restoring screen containing key

                  g.sc.clear (m.sd.message)
                  g.nm.save.screen ()
               $)

            // use logical colours reserved for key foregrounds;
            // the normal keys must never be displayed from now
            // until exit from Compare

            g.sc.palette (m.bg.nodata, m.sd.blue2)
            g.sc.palette (m.fg.nodata, g.sc.complement.colour (m.bg.nodata) )
            g.sc.palette (m.bg.coinc, m.sd.red2)
            g.sc.palette (m.fg.coinc, g.sc.complement.colour (m.bg.coinc) )

            g.nm.display.link.key ()

            g.nm.init.processor (g.context!m.grbleast, g.context!m.grblnorth,
                                 g.context!m.grtreast, g.context!m.grtrnorth)
            success := link.display ()
         $)
      else
         $(
            g.sc.ermess ("Not an incidence dataset")
            success := FALSE
         $)
   else
      $(
         g.sc.ermess ("Not available at same detail")
         success := FALSE
      $)

   g.nm.restore.context ()

   // NOTE: flag must be set after restoring context, otherwise the old
   //       value will be restored

   if success then
      g.nm.s!m.linked.display := TRUE

   // reload areal vector from disc, since the cache was overwritten when
   // the screen was saved

   if g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data then
      unless g.nm.load.areal.data () resultis false

   g.nm.init.processor (g.context!m.grbleast, g.context!m.grblnorth,
                        g.context!m.grtreast, g.context!m.grtrnorth)
   resultis success
$)


/*
      link.display

         links the new current variable with the existing display
*/

and link.display () = valof
$(
   let entry.state = g.sc.pointer (m.sd.off)
   let success = ?

   // define graphics window whilst plotting
   g.nm.set.plot.window ()

   success := g.nm.process.variable (link.uniform.block, link.fine.block)

   // restore graphics window to its default setting
   g.nm.unset.plot.window ()

   g.sc.pointer (entry.state)
   resultis success
$)


/*    Link routines to be used by g.nm.process.variable follow    */


/*
      link.uniform.block

         links a block whose values are all the same, due to
         index level compression

         for the link process, a uniform block must be converted to
         (a) fine one(s) and processed one grid square at a time, since
         the current display will not have uniform blocks in all the
         same places; the only exception to this is a uniform black block
         which will make anything black
*/

and link.uniform.block (record.number, offset, east, north, block.size) be
$(
   test record.number = m.nm.uniform.missing then
      $(
                  // uniform missing data block - always black
         g.ut.set32 (0, m.nm.uniform.missing, g.nm.values)
         link.block (east, north, block.size, square.colour (g.nm.values) )
      $)
   else           // record.number <= 0
      $(
         test g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data then

            g.ut.mov32 (g.nm.areal + (- record.number) * m.nm.max.data.size,
                        g.nm.values)

         else
            test g.nm.dual.data.type (g.nm.s!m.nm.raster.data.type) then
               g.ut.set32 (offset, 0, g.nm.values)
            else
               g.ut.set32 ( - record.number, 0, g.nm.values)

         g.nm.init.values.buffer ()
         MOVE (g.nm.values, g.nm.values + m.nm.max.data.size,
               m.nm.fine.blocksize * m.nm.fine.blocksize * m.nm.max.data.size)

         // break a coarse uniform block down into 16 fine ones; a
         // fine block will cause just one iteration
         for e = 0 to (block.size - m.nm.fine.blocksize) by
                                                    m.nm.fine.blocksize do
            if (east + e < g.nm.s!m.nm.grid.sq.top.e) &
               (east + e + m.nm.fine.blocksize >
                                          g.nm.s!m.nm.grid.sq.low.e) then

               for n = 0 to (block.size - m.nm.fine.blocksize) by
                                                    m.nm.fine.blocksize do
                  if ( (north + n) < g.nm.s!m.nm.grid.sq.top.n) &
                        ( (north + n + m.nm.fine.blocksize) >
                                    g.nm.s!m.nm.grid.sq.low.n) then

                     link.fine.block (east + e, north + n)
      $)
$)


/*
      link.fine.block

         links the specified fine block of values

         assumes the following order for an n*n matrix of values
         1 -> n*n, where n is m.nm.fine.blocksize :

               .
               .
               .
         n+1   n+2   n+3   ...   ...   2n
          1     2     3    ...   ...    n
*/

and link.fine.block (start.east, start.north) be
$(
   let areal.data, wholly.within =  ?, ?
   and curr.e, curr.n, index, area, last.area, colour =  ?, ?, ?, ?, ?, ?
   and last.colour  =  ?

   areal.data := (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data)

   // see if whole fine block is within area of interest - if it is
   // then processing of the block can be performed more quickly

   wholly.within :=
         (start.east >= g.nm.s!m.nm.grid.sq.low.e) &
         (start.east + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.e) &
         (start.north >= g.nm.s!m.nm.grid.sq.low.n) &
         (start.north + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.n)

   last.area := -1

   // process block

   index := m.nm.max.data.size

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
            test areal.data then
               $(areal
               // NOTE g.nm.values contains boundary values which are used to
               //      index areal vector - all boundary values fit into lsw

               area := g.nm.values!index

               test area = last.area then
                  colour := last.colour
               else
                  $(norepeat
                     colour := square.colour (
                                 g.nm.areal + (area * m.nm.max.data.size) )
                     last.area := area
                     last.colour := colour
                  $)norepeat
               $)areal
            else
               $(gridsquare
               colour := square.colour (g.nm.values + index)
               $)gridsquare

            link.block (curr.e, curr.n, 1, colour)
            $)inside

         index := index + m.nm.max.data.size
         $)square
$)


/*
      square.colour

         determines the colour to be used for linking an incidence
         value (32 bits)
*/

and square.colour (value.ptr) = valof
$(
   let max.neg32 = vec 1

   and junk = ?

   g.ut.set32 (1, m.nm.max.neg.high, max.neg32)

   if g.ut.get32 (value.ptr, @junk) = 1  RESULTIS m.bg.coinc

   if ( g.ut.cmp32 (value.ptr, max.neg32) = m.eq ) RESULTIS m.sd.black2

   RESULTIS m.bg.nodata
$)


/*
      link.block

      links a block of grid squares (single square, fine block or
      coarse block) by plotting pixels according to the decision table:

            \  new
         old  \
                     BLACK    BLUE     RED
                ----------------------------
         BLACK  |  plot        -        -
                |  BLACK
                |
         BLUE   |  plot        -        -
                |  BLACK
                |
         RED    |  plot      plot       -
                |  BLACK     BLUE
                |
         OTHER  |  plot      plot      plot
                |  BLACK     BLUE      BLUE
                |


      NB: PLOT (library plot block routine) contains the routine
          g.nm.plot.block which this routine was closely based on
          but is separate for efficiency reasons; if this
          routine is optimised to speed up the link time
          then g.nm.plot.block should be similarly modified
*/

and link.block (grid.sq.east, grid.sq.north, block.size, logical.colour) be
$(
   let x1, y1, size.x, size.y  =  ?, ?, ?, ?
   and old.colour, new.colour, plot.colour = ?, ?, ?

   x1 := (grid.sq.east - g.nm.s!m.nm.grid.sq.low.e) *
            g.nm.s!m.nm.x.graph.per.grid.sq +
               g.nm.s!m.nm.x.graph.start

   y1 := (grid.sq.north - g.nm.s!m.nm.grid.sq.low.n) *
            g.nm.s!m.nm.y.graph.per.grid.sq +
               g.nm.s!m.nm.y.graph.start

   g.sc.movea (m.sd.display, x1, y1)

   size.x := block.size * g.nm.s!m.nm.x.graph.per.grid.sq - 1
   size.y := block.size * g.nm.s!m.nm.y.graph.per.grid.sq - 1

   // determine new physical colour
   new.colour := g.sc.physical.colour (logical.colour)

   // if new colour is black, simply plot a black block and return, to
   // save having to read the screen; in the case of a uniform missing
   // coarse block, it could take a long time to find a point which is
   // on-screen

   if (new.colour = m.sd.black2) then
      $(
         g.sc.selcol (logical.colour)
         g.sc.rect (m.sd.plot, size.x, size.y)
         return
      $)

   // determine current physical colour of first pixel in block;
   // if this is off screen, then find a pixel which is on screen
   // and determine its colour - one of them must be on screen,
   // and should be representative of the whole block

   old.colour := g.sc.pixcol ()

   if (old.colour = #xff) then
      $(
         let dx, dy = x1, y1

         while (old.colour = #xff) do
            $(
               g.sc.movea (m.sd.display, dx, dy)
               old.colour := g.sc.pixcol ()
               dy := dy + m.nm.y.pixels.to.graphics
               if (dy - y1) > size.y then
                  $(
                     dx := dx + m.nm.x.pixels.to.graphics
                     dy := y1
                  $)
            $)

         // move back to first pixel for plotting new block
         g.sc.movea (m.sd.display, x1, y1)
      $)

   // convert logical colour to physical colour
   old.colour := g.sc.physical.colour (old.colour)

   // take action based on decision table in header

   plot.colour := - 1

   test (new.colour = m.sd.blue2) &
        (old.colour ~= m.sd.black2) &
        (old.colour ~= m.sd.blue2) then
      plot.colour := logical.colour

   else if (new.colour = m.sd.red2) &
           (old.colour ~= m.sd.black2) &
           (old.colour ~= m.sd.blue2) &
           (old.colour ~= m.sd.red2) then
      plot.colour := m.bg.nodata

   if (plot.colour ~= -1) then

      $(
         // plot square using logical colour
         g.sc.selcol (plot.colour)
         g.sc.rect (m.sd.plot, size.x, size.y)
      $)
$)
.
