//  PUK SOURCE  6.87

/**
         NM.PROCESS - VARIABLE PROCESSOR FOR NATIONAL MAPPABLE
         -----------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         15.01.86 1        D.R.Freed   Initial version
         26.02.86 2        DRF         Call to
                                       g.nm.unpack.fine.block
                                       moved here from
                                                NM.DISPLAY2
                                       AOI passed as params
                                       g.nm.convert.refs.to.km
                                       works out grid system
                                       nm.min/max made global
                                       Relative record numbers
                                          converted to absolute
                                          here rather than in
                                          load index routines
                                       Coarse index removed from
                                          g.nm.s and held in
                                          dedicated vectors
                                       Processes whole AOI, not
                                          just rasterised data
                                       Init.processor modified
                                          to handle cases where
                                          AOI starts before data
                                          & to use num blocks we
                                          & ns as upper limits
                                          for data

         ********************************
         19.6.87     3     DNH      CHANGES FOR UNI

         g.nm.init.processor
         g.nm.process.variable
         g.nm.convert.refs.to.km
**/

section "nmprocess"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/grhd.h"
get "H/nmhd.h"


/**
         G.NM.INIT.PROCESSOR - INITIALISE VARIABLE PROCESSOR
         ---------------------------------------------------

         Initialises global statics relating to current area of
         interest and scope of rasterized data.

         INPUTS:

         Area of interest (AOI) :
            bottom left easting
            bottom left northing
            top right easting
            top right northing

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.km.low.e
         g.nm.s!m.nm.km.top.e
         g.nm.s!m.nm.km.low.n
         g.nm.s!m.nm.km.top.n
         g.nm.s!m.nm.grid.sq.low.e
         g.nm.s!m.nm.grid.sq.top.e
         g.nm.s!m.nm.grid.sq.low.n
         g.nm.s!m.nm.grid.sq.top.n
         g.nm.s!m.nm.grid.sq.start.e
         g.nm.s!m.nm.grid.sq.start.n
         g.nm.s!m.nm.grid.sq.end.e
         g.nm.s!m.nm.grid.sq.end.n
         g.nm.s!m.nm.blk.low.e
         g.nm.s!m.nm.blk.top.e
         g.nm.s!m.nm.blk.low.n
         g.nm.s!m.nm.blk.top.n
         g.nm.s!m.nm.blk.start.e
         g.nm.s!m.nm.blk.start.n
         g.nm.s!m.nm.blk.end.e
         g.nm.s!m.nm.blk.end.n
         g.nm.s!m.nm.grid.system
         g.nm.s!m.nm.raster.grid.system

         SPECIAL NOTES FOR CALLERS:

         This routine must be called before g.nm.process.variable
         is called whenever the area of interest or sub-dataset
         changes.

         PROGRAM DESIGN LANGUAGE:

         g.nm.init.processor [grbleast, grblnorth, grtreast, grtrnorth]
         -------------------

         convert area of interest grid references to km
         convert scope of rasterized data to km

         calculate area of interest in terms of grid squares
         calculate scope of rasterized data in terms of grid
                                                      squares

         calculate area of interest in terms of coarse blocks
         calculate scope of rasterized data in terms of coarse
                                                      blocks
**/

