//  PUK SOURCE  6.87

/**
         NM.UTILS2 - MORE UTILITIES FOR NATIONAL MAPPABLE
         ------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         12.06.86 1        D.R.Freed   Initial version
         ********************************
         18.6.87  2        DNH         CHANGES FOR UNI
         11.08.87 3        SRY         Modified for DataMerge

         g.nm.load.dataset
         g.nm.replot
         g.nm.restore.areal.vector
         g.nm.save.screen
         g.nm.restore.screen
         g.nm.id.grid.pos
         g.nm.running.status
**/

section "nmutils2"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/dhhd.h"
get "H/iohd.h"
get "H/uthd.h"
get "H/grhd.h"
get "H/nmhd.h"


/**
         G.NM.LOAD.DATASET - LOAD A DATASET
         ----------------------------------

         Loads the headers and sub-dataset(s) for the current
         variable in g.context.

         INPUTS: none

         OUTPUTS:

         RETURNS TRUE if the load is successful,
                 FALSE if there is not a sub-dataset for
                       the current resolution and/or areal unit
                       in g.context

         GLOBALS MODIFIED:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.load.dataset [] RETURN success
         -----------------

         take private copy of item address
         load dataset header
         IF dataset is areal mappable THEN
            IF sub-dataset available for current areal unit THEN
               load it
            ELSE
               RETURN FALSE
            ENDIF
            load dataset header for rasterised boundary
         ENDIF
         IF sub-dataset available for current resolution THEN
            load it
         ELSE
            RETURN FALSE
         ENDIF

         initialise values buffer
         RETURN TRUE
**/

let g.nm.load.dataset () = valof
$(
   let position = ?
   g.nm.s!m.nm.file.system :=
      (g.context+m.itemrecord)%1 = '~' -> m.dh.adfs, m.dh.vfs

   g.ut.mov32 (g.context + m.itemaddress, g.nm.s + m.nm.item.address)

   unless g.nm.load.dataset.header (g.context + m.itemaddress) resultis false

   if (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data) then

      $(
         unless g.nm.look.for.subset (m.nm.value.data.type,
                               g.context!m.areal.unit,
                               @position) resultis false
         if position < 0 then
            resultis FALSE

         unless g.nm.load.areal.sub.dataset (position) resultis false
         g.nm.s!m.nm.file.system := m.dh.vfs // all vfs until further notice
         unless g.nm.load.dataset.header (g.nm.s + m.nm.boundary.address)
            resultis false
      $)

   unless g.nm.look.for.subset (m.nm.raster.data.type, g.context!m.resolution,
                                @position) resultis false
   if position < 0 then
      resultis FALSE

   unless g.nm.load.raster.sub.dataset (position) resultis false

   // initialise values buffer since we are now dealing with a new set
   // of record numbers and offsets
   g.nm.init.values.buffer ()

   resultis TRUE
$)


/**
         G.NM.REPLOT - REPLOT A VARIABLE
         -------------------------------

         Regenerates the current variable display and reloads
         the current child overlay.

         INPUTS:

         Pick subset flag
         Initialise flag
         Window flag

         OUTPUTS:

         Returns TRUE if the variable was replotted,
                 FALSE if a suitable areal unit and/or
                           resolution could not be found and
                           an error message was issued

         GLOBALS MODIFIED:

         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         Should only be called when a child overlay
         is active.

         PROGRAM DESIGN LANGUAGE:

         g.nm.replot [pick.subset.flag, init.flag, window.flag]
         -----------                               RETURNS boolean

         make a copy of the current child overlay name
         load child overlay for display

         IF pick.subset.flag is TRUE AND
                        pick initial subset fails THEN
            reload previous child overlay
            RETURN FALSE
         ENDIF

         IF init.flag is TRUE THEN
            initialise display processor
            clear display area
            initialise class colours
            shuffle key
         ELSE
            just initialise number of areas count
         ENDIF

         display variable

         IF window.flag is TRUE THEN
            load child overlay for window
            window variable
         ENDIF

         reload previous child overlay
         reposition videodisc
         RETURN TRUE
**/

