//  PUK SOURCE  6.87

/**
         NM.DISPLAY2 - DISPLAY VARIABLE FOR NATIONAL MAPPABLE
         ----------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmDISP

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         25.6.87  3        DNH         CHANGES FOR UNI
         13.7.87  4        DNH         fix set32 in disp..u..block
         11.08.87 5        SRY         Modified for DataMerge

         g.nm.display.variable
**/

section "nmdisplay2"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nmhd.h"


/**
         G.NM.DISPLAY.VARIABLE - DISPLAY VARIABLE AS SQUARES
         ---------------------------------------------------

         Displays a variable, over the current area of interest,
         as coloured squares corresponding to classes.

         For grid square data, counts the number of non-missing
         squares that fall within the area of interest,

         For areal mappable data, registers accesses to the
         areal vector (in the areal map) for all squares
         within the area of interest and counts the number of
         areas accessed.

         Displays a warning in the message area if the
         number of areas = 0.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.num.areas
         g.nm.s!m.nm.windowed
         g.nm.areal.map

         PROGRAM DESIGN LANGUAGE:

         g.nm.display.variable []
         ---------------------

         turn off mouse pointer
         clear display area
         set plot window
         process variable with plot routines
         unset plot window
         indicate that display is not windowed
         IF areal data THEN
            count the number of areas accessed
               whose values were non-missing
         ENDIF
         IF number of areas = 0 THEN
            display warning message
         ENDIF
         restore mouse pointer
**/

let g.nm.display.variable () = valof
$( let result = false
   let entry.state = g.sc.pointer (m.sd.off)
   g.sc.clear (m.sd.display)

   // define graphics window for plotting
   g.nm.set.plot.window ()

   if g.nm.process.variable (display.uniform.block, display.fine.block)
   $( result := true
      // restore graphics window to its default setting

      g.nm.unset.plot.window ()
      g.nm.s!m.nm.windowed := FALSE

      if g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data
      $(
         let max.neg32 = vec 1
         g.ut.set32 (0, m.nm.max.neg.high, max.neg32)

         g.nm.s!m.nm.num.areas := 0

         for i = 1 to g.nm.s!m.nm.nat.num.areas do
            if g.nm.map.hit (i) do
               unless g.ut.cmp32 (g.nm.areal + i * m.nm.max.data.size,
                                      max.neg32 ) = m.eq do
                  g.nm.s!m.nm.num.areas := g.nm.s!m.nm.num.areas + 1
      $)

      if g.nm.s!m.nm.num.areas = 0
      $( g.sc.movea (m.sd.display, m.sd.charwidth * 3, m.sd.distop * 3 / 4)
         g.sc.odrop ("All data in this area is missing")
      $)

   $)
   g.sc.pointer (entry.state)
   resultis result
$)


/*    Plot routines to be used by g.nm.process.variable follow    */


/*
      display.uniform.block

         plots a block whose values are all the same, due to
         index level compression

         for areal mappable data, sets entry in areal map
         for grid square data, counts non-missing squares that fall within
            the area of interest
*/

and display.uniform.block (record.number, offset, east, north, block.size) be
$(
   let value = vec m.nm.max.data.size - 1
   and num.e, num.n  =  ?, ?


   test (record.number = m.nm.uniform.missing) then
      g.ut.set32 (0, m.nm.uniform.missing, value)

   else                 // record.number <= 0

      test (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data) then
      $(
         g.ut.mov32 (g.nm.areal + ( (- record.number) * m.nm.max.data.size ),
                                                         value)

         g.nm.set.map.entry (-record.number)

      $)

      else

      $(

         test g.nm.dual.data.type (g.nm.s!m.nm.raster.data.type) then
            g.ut.set32 (offset, 0, value)
         else
            g.ut.set32 (-record.number, 0, value)

         // calculate the number of squares that actually lie within the
         // area of interest

         num.e := g.nm.min (east + block.size, g.nm.s!m.nm.grid.sq.top.e) -
                  g.nm.max (east, g.nm.s!m.nm.grid.sq.low.e)

         num.n := g.nm.min (north + block.size, g.nm.s!m.nm.grid.sq.top.n) -
                  g.nm.max (north, g.nm.s!m.nm.grid.sq.low.n)

         g.nm.s!m.nm.num.areas := g.nm.s!m.nm.num.areas +
                           (g.nm.max (num.e, 0) * g.nm.max (num.n, 0) )
      $)



   g.sc.selcol ( g.nm.square.colour (value) )
   g.nm.plot.block (east, north, block.size)
$)


/*
      display.fine.block

         plots the specified fine block of values

         For every square that falls within area of interest:
            for areal mappable data, sets entry in areal map
            for grid square data, adds 1 to the number of areas count

         assumes the following order for an n*n matrix of values
         1 -> n*n, where n is m.nm.fine.blocksize :

               .
               .
               .
         n+1   n+2   n+3   ...   ...   2n
          1     2     3    ...   ...    n
*/

and display.fine.block (start.east, start.north) be
$(
   let areal.data, wholly.within =  ?, ?
   let max.neg32 = vec 1
   and curr.e, curr.n, index, area, last.area  =  ?, ?, ?, ?, ?

   areal.data := (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data)
   unless areal.data do
      g.ut.set32 (0, m.nm.max.neg.high, max.neg32)
   last.area := -1

   // see if whole fine block is within area of interest - if it is
   // then processing of the block can be performed more quickly

   wholly.within :=
         (start.east >= g.nm.s!m.nm.grid.sq.low.e) &
         (start.east + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.e) &
         (start.north >= g.nm.s!m.nm.grid.sq.low.n) &
         (start.north + m.nm.fine.blocksize <= g.nm.s!m.nm.grid.sq.top.n)

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
            test areal.data then
            $(
            // NOTE g.nm.values contains boundary values which are used to
            //      index areal vector - all boundary values fit into 16 bits
               area := g.nm.values!index
               if area ~= last.area then
                  $(
                     g.nm.set.map.entry (area)
                     last.area := area
                  $)
            $)
            else  // grid-square data: only count non-missing grid-squares
               unless g.ut.cmp32 (max.neg32, g.nm.values + index) = m.eq do
                  g.nm.s!m.nm.num.areas := g.nm.s!m.nm.num.areas + 1


         index := index + m.nm.max.data.size
         $)square

   // now plot the block in one go
   g.nm.plot.fine.block (start.east, start.north, g.nm.values)
$)

.

