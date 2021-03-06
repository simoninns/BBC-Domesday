//  UNI SOURCE  4.87

section "cm1"

/**
         CM.B.CM1 - Initialisation Routines for Map Overlay
         --------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         5.3.86   1        DNH         Initial version
                                       expanded from b.cm2
         10.3.86  2        DNH         Cache and Restore
         25.3.86  3        DNH         Disc side detect;
                                       New grid ref. primitives
         18.4.86  4        DNH         g.dy.init & free moved
                                       Debug ermesses in
          9.5.86  5        DNH         Entry from CF,CT,CP fix
          6.6.86  6                    Don't show map on return
                                          from Options
          1.7.86  7                    Fixes to mapini2
         30.7.86  8                    Always show frame in ini2
         26.8.86  9        DNH         Bugfix gotogridref
****************************************************************
         4.3.87   10       DNH         Bugfix gotogridref OR L30

         GLOBALS DEFINED:
         g.cm.grid.system
         g.cm.mapini
         g.cm.mapini2
         g.cm.mapini.special
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/sdhd.h"
get "H/dhhd.h"
get "H/vhhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"
get "H/cm3hd.h"
get "H/grhd.h"


/**
         procedure gotogridref (target level) tries to get to the
         grid reference in g.context at the specified target
         level by recursing down (zooming in) as necessary.
         The calls to 'down' are made after frigging g.xpoint and
         g.ypoint to indicate the required submap.
         Graphics and display of intermediate maps is disabled
         during this.
         Note that it will NOT cross level 1 boundaries. It only
         goes downwards (zoom in).  An ancestor map must
         have been read in before this routine is called.  When
         entering from Photo/Text 'gotomap' will always have been
         called first to set up the ancestor. However entering
         from 'Find' directly in a 'go to place' or 'go to grid
         ref' can land us anywhere so the appropriate L1 map must
         have been read in and set up by 'mapini.special' before
         gotogridref is called.
**/

let gotogridref (target.level) be      // go to global GR, as near to target
$(                                     // level as possible.
   let gre = g.ut.grid.trim (g.context!m.grbleast)
   let grn = g.ut.grid.trim (g.context!m.grblnorth)

   $( let last.level = g.cm.s!m.cmlevel
      let x, y = gre - g.cm.s!m.x0, grn - g.cm.s!m.y0  // residual hectometres

// new code to ensure that we zoom in to the map containing the grid ref's
// in gre, grn.  Due to rounding errors in calculations of map height in
// pixels given the screen stretch factor of 12/13.  See also the mod to
// g.cm.otherpars elsewhere.

      switchon last.level into
      $(
         case 1:
            x, y := x/100 * 100 + 10, y/100 * 100 + 10
            endcase
         case 2:
            x, y := x/10  *  10 +  1, y/10  *  10 +  1
            endcase
         case 4:
            x, y := x*10, y*10         // decametres for L4
            endcase
      $)

      g.xpoint := g.cm.a.of (x)        // DON'T add one !!
      g.ypoint := g.cm.b.of (y)

      g.cm.down (m.cm.no.bit)
      if g.cm.s!m.cmlevel = target.level |
         g.cm.s!m.cmlevel = last.level  return   // at target or limit
   $) repeat
$)


/**
         procedure gotomap (frame number, map record number, map
         level) tries to go to the map given as frame number
         given the nearest map record number.  For level 1 and 2
         maps these will always be the same.  For some L3 maps
         they will be the same.  For the remaining L3 maps and
         all L4, L5 maps the L2 ancestor map record is read in
         and the correct target map found by calling
         'gotogridref'.
         Note that g.context grid ref entries must be left
         unchanged for them to be valid in 'gotogridref'.
**/

and gotomap (frame, map.record, mlevel) be
$(
   g.cm.s!m.map := map.record
   g.cm.s!m.recptr := g.cm.findmaprec (map.record)
   g.cm.mapinfo()

   if mlevel > g.cm.s!m.cmlevel do  gotogridref (mlevel)
$)


/**
         function g.cm.grid.system (easting, northing) returns
         the grid reference system indicated by the pattern of
         top bits of the Domesday format easting and northing
         parameters. The returned manifest is declared in cm3hdr.
         It uses the utility routine g.ut.grid.region to
         determine the region that the grid ref is in and then
         interprets this as a grid system.
**/

