//  PUK SOURCE  6.87

/**
         NM.RETR3 - RETRIEVE SUB-OPERATION FOR MAPPABLE DATA
         ---------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmRETR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         21.04.86  1       D.R.Freed   Initial version
         27.10.86  2       DRF         Always use primary units
                                                    string
         ********************************
         3.7.87    3       DNH         CHANGES FOR UNI
         11.08.87  4       SRY         Modified for DataMerge
         ********************************
         09.06.88  5       SA          CHANGES FOR COUNTRYSIDE
            &                          do not mask out grid squares plotted
         13.06.88                      in black. (used by g.nm.total)

         g.nm.sum
         g.nm.value.func
**/

section "nmretr3"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sihd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/nmhd.h"

get "H/nmrehd.h"


/*
      g.nm.sum ()

            handles the sum state of the retrieve operation
*/

let g.nm.sum () be
$(
   let east, north, grid.sq.e, grid.sq.n  =  ?, ?, ?, ?

   g.nm.s!m.nm.mask.black.sqrs := FALSE  //SA 09.06.88

   switchon g.key into
   $( case m.kd.return:
         if g.screen = m.sd.display &
            g.nm.id.grid.pos (@east, @north, @grid.sq.e, @grid.sq.n) then
         $( let entry.state = g.sc.pointer (m.sd.off)
            test g.nm.s!m.flash.colour = m.nm.flash.white
            then $( // no current flashing square
                    mark.square (grid.sq.e, grid.sq.n, m.nm.white)
                    // retrieve value for a single square
                    g.nm.retrieve.values (east, north, east, north)
                 $)
            else test grid.sq.n = g.nm.s!m.flash.sq.n
                 then $( // current square in line with flashing square
                         // mark the row of squares between flashing square and
                         // selected square
                         for i = g.nm.min (grid.sq.e, g.nm.s!m.flash.sq.e) to
                                 g.nm.max (grid.sq.e, g.nm.s!m.flash.sq.e) do
                            mark.square (i, grid.sq.n, m.nm.white)

                         // retrieve values for row of squares
                         g.nm.retrieve.values (
                                   g.nm.min (east, g.nm.s!m.flash.e),
                                   north,
                                   g.nm.max (east, g.nm.s!m.flash.e),
                                   north)
                         g.nm.s!m.flash.colour := m.nm.flash.white
                      $)
                 else $( // current square not in line with flashing square
                         // make flashing square white and sum its value
                         mark.square (g.nm.s!m.flash.sq.e, g.nm.s!m.flash.sq.n,
                                      m.nm.white)
                         g.nm.retrieve.values (g.nm.s!m.flash.e,
                                               g.nm.s!m.flash.n,
                                               g.nm.s!m.flash.e,
                                               g.nm.s!m.flash.n)
                         g.nm.s!m.flash.colour := m.nm.flash.white
                      $)

            display.sum ()
            g.nm.position.videodisc ()
            g.sc.pointer (entry.state)
         $)
      endcase

      case m.kd.tab:
         if (g.screen = m.sd.display) &
            g.nm.id.grid.pos (@east, @north, @grid.sq.e, @grid.sq.n) then
         $( // restore any existing flashing square and set new one
            let entry.state = g.sc.pointer (m.sd.off)

            if g.nm.s!m.flash.colour ~= m.nm.flash.white then
               mark.square (g.nm.s!m.flash.sq.e, g.nm.s!m.flash.sq.n,
                            g.nm.s!m.flash.colour)
            // set up information about new flashing square
            g.nm.s!m.flash.e := east
            g.nm.s!m.flash.n := north
            g.nm.s!m.flash.sq.e := grid.sq.e
            g.nm.s!m.flash.sq.n := grid.sq.n
            // save colour of square before marking
            g.sc.movea (m.sd.display, g.xpoint, g.ypoint)
            g.nm.s!m.flash.colour := g.sc.pixcol ()
            mark.square (grid.sq.e, grid.sq.n, m.nm.flash.white)
            g.sc.pointer (entry.state)
         $)
      endcase

      case m.kd.fkey5:   // Grid Ref function
         change.to.nomark.state (m.wgridref, m.wsum)
      endcase

      case m.kd.fkey6:
         if g.nm.check.download() g.nm.to.write (m.wsum, m.sd.act)
      endcase
   $)
$)