and g.nm.replot (pick.subset.flag, init.flag, window.flag) = valof
$(
   let child.name =  vec m.nm.file.name.length / BYTESPERWORD

   // make a copy of the current child overlay name
   g.ut.movebytes (g.nm.s + m.nm.curr.child, 0,
                   child.name, 0,
                   m.nm.file.name.length)

   g.nm.load.child ("cnmDISP")

   if pick.subset.flag & (NOT g.nm.pick.initial.subset ()) then
      $(
         // reload the child overlay that was resident on entry
         // DON'T show underlay map, since error handling of caller
         // will want to load data from disc
         g.nm.load.child (child.name)
         resultis FALSE
      $)

   test init.flag then
      $(
         g.nm.init.display ()

         // clear display area before initialising class colours
         // to prevent weird effects on the screen
         g.sc.clear (m.sd.display)
         g.nm.init.class.colours (g.nm.class.colour)
         g.nm.shuffle.key ()
      $)
   else
      g.nm.s!m.nm.num.areas := 0

   g.nm.display.variable ()

   if window.flag then
      $(
         g.nm.load.child ("cnmWIND")
         g.nm.window.variable ()
      $)

   // reload the child overlay that was resident on entry
   g.nm.load.child (child.name)
   g.nm.position.videodisc ()
   resultis TRUE
$)


/*
      g.nm.restore.areal.vector

         restores the areal vector, re-reading from disc if
         necessary:

         IF areal vector has been cached THEN
            restore it from IO work area
            IF dataset is areal-mappable type AND
               there are more areal values than would fit
                                       into the cache area THEN
                  re-load areal data from disc
*/

and g.nm.restore.areal.vector () be
$(
   if g.ut.restore (g.nm.areal,
                    m.nm.areal.cache.size, m.io.wa.nm.areal) then

      if (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data) &
            (g.nm.s!m.nm.nat.num.areas >
                  (m.nm.areal.cache.size + 1) / m.nm.max.data.size - 1) then

         g.nm.load.areal.data ()
$)


/*
      g.nm.save.screen

         saves the screen to shadow screen RAM so that it can be
         easily restored later

         the menu bar area is not saved

         the RAM workspace is also used by Help and the saved screen
         will be lost if Help is visited
*/

let g.nm.save.screen () be
$(
   // copy main screen to shadow screen using areal vector cache as an
   // intermediate work area
   g.ut.copy.screen (m.io.wa.nm.areal, m.nm.areal.cache.size, m.ut.main)
$)


/*
      g.nm.restore.screen

         restores the screen, either by reading it back from the shadow
         screen RAM or, if Help has prevented this, by restoring the
         message area, replotting the variable and re-windowing, if
         necessary

         if the screen is read from shadow RAM, the menu bar area is
         first cleared
*/

and g.nm.restore.screen (help.visited.flag) be
$(
   test help.visited.flag then
      $(
         // restore message area first so that it is sensible while
         // building the replotted screen
         g.nm.restore.message.area ()

         // replot variable, re-window if it was windowed before
         // and reload calling child overlay
         g.nm.replot (FALSE, FALSE, g.nm.s!m.nm.windowed)
      $)
   else
      $(
         g.sc.clear (m.sd.menu)
         // copy screen back from shadow using same intermediate work area
         g.ut.copy.screen (m.io.wa.nm.areal, m.nm.areal.cache.size,
                           m.ut.shadow)
      $)
$)


/**
         G.NM.ID.GRID.POS - IDENTIFY CURRENT GRID REFERENCE
         --------------------------------------------------

         Identifies the grid reference and square corresponding
         to the current mouse pointer position.

         If the current point is outside the area of interest
         outputs an error message and returns FALSE.

         INPUTS:

         none

         OUTPUTS:

         easting
         northing
         grid square east
         grid square north

         RETURNS TRUE if the current point is within AOI,
                 FALSE if outside

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Only to be called if the mouse pointer is in the
         display area.

         PROGRAM DESIGN LANGUAGE:

         g.nm.id.grid.pos [-> easting, -> northing,
         ----------------  -> grid.sq.e, -> grid.sq.n]
                                    RETURNS boolean

         adjust graphics coords of mouse pointer to a
            pixel boundary
         IF adjusted graphics coords of mouse pointer are
                     outside the effective display window THEN
            write error message
                  "Point is outside area of interest"
            RETURN FALSE
         ELSE
            convert x,y graphics coords into km
            convert x,y graphics coords into grid squares
            convert km to hectametres
            IF Channel Isles or N.Ireland grid system THEN
               set top bit of easting
            ENDIF
            RETURN TRUE
         ENDIF
**/

