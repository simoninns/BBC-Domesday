//  PUK SOURCE  6.87

/**
         NM.DETAIL1 - DETAIL OPERATION FOR MAPPABLE DATA
         -----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmDETL

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         03.06.86 1        D.R.Freed   Initial version
         16.10.86 2        DRF         Optimised & split into
                                       DETAIL1 & DETAIL2
         21.08.87 3        SRY         Added toggle video mode

         g.nm.to.res
         g.nm.resolution
**/

section "nmdetail1"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/kdhd.h"
get "H/nmhd.h"

manifest
$(
   m.char.width = m.sd.disw / m.sd.charsperline

   // offsets into general purpose static area
   m.list.start      = m.nm.gen.purp
   m.list.end        = m.nm.gen.purp + 1
   m.new.resolution  = m.nm.gen.purp + 2
   m.new.res.pos     = m.nm.gen.purp + 3
   m.current.res.pos = m.nm.gen.purp + 4
   m.num.entries     = m.nm.gen.purp + 5
   m.res.table       = m.nm.gen.purp + 6  // maximum of 10 entries
$)


/**
         G.NM.TO.RES - TRANSITION TO RESOLUTION SUB-OPERATION
         ----------------------------------------------------

         Initialisation routine for transition to resolution
         operation, from anywhere

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.to.res []
         -----------

         display menu bar with Replot suppressed
         set up table of available resolutions
         display table in message area
         initialise new.resolution, list.start, list.end statics
         reposition videodisc for underlay map
**/

let g.nm.to.res () be
$(
   let string, xpos = ?, ?
   let key, rec.num, offset = ?, ?, ?

   let entry.state = g.sc.pointer (m.sd.off)

   // display menu bar which may have Areas option suppressed;
   // Replot should be suppressed until a new resolution is selected
   g.nm.s!(m.nm.menu + m.box3) := m.wblank
   g.nm.s!(m.nm.menu + m.box4) :=
      (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data) ->
                                                m.sd.act, m.wblank
   g.sc.menu (g.nm.s + m.nm.menu)

   string := (g.nm.s!m.nm.dataset.type = m.nm.areal.mappable.data) ->
                     "Raster size: ", "Grids available:"
   g.sc.mess (string)
   g.nm.s!m.list.start := m.sd.mesXtex + g.sc.width (string)

   xpos := g.nm.s!m.list.start
   g.nm.s!m.num.entries := 0

   for pos = 0 to g.nm.num.of.subsets (m.nm.raster.data.type) - 1 do

      $(
         g.nm.find.subset (m.nm.raster.data.type, pos,
                           @key, @rec.num, @offset)

         if g.nm.res.usable (key) then
            $(
               g.nm.s!(m.res.table + g.nm.s!m.num.entries) := key
               g.nm.s!m.num.entries := g.nm.s!m.num.entries + 1

               // m.nm.flash.white has red assigned whilst in Detail
               test key = g.context!m.resolution then
                  $(
                     display.res (key, m.nm.flash.white, xpos)
                     g.nm.s!m.current.res.pos := xpos
                  $)
               else
                  display.res (key, m.sd.blue, xpos)

               xpos := xpos + m.char.width * 2
            $)
      $)

   g.sc.selcol (m.sd.blue)
   g.sc.oprop ("km")

   g.nm.s!m.list.end := xpos
   g.nm.s!m.new.resolution := g.context!m.resolution

   g.nm.position.videodisc ()
   g.sc.pointer (entry.state)
$)


/*
      display.res

         displays the given resolution key in the message area using
         the specified colour at the specified x position
*/

and display.res (key, colour, xpos) be
$(
   let string = vec 1

   g.sc.selcol (colour)

   g.sc.movea (m.sd.message, xpos, m.sd.mesYtex)

   test key = 10 then
         g.sc.oprop ("10 ") // always last entry
   else
      $(
         string%0 := 2
         string%1 := key + '0'
         string%2 := ' '
         g.sc.oprop (string)
      $)
$)


/**
         G.NM.RESOLUTION - ACTION ROUTINE FOR RESOLUTION
         -----------------------------------------------

         Action routine for resolution sub-operation.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.key
         g.context!m.resolution
         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.resolution []
         ---------------

         IF key = RETURN AND pointer is over an alternative
                                             resolution THEN
            new.resolution = resolution under pointer
            rewrite any previously selected resolution in blue
            rewrite new resolution in yellow
            put Replot on menu bar, if necessary
            set key to no action
         ENDIF

         IF key = Replot function key THEN
            highlight new resolution in red
            current resolution = new.resolution
            suppress Replot from menu bar
            replot variable
         ENDIF
**/

and g.nm.resolution () be
$(
   switchon g.key into
   $(
      case m.kd.tab:
         g.nm.toggle.video.mode()
      endcase

      case m.kd.return:
         if g.screen = m.sd.message &
            g.nm.s!m.list.start <= g.xpoint < g.nm.s!m.list.end
         $( let table.pos =
               (g.xpoint - g.nm.s!m.list.start) / (m.char.width * 2)
            let res = g.nm.s!(m.res.table + table.pos)
            if res ~= g.context!m.resolution then
            $( if g.nm.s!m.new.resolution ~= g.context!m.resolution
                  display.res (g.nm.s!m.new.resolution,
                               m.sd.blue, g.nm.s!m.new.res.pos)

               g.nm.s!m.new.resolution := res
               g.nm.s!m.new.res.pos :=
                     g.nm.s!m.list.start + table.pos * m.char.width * 2
               display.res (g.nm.s!m.new.resolution,
                            m.sd.yellow, g.nm.s!m.new.res.pos)
               if g.nm.s!(m.nm.menu + m.box3) = m.wblank then
               $( g.nm.s!(m.nm.menu + m.box3) := m.sd.act
                  g.sc.menu (g.nm.s + m.nm.menu)
               $)
               g.key := m.kd.noact
            $)
         $)
      endcase

      case m.kd.fkey3:
         // move highlight from old current resolution to new one
         display.res (g.context!m.resolution, m.sd.blue,
                      g.nm.s!m.current.res.pos)
         display.res (g.nm.s!m.new.resolution, m.nm.flash.white,
                      g.nm.s!m.new.res.pos)

         g.context!m.resolution := g.nm.s!m.new.resolution
         g.nm.s!m.current.res.pos := g.nm.s!m.new.res.pos

         // suppress Replot until another selection
         g.nm.s!(m.nm.menu + m.box3) := m.wblank
         g.sc.menu (g.nm.s + m.nm.menu)

         // initialise display processor, replot variable
         // and reload this child overlay
         g.nm.replot (FALSE, TRUE, FALSE)
      endcase
   $)
$)
.