let g.nm.init.processor (grbleast, grblnorth, grtreast, grtrnorth) be
$(
   let km.start.e, km.start.n   =  ?, ?
   and km.end.e, km.end.n = ?, ?

   g.nm.convert.refs.to.km (grbleast, grblnorth, grtreast, grtrnorth,
                            g.nm.s + m.nm.km.low.e, g.nm.s + m.nm.km.low.n,
                            g.nm.s + m.nm.km.top.e, g.nm.s + m.nm.km.top.n,
                            g.nm.s + m.nm.grid.system)

   g.nm.convert.refs.to.km (g.nm.s!m.nm.gr.start.e, g.nm.s!m.nm.gr.start.n,
                            g.nm.s!m.nm.gr.end.e, g.nm.s!m.nm.gr.end.n,
                            @km.start.e, @km.start.n, @km.end.e, @km.end.n,
                            g.nm.s + m.nm.raster.grid.system)

   g.nm.s!m.nm.grid.sq.low.e := g.nm.s!m.nm.km.low.e / g.context!m.resolution
   g.nm.s!m.nm.grid.sq.top.e :=
      (g.nm.s!m.nm.km.top.e + g.context!m.resolution - 1) /
                                                      g.context!m.resolution
   g.nm.s!m.nm.grid.sq.low.n := g.nm.s!m.nm.km.low.n / g.context!m.resolution
   g.nm.s!m.nm.grid.sq.top.n :=
      (g.nm.s!m.nm.km.top.n + g.context!m.resolution - 1) /
                                                      g.context!m.resolution

   g.nm.s!m.nm.grid.sq.start.e := km.start.e / g.context!m.resolution
   g.nm.s!m.nm.grid.sq.start.n := km.start.n / g.context!m.resolution

   g.nm.s!m.nm.grid.sq.end.e :=
               (km.end.e + g.context!m.resolution - 1) / g.context!m.resolution
   g.nm.s!m.nm.grid.sq.end.n :=
               (km.end.n + g.context!m.resolution - 1) / g.context!m.resolution

   g.nm.s!m.nm.blk.low.e :=
      muldiv ( (g.nm.s!m.nm.grid.sq.low.e - g.nm.s!m.nm.grid.sq.start.e), 1,
               m.nm.coarse.blocksize) + 1
   if (RESULT2 < 0) then
      g.nm.s!m.nm.blk.low.e := g.nm.s!m.nm.blk.low.e - 1

   g.nm.s!m.nm.blk.top.e :=
      muldiv ( (g.nm.s!m.nm.grid.sq.top.e - g.nm.s!m.nm.grid.sq.start.e), 1,
               m.nm.coarse.blocksize )
   if (RESULT2 > 0) then
         g.nm.s!m.nm.blk.top.e := g.nm.s!m.nm.blk.top.e + 1

   g.nm.s!m.nm.blk.low.n :=
      muldiv ( (g.nm.s!m.nm.grid.sq.low.n - g.nm.s!m.nm.grid.sq.start.n), 1,
               m.nm.coarse.blocksize) + 1
   if (RESULT2 < 0) then
      g.nm.s!m.nm.blk.low.n := g.nm.s!m.nm.blk.low.n - 1

   g.nm.s!m.nm.blk.top.n :=
      muldiv ( (g.nm.s!m.nm.grid.sq.top.n - g.nm.s!m.nm.grid.sq.start.n), 1,
               m.nm.coarse.blocksize)
   if (RESULT2 > 0) then
         g.nm.s!m.nm.blk.top.n := g.nm.s!m.nm.blk.top.n + 1

   g.nm.s!m.nm.blk.start.e := 1
   g.nm.s!m.nm.blk.start.n := 1
   g.nm.s!m.nm.blk.end.e := g.nm.s!m.nm.num.we.blocks
   g.nm.s!m.nm.blk.end.n := g.nm.s!m.nm.num.sn.blocks
$)


/**
         G.NM.CONVERT.REFS.TO.KM - CONVERT GRID REFS TO KM
         -------------------------------------------------

         Converts the given grid references true kilometre
         references and sets up grid system accordingly.

         INPUTS:

         bottom left easting
         bottom left northing
         top right easting
         top right northing
         address of km bl easting
         address of km bl northing
         address of km tr easting
         address of km tr norting
         address of grid system indicator

         OUTPUTS: none

         GLOBALS MODIFIED: none

         PROGRAM DESIGN LANGUAGE:

         g.nm.convert.refs.to.km [grbleast, grblnorth,
         -----------------------    grtreast, grtrnorth,
                                    km.ble.ptr, km.bln.ptr,
                                    km.tre.ptr, km.trn.ptr,
                                    grid.system.ptr]

         convert bottom left references
         convert top right references
         set up grid system
**/

and g.nm.convert.refs.to.km (grbleast, grblnorth, grtreast, grtrnorth,
                             km.ble.ptr, km.bln.ptr, km.tre.ptr, km.trn.ptr,
                             grid.system.ptr) be
$(
   nm.convert.gr.to.km (grbleast, grblnorth, FALSE,
                        km.ble.ptr, km.bln.ptr, grid.system.ptr)

   nm.convert.gr.to.km (grtreast, grtrnorth, TRUE,
                        km.tre.ptr, km.trn.ptr, grid.system.ptr)
$)


