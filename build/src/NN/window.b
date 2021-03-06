//  PUK SOURCE  6.87

/**
         NM.WINDOW - WINDOW VARIABLE FOR NATIONAL MAPPABLE
         -------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmWIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         09.06.86 1        D.R.Freed   Initial version
         ********************************
         7.7.87      2     DNH      CHANGES FOR UNI
         12.08.87 3        SRY      Modified for DataMerge
         01.10.87 4        SRY      Fix file system bug
         ********************************
         07.06.88 5        SA       CHANGES FOR COUNTRYSIDE
                                    total function

         g.nm.window.variable
         g.nm.total
**/

section "nmwindow"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/dhhd.h"
get "H/sdhd.h"
get "H/grhd.h"
get "H/nmhd.h"
get "H/nmrehd.h"

/**
         G.NM.WINDOW.VARIABLE - WINDOW DISPLAYED VARIABLE
         ------------------------------------------------

         Window a variable display such that all areas falling
         outside the chosen area of interest are blacked out.

         Only called when area of interest was chosen by name

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.windowed

         PROGRAM DESIGN LANGUAGE:

         g.nm.window.variable []
         --------------------

         IF AOI areal unit ~= current areal unit THEN
            IF AOI areal unit boundary dataset exists THEN
               save context
               load dataset header
               IF available at current resolution THEN
                  load sub-dataset
               ENDIF
            ENDIF
         ENDIF

         IF above are available THEN
            initialise variable processor
            turn off mouse pointer
            set plot window
            process variable with window routines
            unset plot window
            restore mouse pointer
         ELSE
            output error message "Unable to window"
         ENDIF

         IF context was saved THEN
            restore context to entry state
         ENDIF

         IF window was done THEN
            re-initialise variable processor
            indicate that display is windowed
         ENDIF
**/

let g.nm.window.variable () be
$(
   let possible, different, context.saved =  ?, ?, ?
   let position, entry.state = ?, ?
   let save = g.nm.s!m.nm.file.system
   let bound.addr = vec 2
   let dummy = vec 16

   // Always window from VFS
   g.nm.s!m.nm.file.system := m.dh.vfs

   different := (g.context!m.type.AOI ~= g.context!m.areal.unit)
   context.saved := FALSE

   test different then
      // find boundary dataset for areal unit to be used for windowing
      possible :=
         g.nm.au.usable (0, g.context!m.type.AOI,
                                 dummy, dummy, dummy, bound.addr)
   else
      possible := TRUE

   if (possible & different) then
      $(
         // Save real file system!
         g.nm.s!m.nm.file.system := save
         g.nm.save.context ()
         g.nm.s!m.nm.file.system := m.dh.vfs
         context.saved := TRUE

         possible := g.nm.load.dataset.header (bound.addr)

         // ensure loader knows this is a boundary file
         g.nm.s!m.nm.dataset.type := m.nm.areal.boundary.data

         // look for sub-dataset at current resolution
         if possible possible := g.nm.look.for.subset (m.nm.raster.data.type,
                               g.context!m.resolution, @position)
         if possible possible := position >= 0
         if possible possible := g.nm.load.raster.sub.dataset (position)
      $)

   test possible then

      $(
         g.nm.init.processor (g.context!m.grbleast, g.context!m.grblnorth,
                              g.context!m.grtreast, g.context!m.grtrnorth)

         entry.state := g.sc.pointer (m.sd.off)

         // define graphics window for plotting
         g.nm.set.plot.window ()

         possible := g.nm.process.variable (window.uniform.block,
                                            window.fine.block)

         // restore graphics window to its default setting
         g.nm.unset.plot.window ()

         g.sc.pointer (entry.state)
      $)

   else
         g.sc.ermess ("Unable to window")

   if context.saved then
      possible := g.nm.restore.context ()

   // Reset filing system to previous state (restore.context does it too)
   g.nm.s!m.nm.file.system := save

   if possible then
      $(
         g.nm.init.processor (g.context!m.grbleast, g.context!m.grblnorth,
                              g.context!m.grtreast, g.context!m.grtrnorth)
         g.nm.s!m.nm.windowed := TRUE
      $)
$)



/*    Windowing routines to be used by g.nm.window.variable follow ;
      they plot all grid squares that are not in the AOI named area
      in black, thus leaving the AOI windowed
*/

/*
      window.uniform.block

         windows a block whose values are all the same, due to
         index level compression
*/

and window.uniform.block (record.number, offset, east, north, block.size) be
$(
   let value = ?

   test (record.number = m.nm.uniform.missing) then

      value := record.number

   else

      value := g.nm.dual.data.type (g.nm.s!m.nm.raster.data.type) ->
                                                   offset, - record.number

   if value ~= g.context!m.name.AOI then
      $(
         g.sc.selcol (m.sd.black2)
         g.nm.plot.block (east, north, block.size)
      $)
$)


/*
      window.fine.block

         windows the specified fine block of values

         assumes the following order for an n*n matrix of values
         1 -> n*n, where n is m.nm.fine.blocksize :

               .
               .
               .
         n+1   n+2   n+3   ...   ...   2n
          1     2     3    ...   ...    n
*/

and window.fine.block (start.east, start.north) be
$(
   let wholly.within, index  =  ?, ?

   // all plotting will be done in black
   g.sc.selcol (m.sd.black2)

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
         let curr.e, curr.n =
                  start.east + east - 1, start.north + north - 1

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
            // NOTE g.nm.values contains boundary values which are all
            //      contained within the lsw
            if g.nm.values!index ~= g.context!m.name.AOI then
               g.nm.plot.block (curr.e, curr.n, 1)
            $)inside

         index := index + m.nm.max.data.size
         $)square