/*
      g.nm.value.func ()

            handles the values state of the retrieve operation
*/

and g.nm.value.func () be
$(
   g.nm.s!m.nm.mask.black.sqrs := FALSE  //SA 13.06.88

   switchon g.key into
   $( case m.kd.return:
      $( let east, north, grid.sq.e, grid.sq.n  =  ?, ?, ?, ?
         if (g.screen = m.sd.display) &
            g.nm.id.grid.pos (@east, @north, @grid.sq.e, @grid.sq.n)
         $( let entry.state = g.sc.pointer (m.sd.off)
            mark.square (grid.sq.e, grid.sq.n, m.nm.white)

            // initialise sum to get value of single square and
            // initialise missing flag
            g.ut.set48 (0,0,0, g.nm.s + m.sum.total)
            g.nm.s!m.missing := TRUE

            g.nm.retrieve.values (east, north, east, north)

            test g.nm.s!m.missing
            then g.sc.mess ("Missing data")
            else display.sum ()

            g.nm.position.videodisc ()
            g.sc.pointer (entry.state)
         $)
      $)
      endcase

      case m.kd.fkey5:  // Unit or Grid Ref function
         change.to.nomark.state (g.nm.s!(m.nm.menu + m.box5), m.wvalues)
      endcase

      case m.kd.fkey6:
         if g.nm.check.download() g.nm.to.write (m.wvalues, m.sd.act)
      endcase
   $)
$)


/*
      change.to.nomark.state

         changes the state of the local state machine for
         the Retrieve operation from a marking state to a
         non-marking state and performs the associated housekeeping
*/

and change.to.nomark.state (new.state, box3) be
$( test g.nm.s!m.restore
   then $( g.nm.restore.screen (NOT g.nm.s!m.saved)
           g.nm.s!m.restore := FALSE
        $)
   else g.nm.restore.message.area ()

   g.nm.s!m.local.state := new.state
   g.nm.s!(m.nm.menu + m.box3) := box3
   g.nm.s!(m.nm.menu + m.box5) := m.wClear
   g.sc.menu (g.nm.s + m.nm.menu)
$)


/*
      mark.square

         plots a single grid square at the given reference in the
         specified colour

         if the screen has not already been saved, then saves it
         here before marking the square
*/

and mark.square (grid.sq.e, grid.sq.n, colour) be
$(
   if NOT g.nm.s!m.saved & NOT g.nm.s!m.restore then
      $(
         g.nm.save.screen ()
         g.nm.s!m.saved := TRUE
      $)

   // temporarily set graphics window to ensure
   // that marker square doesn't overflow outside plot area
   g.nm.set.plot.window ()

   g.sc.selcol (colour)
   g.nm.plot.block (grid.sq.e, grid.sq.n, 1)

   // restore graphics window to its default setting
   g.nm.unset.plot.window ()

   g.nm.s!m.restore := TRUE   // there is now something to restore
$)


/*
      display.sum

         displays the sum total in the message area, followed by as
         much of the units string as will fit on the line
*/

and display.sum () be
$( let units.string = g.nm.s + m.nm.primary.units.string
   let length = units.string%0   // save real length
   g.sc.mess ("") // clear message area & fill with background colour
   g.sc.movea (m.sd.message, m.sd.mesXtex, m.sd.mesYtex)

   // display number and truncate string so that it fits
   units.string%0 :=
      g.nm.min (length, (m.sd.charsperline -
            g.nm.mpdisp (g.nm.s + m.sum.total,
                         g.nm.dual.data.type (
                                       g.nm.s!m.nm.value.data.type) ->
                           g.nm.s!m.nm.secondary.norm.factor,
                              g.nm.s!m.nm.primary.norm.factor) ) )
   g.sc.oprop (units.string)
   units.string%0 := length   // restore real length
$)
.