and g.cm.grid.system (e, n) = valof
$(
   let region = g.ut.grid.region (e, n)
   switchon region into
   $(
      case m.grid.is.channel:
      case m.grid.is.NI:
      case m.grid.invalid:
         resultis region
      default:
         resultis m.grid.is.GB
   $)
$)


/**
         procedure g.cm.mapini () is the main initialiser for Map
         from Photo and Text by menu bar selection.
         The current map can have changed since Map was last
         exited, for example if Photo is entering Map with a new
         item that is on a different (smaller) map.
**/

and g.cm.mapini () be
$(                      // we have come from Photo or Text
   $<DEBUG
   g.cm.debugmess ("g.cm.mapini: %N %N %N", g.context!m.frame.no,
                                          g.context!m.maprecord,
                                          g.context!m.leveltype)
   $>DEBUG
   g.sc.pointer (m.sd.off)
   g.sc.clear (m.sd.message)
   g.sc.clear (m.sd.display)
   g.cm.s!m.clear.is.pending := false        // screen is clear now
   g.cm.s!m.substate := m.mapwalk.substate

   test g.context!m.map.no = g.cm.s!m.frame |
        g.context!m.map.no = L0.no.highlight then
      g.cm.s!m.frame := 0     // we are back on our current map, just ensure
                              // that it gets redisplayed
   else
   $(                // a new item has been selected.  Find the map.
      gotomap (g.context!m.map.no, g.context!m.maprecord,
                                                      g.context!m.leveltype)
      g.cm.s!m.frame := 0
   $)
$)


/**
         procedure g.cm.mapini2 () is the initialisation routine
         for Find menu bar transition and return from Map
         Options. If Map is entered from one of these then the
         map information cannot be out of step with the current
         map - ie. no further initialisation is needed.  This is
         even the case if map walking has taken place in the grid
         ref or options substates.  The map level cannot have
         changed at all.
         In all cases we redisplay the current map (the flicker
         bug is fixed now) and icons are shown.  This is actually
         done by the mapwalk action routine, in response to the
         static frame number being zero when g.redraw is true.
         In cases other than Key the frame won't actually have
         changed, but after a Find MBT the video will be blanked:
         this also unmutes it.
**/

and g.cm.mapini2 () be
$(
   $<DEBUG
   g.cm.debugmess ("In g.cm.mapini2")
   if g.context!m.leveltype ~= g.cm.s!m.cmlevel do
      g.cm.collapse ("Bad leveltype %N (%N) in mapini2",
                                       g.context!m.leveltype, g.cm.s!m.cmlevel)
   $>DEBUG

   g.sc.pointer (m.sd.off)
   g.sc.clear (m.sd.message)
   g.sc.clear (m.sd.display)
   g.cm.s!m.clear.is.pending := false              // no icons on show now
   g.cm.s!m.frame := 0                             // ensures frame shown
   g.cm.s!m.substate := m.mapwalk.substate
$)


/**
         procedure mapini.special () is the initialisation
         routine called by g.cm.mapwal when it detects a pending
         state transition.  This may have been from Find or
         System Startup.
         If the grid reference in g.context is invalid then it is
         a system startup and Map is entered at top level with
         the level 0 map.  Otherwise the system attempts to go to
         the map and grid references specified by Find.
**/

