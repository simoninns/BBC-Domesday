//  PUK SOURCE  6.87

/**
         NM.AUTO4 - AUTOMATIC CLASSING OPERATN FOR MAPPABLE DATA
         -------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmAUTO

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         21.03.86 1        D.R.Freed   Initial version
         ********************************
          3.07.87 2        DNH         CHANGES FOR UNI
         21.08.87 3        SRY         Added toggle video mode
          3.09.87 4        SRY         Added Local/National

         g.nm.auto.opt
         g.nm.check.summary.data
         g.nm.auto.ermess
         g.nm.nested.colours
**/

section "nmauto4"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sihd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/nmhd.h"
get "H/nmclhd.h"


/**
         G.NM.AUTO.OPT - ACTION ROUTINE FOR AUTOMATIC CLASSING
         -----------------------------------------------------

         Action routine for all automatic classing methods.
         Handles the Replot function.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.auto.opt []
         -------------

         IF Replot key has been pressed THEN
            suppress Replot on menu bar
            stop key border flashing
            replot variable
            resave class intervals
            resave palette
         ENDIF
**/

let g.nm.auto.opt () be
$(
   let box = ?
   let menu = g.nm.s+m.nm.menu

   if valof switchon g.key into
      $(
         CASE m.kd.fkey3 : box := m.box3
                           resultis (g.nm.s!m.nm.gen.purp = m.wequal)
         CASE m.kd.fkey4 : box := m.box4
                           resultis (g.nm.s!m.nm.gen.purp = m.wnested)
         CASE m.kd.fkey5 : box := m.box5
                           resultis (g.nm.s!m.nm.gen.purp = m.wquantiles)

         CASE m.kd.fkey6 :    // local/national
            test g.nm.s!m.nm.scope = m.wNational // ie Local on menu bar
            then g.nm.s!m.nm.scope := m.wlocal
            else g.nm.s!m.nm.scope := m.wnational
            resultis false
         ENDCASE

         CASE m.kd.tab   : g.nm.toggle.video.mode()

         DEFAULT         : resultis FALSE
      $) then
            $(
               // suppress Replot from menu bar
               menu!box := m.wblank
               g.sc.menu (menu)

               // stop border flashing
               g.nm.s!m.nm.intervals.changed := FALSE
               g.nm.display.key (TRUE)

               g.nm.replot (FALSE, FALSE, FALSE)

               // resave class intervals and palette now that
               // they have been made permanent
               MOVE (g.nm.class.upb, g.nm.s + m.plotted.upb,
                     (m.nm.num.of.class.intervals + 1) * m.nm.max.data.size)

               for i = 1 to m.nm.num.of.class.intervals do
                  g.nm.s!(m.plotted.palette + i - 1) :=
                           g.sc.physical.colour (g.nm.class.colour!i)
            $)

   test g.nm.s!m.nm.scope = m.wNational
   then unless menu!m.box6 = m.wLocal
        $( for i = m.box1 to m.box5 menu!i := m.sd.act
           menu!m.box6 := m.wLocal
           g.sc.menu(menu)
        $)
   else unless menu!m.box6 = m.wNational
        $( for i = m.box1 to m.box5 menu!i := m.sd.act
           menu!m.box6 := m.wNational
           g.sc.menu(menu)
        $)
$)


/*
      g.nm.check.summary.data

         checks the class intervals for National scope, which have been
         extracted from the summary data in the sub-dataset header

         vec.ptr is the address of the cut-points in the header; the
         first (artificial) cut-point is the missing value (NA box)
         so is ignored

         num.values gives the number of cut-points to be checked and
         should not include the last (artificial) cut-point, which is
         maximum positive ( > box)

         issues an error message if ALL the values are "missing"
*/

and g.nm.check.summary.data (vec.ptr, num.values) = valof
$(
   let missing32 = vec 1
   let ok = FALSE

   g.ut.set32 (0, m.nm.max.neg.high, missing32)

   for i = 1 to num.values do
      if g.ut.cmp32 (vec.ptr + i * m.nm.max.data.size, missing32) ~= m.eq then
         ok := TRUE

   if NOT ok then
      g.nm.auto.ermess ("Not available for this dataset")

   resultis ok
$)


/*
      g.nm.auto.ermess

         issues an error message for automatic classing, but doesn't
         restore the message area, since it is always immediately
         replaced by the key; in all other respects this routie should
         behave exactly like g.sc.ermess
*/

and g.nm.auto.ermess (string.ptr) be
$(
   g.sc.beep ()
   g.sc.mess (string.ptr)
   g.ut.wait (m.sd.errdelay)
$)


/*
      g.nm.nested.colours

         sets up the palette for a nested means key, which only has 3
         class intervals
*/

and g.nm.nested.colours () be
$(
   g.sc.palette (g.nm.class.colour!1, m.sd.cyan2)
   g.sc.palette (g.nm.class.colour!2, m.sd.green2)
   g.sc.palette (g.nm.class.colour!3, m.sd.green2)
   g.sc.palette (g.nm.class.colour!4, m.sd.yellow2)
   g.sc.palette (g.nm.class.colour!5, m.sd.red2)
$)

.
