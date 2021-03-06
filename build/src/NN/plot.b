//  PUK SOURCE  6.87

/**
         NM.PLOT - LIBRARY PLOT BLOCK ROUTINES
         -------------------------------------

         NAME OF FILES CONTAINING RUNNABLE CODE:

         cnmDISP
         cnmWIND
         cnmRETR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         18/04/86 1        D.R.Freed   Initial version
         02/10/86 2        DRF         Optimised; colour
                                        no longer passed as
                                        a parameter in
                                        g.nm.plot.block;
                                       g.nm.plot.fine.block
                                         added
                                       g.nm.square.colour
                                         coded in assembler
                                         & moved to a.classify
         ********************************
         25.6.87     3     DNH      CHANGES FOR UNI
         12.08.87 5        SRY      Modified for DataMerge
         12.01.88    6     MH       A500 version - uses Osplot

         g.nm.plot.block
         g.nm.plot.fine.block

         NB: this module is machine specific because it uses
             direct VDU calls for speed
**/

section "nmplot"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nmhd.h"

manifest
$(             // data.size: 2 -> << 1
               //            1 -> << 0
   m.max.data.size.shift = m.nm.max.data.size - 1
$)


/**
         G.NM.PLOT.BLOCK - PLOT A BLOCK OF GRID SQUARES
         ----------------------------------------------

         Plots a block of squares at specified grid square
         coordinates of specified size in the current colour

         INPUTS:

         Grid square east coordinate
         Grid square north coordinate
         Size of block sides (block must be square)

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none


         SPECIAL NOTES FOR CALLERS:

         May be used to plot a single square, a fine block or a
         uniform block.

         NB: COMPARE3 (link sub-operation) contains the routine
             link.block which is closely based on this routine
             but is separate for efficiency reasons; if this
             routine is optimised to speed up the display time
             then link.block should be similarly modified

         PROGRAM DESIGN LANGUAGE:

         g.nm.plot.block [east, north, size]
         ---------------

         calculate x and y start positions in graphics coords
         calculate size in Domesday graphics coordinates
         plot square in current colour
**/

let g.nm.plot.block (grid.sq.east, grid.sq.north, block.size) be
$(
   let x = (grid.sq.east - g.nm.s!m.nm.grid.sq.low.e) *
           g.nm.s!m.nm.x.graph.per.grid.sq +
              g.nm.s!m.nm.x.graph.start

   // add display area offset for y since we are by-passing g.sc.movea
   let y = (grid.sq.north - g.nm.s!m.nm.grid.sq.low.n) *
           g.nm.s!m.nm.y.graph.per.grid.sq +
              g.nm.s!m.nm.y.graph.start +
                 m.sd.disY0

// g.sc.movea (m.sd.display, x, y)
//   VDU ("25,%,%;%;", 4, x, y)
   Osplot(4, x, y)

// g.sc.rect (m.sd.plot, size.x, size.y)
/*   VDU ("25,%,%;%;", #x61,
        block.size * g.nm.s!m.nm.x.graph.per.grid.sq - 1,
        block.size * g.nm.s!m.nm.y.graph.per.grid.sq - 1)
*/
   Osplot( #x61,
           block.size * g.nm.s!m.nm.x.graph.per.grid.sq - 1,
           block.size * g.nm.s!m.nm.y.graph.per.grid.sq - 1)
$)


/**
         G.NM.PLOT.FINE.BLOCK - PLOT A FINE BLOCK OF GRID SQUARES
         --------------------------------------------------------

         Plots a fine block of squares with specified grid square
         coordinate origin.

         INPUTS:

         Grid square east origin
         Grid square north origin
         Address of values/areas vector

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none


         SPECIAL NOTES FOR CALLERS:

         Only to be used for plotting a fine block of single squares

         PROGRAM DESIGN LANGUAGE:

         g.nm.plot.fine.block [east, north, values]
         --------------------

         calculate x and y start positions in graphics coords
         FOR east = 1 to fine blocksize
            FOR north = 1 to fine blocksize
               IF areal data THEN
                  get value for area
               ENDIF
               classify value into colour
               plot square
            ENDFOR
         ENDFOR
**/

and g.nm.plot.fine.block (grid.sq.east, grid.sq.north, values) be
$( let areal.data = (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data)
   let last.colour = -1
   let last.area = -1

   let start.x = (grid.sq.east - g.nm.s!m.nm.grid.sq.low.e) *
                 g.nm.s!m.nm.x.graph.per.grid.sq +
                    g.nm.s!m.nm.x.graph.start

   // add display area offset for y since we are by-passing g.sc.movea
   let y = (grid.sq.north - g.nm.s!m.nm.grid.sq.low.n) *
           g.nm.s!m.nm.y.graph.per.grid.sq +
              g.nm.s!m.nm.y.graph.start +
                 m.sd.disY0

   let size.x = g.nm.s!m.nm.x.graph.per.grid.sq - 1
   let size.y = g.nm.s!m.nm.y.graph.per.grid.sq - 1
   let index = m.nm.max.data.size

   for north = 1 to m.nm.fine.blocksize do

      $(
         let x = start.x

         for east = 1 to m.nm.fine.blocksize do

            $( let colour = last.colour
               test areal.data then
                  $(
                     let area = g.nm.values!index
                     unless area = last.area
                     $( colour := g.nm.square.colour ( g.nm.areal +
                                    (area << m.max.data.size.shift))
                        last.area := area
                     $)
                  $)
               else
                  colour := g.nm.square.colour (values + index)

               unless colour = last.colour
                  $(
                     g.sc.selcol (colour)
                     last.colour := colour
                  $)

               // g.sc.movea (m.sd.display, x, y)
               // VDU ("25,%,%;%;", 4, x, y)
               Osplot(4, x, y)

               // g.sc.rect (m.sd.plot, size.x, size.y)
               // VDU ("25,%,%;%;", #x61, size.x, size.y)
               Osplot(#x61, size.x, size.y) 

               index := index + m.nm.max.data.size
               x := x + size.x + 1
            $)

         y := y + size.y + 1
      $)
$)

.