and g.cm.mapini.special () be
$(
   let find.request.type = g.context!m.leveltype   // go to place or grid ref
   let old.grid.system = g.cm.s!m.grid.system

   $<DEBUG
   g.cm.debugmess ("In g.cm.mapini.special")
   $>DEBUG

   g.sc.pointer (m.sd.off)
   g.sc.clear (m.sd.message)
   g.sc.clear (m.sd.display)
   g.sc.clear (m.sd.menu)
   g.cm.s!m.clear.is.pending := false        // screen is clear now
   g.cm.s!m.substate := m.mapwalk.substate
   g.cm.s!m.grid.system := g.cm.grid.system (g.context!m.grbleast,
                                                      g.context!m.grblnorth)
   if g.cm.s!m.grid.system = m.grid.invalid do
   $( let str = ?
      g.cm.s!m.map := map.L0              // reinitialise to L0
      g.cm.s!m.frame := 0                 // init to invalid; ensures shown
      g.cm.s!m.measure!m.v.units := m.metric    // metric as default
      g.cm.s!m.recptr := g.cm.findmaprec (g.cm.s!m.map)
      g.cm.mapinfo ()
      str := (g.context!m.discid = m.dh.south) -> "Sou", "Nor"
      g.sc.mess ("*S*S*S*S*SCommunity Disc - %Sthern Side", str)
         // banner message.
         // don't show the map. Wait for 'highlight L0
      return
   $)

                       // use values from interface with Find
   $(                         // load in level 1 map for this region
      let map = valof switchon g.ut.grid.region (g.context!m.grbleast,
                                                g.context!m.grblnorth) into
      $(
         case m.grid.is.NI:      resultis L0.ire
         case m.grid.is.Channel: resultis L0.chan
         case m.grid.is.South:   resultis L0.south
         case m.grid.is.Domesday.wall:
            resultis (g.context!m.discid = m.dh.south) -> L0.south, L0.north
         case m.grid.is.North:   resultis L0.north
         case m.grid.is.Shet:    resultis L0.shet
         case m.grid.is.IOM:     resultis L0.man
      $)
      g.cm.s!m.map := map + map.L1 - map.L0    // add in offset from L0 maps
   $)
   g.cm.s!m.frame := 0
   g.cm.s!m.recptr := g.cm.findmaprec (g.cm.s!m.map)
   g.cm.mapinfo ()
   gotogridref (3)            // try to get to level 3 for GR in g.context

   $(
            // (note that these are residuals)
      let x0 = g.ut.grid.trim (g.context!m.grbleast) - g.cm.s!m.x0
      let y0 = g.ut.grid.trim (g.context!m.grblnorth) - g.cm.s!m.y0

      let a0 = g.cm.a.of (x0)       // screen position of grid ref
      let b0 = g.cm.b.of (y0)

      $<DEBUG
      unless 0 <= a0 < m.sd.disw &
             0 <= b0 < m.sd.dish do
         g.cm.collapse ("Grid ref outside L1 maps: %N %N",
                                 g.context!m.grbleast, g.context!m.grblnorth)

      g.cm.sel.fs (m.dh.vfs)
      $>DEBUG

      test find.request.type = 2 then     // go to Place and highlight
      $(
         let a1 = g.cm.a.of (x0 + 10)        // 10 hm square
         let b1 = g.cm.b.of (y0 + 10)
         if within.one.pixel (a0, b0, a1, b1) do      // too small to see !!
         $( a1 := g.cm.a.of (x0 + 100)       // 100 hm square
            b1 := g.cm.b.of (y0 + 100)
         $)
         g.vh.video (m.vh.lv.only)     // no micro output while setting up
         g.sc.selcol (m.sd.blue)
         g.sc.movea (m.sd.display, a0, b0)
         g.sc.rect (m.sd.plot, a1-a0, b1-b0)
         g.cm.showmap (m.cm.frame.bit)       // only show the video frame
         g.vh.video (m.vh.highlight)         // enable micro output
         g.ut.wait (300)                     // 3 second wait
         g.sc.movea (m.sd.display, a0, b0)
         g.sc.rect (m.sd.clear, a1-a0, b1-b0)
         g.vh.video (m.vh.superimpose)       // back to normal
         g.cm.showmap (m.cm.icons.bit)       // show icons, if there are any
      $)
      else              // go to Grid Ref and show Yellow Cross
      $(
         g.sc.movea (m.sd.display, a0, b0)
         g.sc.icon (m.sd.cross2, m.sd.plot)     // yellow cross
         g.cm.showmap (m.cm.frame.bit | m.cm.icons.bit)
         g.cm.s!m.clear.is.pending := true      // ensure cross cleared later
      $)
   $)
$)


/**
         function within.one.pixel (x1, y1, x2, y2) returns a
         boolean according to whether the two points specified
         are within one pixel of each other.  This is dependent
         on 4 graphics units per pixel in each direction.
**/

and within.one.pixel (x1, y1, x2, y2) =
   abs (x2-x1) <= 4 & abs (y2-y1) <= 4          // 4 graphics units = 1 pixel
.