and g.nm.id.grid.pos (easting.ptr, northing.ptr, grid.sq.e.ptr,
                      grid.sq.n.ptr) = valof
$(
   let   x, y   =  ?, ?
   and   a32    =  vec 1
   and   cons32 =  vec 1

   // adjust graphics coords of mouse pointer to a pixel boundary;
   // truncation on integer division gives the desired result
   x := (g.xpoint / m.nm.x.pixels.to.graphics) * m.nm.x.pixels.to.graphics
   y := (g.ypoint / m.nm.y.pixels.to.graphics) * m.nm.y.pixels.to.graphics

   test (x < g.nm.s!m.nm.x.min) | (x > g.nm.s!m.nm.x.max) |
           (y < g.nm.s!m.nm.y.min) | (y > g.nm.s!m.nm.y.max) then
      $(
        g.sc.ermess ("Point is outside area of interest")
        resultis FALSE
      $)

   else
      $(
         x := muldiv (x - g.nm.s!m.nm.x.min, g.context!m.resolution,
                      g.nm.s!m.nm.x.graph.per.grid.sq) +
                                                g.nm.s!m.nm.km.low.e

         y := muldiv (y - g.nm.s!m.nm.y.min, g.context!m.resolution,
                      g.nm.s!m.nm.y.graph.per.grid.sq) +
                                                g.nm.s!m.nm.km.low.n

         !grid.sq.e.ptr := x / g.context!m.resolution
         !grid.sq.n.ptr := y / g.context!m.resolution

         !easting.ptr := x * 10

         if (g.nm.s!m.nm.grid.system = m.grid.is.NI) |
                        (g.nm.s!m.nm.grid.system = m.grid.is.Channel) then
            !easting.ptr := !easting.ptr | #x8000  // set top bit

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
$)


/**
         G.NM.RUNNING.STATUS - OUTPUT RUNNING STATUS
         -------------------------------------------

         Outputs a running status in a fixed position in
         the message area, consisting of
               numerator / denominator

         Both numbers are assumed to have a maximum field
         width of 5 decimal digits

         INPUTS:

         numerator
         denominator

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.running.status [numerator, denominator]
         -------------------

         clear previous status by blanking in cyan
         output new numerator / denominator
**/

and g.nm.running.status (numerator, denominator) be
$(
   g.sc.movea (m.sd.message, 836, 0)
   g.sc.selcol (m.sd.cyan)
   g.sc.rect (m.sd.plot, 352, 48) // clear previous status
   g.sc.movea (m.sd.message, 836, 36)
   g.sc.selcol (m.sd.blue)
   g.sc.ofstr ("%n/%n", numerator, denominator) // new status
$)

/**
         G.NM.CHECK.DOWNLOAD - CHECK CAN DOWNLOAD FILE
         ---------------------------------------------

         Added for User Data

         INPUTS:

         none

         OUTPUTS:

         returns true if can download

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

**/

and G.nm.check.download() = valof
$( unless G.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data
   $( let s.e, s.n, e.e, e.n, unit = ?, ?, ?, ?, ?
      G.nm.convert.refs.to.km(G.nm.s!m.nm.gr.start.e, G.nm.s!m.nm.gr.start.n,
                              G.nm.s!m.nm.gr.end.e, G.nm.s!m.nm.gr.end.n,
                              @s.e, @s.n, @e.e, @e.n, @unit)
      unit := G.context!m.resolution * 32
      unless (s.e rem unit = 0) & (s.n rem unit = 0) &
             (e.e rem unit = 0) & (e.n rem unit = 0)
      $( G.sc.ermess("Cannot download this item")
         resultis false
      $)
   $)
   resultis true
$)
.