$)

/**
         G.NM.TOTAL - SUM TOTAL OF VALUES WITHIN AREA OF INTEREST
         --------------------------------------------------------

         INPUTS: none

         OUTPUTS: total

         GLOBALS MODIFIED: none

         PROGRAM DESIGN LANGUAGE:

         g.nm.total []
         -------------

         IF area of interest specified by grid reference
         THEN
              IF dataset is grid mappable
              THEN total = CASE: AOI by grid reference; dataset grid-mappable
              ELSE total = CASE: AOI by grid reference; dataset areal-mappable
              ENDIF
         ELSE
              IF dataset is grid mappable
              THEN total = CASE: AOI by name; dataset grid-mappable
              ELSE total = CASE: AOI by name; dataset areal-mappable
              ENDIF
         ENDIF
**/

LET g.nm.total() = VALOF
$(
   LET result = ?

   TEST (g.context!m.type.AOI = -1)
   THEN TEST (g.nm.s!m.nm.dataset.type = m.nm.grid.mappable.data)
        THEN result := case3.total()
        ELSE result := case4.total()
   ELSE TEST (g.nm.s!m.nm.dataset.type = m.nm.grid.mappable.data)
        THEN result := case1.total()
        ELSE result := case2.total()

   RESULTIS result
$)

//AOI by name; dataset grid-mappable
AND case1.total() = VALOF
$(
   LET result = ?

   //calculate total masking out grid squares plotted in logical black
   g.nm.s!m.nm.mask.black.sqrs := TRUE
   result := general.total()

   RESULTIS result
$)

//AOI by name; dataset areal-mappable
AND case2.total() = VALOF
$(
   LET result = ?

   //calculate total masking out grid squares plotted in logical black
   g.nm.s!m.nm.mask.black.sqrs := TRUE
   result := general.total()

   //areal vector thrashed around by the retrieve code when
   //'mask black squares' flag is set & dataset is areal-mappable
   g.nm.restore.areal.vector()

   RESULTIS result
$)

//AOI by grid reference; dataset grid-mappable
AND case3.total() = VALOF
$(
   LET result = ?

   //calculate total NOT masking out grid squares plotted in logical black
   g.nm.s!m.nm.mask.black.sqrs := FALSE
   result := general.total()

   RESULTIS result
$)

//AOI by grid reference; dataset areal-mappable
AND case4.total() = VALOF
$(
   LET result = ?

   //calculate total masking out grid squares plotted in logical black
   g.nm.s!m.nm.mask.black.sqrs := TRUE
   result := general.total()

   //areal vector thrashed around by the retrieve code when
   //'mask black squares' flag is set & dataset is areal-mappable
   g.nm.restore.areal.vector()

   RESULTIS result
$)


//Utilities used by total

AND general.total() = VALOF
$(
   LET bl.east = ?
   AND tr.east = ?
   AND bl.north = ?
   AND tr.north = ?
   AND old.state = g.sc.pointer( m.sd.off )

   //translate effective display area coordinates to grid references
   find.easting( g.nm.s!m.nm.x.min, @bl.east )
   find.easting( g.nm.s!m.nm.x.max, @tr.east )
   find.northing( g.nm.s!m.nm.y.min, @bl.north )
   find.northing( g.nm.s!m.nm.y.max, @tr.north )

   //clear the sum total store
   g.ut.set48 (0,0,0, g.nm.s + m.sum.total)

   //Evaluate the function
   //Result deposited in 'g.nm.s + m.sum.total'.
   g.nm.retrieve.values( bl.east, bl.north, tr.east, tr.north)
   g.sc.pointer( old.state )

   //transfer result to permanent store 'g.nm.s + m.nm.total'
   g.ut.movebytes (g.nm.s+m.sum.total, 0, g.nm.s+m.nm.total, 0, 3*bytesperword)

   //clear the sum total store
   g.ut.set48 (0,0,0, g.nm.s + m.sum.total)

   RESULTIS TRUE
$)

//refer to g.nm.id.grid.ref for comments on the next two routines below
AND find.easting( x.coord, easting.ptr ) BE
$(
   LET x = g.nm.s!m.nm.km.low.e +
                 MULDIV( x.coord - g.nm.s!m.nm.x.min,
                         g.context!m.resolution,
                         g.nm.s!m.nm.x.graph.per.grid.sq )

   !easting.ptr := x * 10 

   IF ( g.nm.s!m.nm.grid.system = m.grid.is.NI ) |
      ( g.nm.s!m.nm.grid.system = m.grid.is.channel )
   THEN !easting.ptr := !easting.ptr | #x8000   //set top bit
$)

AND find.northing( y.coord, northing.ptr ) = VALOF
$(
   LET cons32 = VEC 1
   AND a32    = VEC 1
   LET y = g.nm.s!m.nm.km.low.n +
                 MULDIV( y.coord - g.nm.s!m.nm.y.min,
                         g.context!m.resolution,
                         g.nm.s!m.nm.y.graph.per.grid.sq )

   // need to use 32-bit arithmetic when manipulating northing, since
   // Channel Isles will have a true top bit set
   g.ut.set32 (10, 0, cons32)
   g.ut.set32 (y,  0, a32)

   test g.ut.mul32 (cons32, a32) then
   $(
      let junk = ?
      !northing.ptr := g.ut.get32 (a32, @junk)
   $)
   else
   $(
      g.ut.trap ("NM", 1, FALSE, 1, 1, 0, 0)
      resultis FALSE
   $)

   resultis TRUE
$)
.