/*
      nm.convert.gr.to.km

         converts all .1 km grid references to km

         clears top bit of eastings - these are artificially set
         to signal Irish and Channel Isles references

         sets up grid system indicator
*/

and nm.convert.gr.to.km (easting, northing, round.up.flag, km.easting.ptr,
                         km.northing.ptr, grid.system.ptr) be
$(
   let grid.ref = vec 2
   and constant = vec 2
   and remainder = vec 2

   // determine which grid system refs are in, for later conversion back
   !grid.system.ptr :=
      (easting & #x8000) = 0 -> m.grid.is.GB,
                                (northing & #x8000) = 0 -> m.grid.is.NI,
                                                           m.grid.is.Channel
   easting := easting & #X7fff

   g.ut.set32 (northing, 0, grid.ref)
            // needs to be handled as a 32-bit quantity
            // since it is a 16-bit unsigned number and
            // top bit is set for Channel Isles refs

   if round.up.flag then

      $(
         easting := easting + 9
         g.ut.set32 (9, 0, constant)
         g.ut.add32 (constant, grid.ref)
      $)

   !km.easting.ptr := easting / 10

   g.ut.set32 (10, 0, constant)

   if (g.ut.div32 (constant, grid.ref, remainder) ~= 0) then   // always true
   $(
      let junk = ?
      !km.northing.ptr := g.ut.get32 (grid.ref, @junk)
   $)
$)


/**
         G.NM.PROCESS.VARIABLE - PROCESS VARIABLE
         ----------------------------------------

         Processes a variable, over the current area of interest,
         using the given routines to process uniform and fine
         blocks.

         INPUTS:

         Address of routine to process a uniform block
         Address of routine to process a fine block

         OUTPUTS: none

         GLOBALS MODIFIED: none

         PROGRAM DESIGN LANGUAGE:

         g.nm.process.variable [uniform.routine.ptr,
         ---------------------          fine.routine.ptr]

         IF area of interest grid system is different to
               rasterised data grid system THEN
            RETURN
         ENDIF

         calculate start grid square coordinate north ;

         FOR all blocks north DO

            calculate start grid square coordinate east ;

            FOR all blocks east DO

               IF both block numbers are within
                                         rasterised data THEN
                  calculate index into coarse block index ;
                  process coarse block [coarse.index.entry,
                                        grid square east coord,
                                        grid square north coord,
                                        uniform.routine.ptr,
                                        fine.routine.ptr]
               ELSE
                  call uniform block routine with value
                                                = "missing"
               ENDIF

               increment grid square east coord by coarse
                                                   blocksize ;

            ENDFOR

            increment grid square north coord by coarse blocksize

         ENDFOR
**/

let g.nm.process.variable (uniform.routine.ptr, fine.routine.ptr) be
$(
   let grid.sq.east, grid.sq.north, coarse.index.entry  =  ?, ?, ?

   if (g.nm.s!m.nm.grid.system ~= g.nm.s!m.nm.raster.grid.system) THEN
      return

   // the area of interest may be larger than the scope of the
   // rasterised data; any blocks outside the data's block limits
   // will be processed as uniform missing data

   grid.sq.north := (g.nm.s!m.nm.blk.low.n - 1) * m.nm.coarse.blocksize +
                                                g.nm.s!m.nm.grid.sq.start.n

   for north = g.nm.s!m.nm.blk.low.n to g.nm.s!m.nm.blk.top.n do

      $(
         grid.sq.east :=
               (g.nm.s!m.nm.blk.low.e - 1) * m.nm.coarse.blocksize +
                                                g.nm.s!m.nm.grid.sq.start.e

         for east = g.nm.s!m.nm.blk.low.e to g.nm.s!m.nm.blk.top.e do
            $(
               test (g.nm.s!m.nm.blk.start.e <= east <=
                                       g.nm.s!m.nm.blk.end.e) &
                        (g.nm.s!m.nm.blk.start.n <= north <=
                                                g.nm.s!m.nm.blk.end.n) then
                  $(
                     coarse.index.entry :=
                        (north - 1) * g.nm.s!m.nm.num.we.blocks + east - 1

                     nm.process.coarse.block (coarse.index.entry,
                                              grid.sq.east, grid.sq.north,
                                              uniform.routine.ptr,
                                              fine.routine.ptr)
                  $)

               else
                  uniform.routine.ptr (m.nm.max.neg.high,
                                       m.nm.max.neg.high,
                                       grid.sq.east, grid.sq.north,
                                       m.nm.coarse.blocksize)

               grid.sq.east := grid.sq.east + m.nm.coarse.blocksize
            $)

         grid.sq.north := grid.sq.north + m.nm.coarse.blocksize
      $)

$)


/*
      nm.process.coarse.block

         processes a coarse block of grid squares, given its entry in
         the coarse index, the grid square references of its
         bottom left hand corner and the routines to be used to
         process uniform and fine blocks

         NB:
         The indices contain the original relative record numbers
         and 2-byte offsets.  Where these are used for
         compression, they and the offsets are not modified, but
         where they are true record numbers they are converted to
         absolute record numbers here and the 2-byte offsets are
         adjusted and converted to byte offsets.
*/

and nm.process.coarse.block (coarse.index.entry, grid.sq.east, grid.sq.north,
                             uniform.routine.ptr, fine.routine.ptr) be
$(
   let record.number, offset, fine.east, fine.north   =  ?, ?, ?, ?
   and fine.index.entry, fine.record.number, fine.offset =  ?, ?, ?

   record.number := g.nm.coarse.index.record!coarse.index.entry
   offset := g.nm.coarse.index.offset!coarse.index.entry

   test (record.number = m.nm.uniform.missing) | (record.number <= 0) then

      // index level compression has been used at coarse level - whole block
      // has same value

      uniform.routine.ptr (record.number, offset, grid.sq.east,
                           grid.sq.north, m.nm.coarse.blocksize)
   else

      $(coarse

      // convert relative record number to absolute and adjust offset
      record.number := g.nm.s!m.nm.data.record.number + record.number - 1
      offset := (offset - 1) * 2    // adj. & convert to byte offset

      // get index for the 4*4 fine blocks within this coarse block and plot
      // the fine blocks which fall within the area of interest

      g.nm.load.fine.index (record.number, offset)

      fine.east := grid.sq.east

      for east = 1 to 4 do

         $(east

         if (fine.east < g.nm.s!m.nm.grid.sq.top.e) &
                  ( (fine.east + m.nm.fine.blocksize) >
                                          g.nm.s!m.nm.grid.sq.low.e) then
            $(inside.east

            for north = 1 to 4 do

               $(north

               // add northing adjustment to current grid square reference ;
               // table reflects the order in which the 16 fine blocks are
               // mapped:
               //    4   5  12  13
               //    3   6  11  14
               //    2   7  10  15
               //    1   8   9  16

               fine.north := grid.sq.north +
                              ((east - 1)*4 + north - 1)!
                                 table 0, 8, 16, 24, 24, 16, 8, 0,
                                       0, 8, 16, 24, 24, 16, 8, 0

               if (fine.north < g.nm.s!m.nm.grid.sq.top.n) &
                        ( (fine.north + m.nm.fine.blocksize) >
                                          g.nm.s!m.nm.grid.sq.low.n) then
                  $(inside.north

                  fine.index.entry := (east - 1) * 4 + north - 1
                  fine.record.number :=
                     g.nm.s!(m.nm.fine.index.record.number + fine.index.entry)
                  fine.offset :=
                     g.nm.s!(m.nm.fine.index.offset + fine.index.entry)

                  test (fine.record.number <= 0) |
                       (fine.record.number = m.nm.uniform.missing) then

                     // index level compression has been used at fine level -
                     // whole block has same value

                     uniform.routine.ptr (fine.record.number, fine.offset,
                                          fine.east, fine.north,
                                          m.nm.fine.blocksize)
                  else
                   $(
                     // convert relative record number to absolute and
                     // adjust offset
                     fine.record.number := g.nm.s!m.nm.data.record.number +
                                                         fine.record.number - 1
                     fine.offset := (fine.offset - 1) * 2

                     g.nm.unpack.fine.block (fine.record.number, fine.offset)
                     fine.routine.ptr (fine.east, fine.north)
                   $)

                  $)inside.north

               $)north

            $)inside.east

         fine.east := fine.east + m.nm.fine.blocksize

      $)east

   $)coarse
$)
.
