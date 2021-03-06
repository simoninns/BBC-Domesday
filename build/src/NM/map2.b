//  PUK SOURCE  6.87

/**
         NM.MAP2 - TOP LEVEL OF NATIONAL MAPPABLE OPERATION
         --------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         23.05.86 1        D.R.Freed   Initial version
         04.11.86 2        DRF         Restore message area
                                          handles units string
         ********************************
         30.6.87     2     DNH      CHANGES FOR UNI

         g.nm.to.map
         g.nm.restore.message.area
         g.nm.top.menu
         g.nm.map.to.com
         g.nm.check.compare.options
**/

section "nmmap2"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/nmhd.h"

get "H/nmcphd.h"


/**
         G.NM.TO.MAP - INITIALISE FOR RE-ENTRY TO MAP
         --------------------------------------------

         Initialisation for re-entering top level of mappable
         data from any operation except Compare.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.menu


         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.to.map []
         -----------

         display appropriate message area (Title or Key)
         draw appropriate menu bar (Title/Key, Text/Blank)
**/

let g.nm.to.map () be
$(
   g.nm.restore.message.area ()
   g.nm.top.menu ()
$)


/*
      g.nm.restore.message.area

            restores the message area to its key, title or units display,
            depending on the value of the static in g.nm.s
*/

and g.nm.restore.message.area () be
$(
   test (g.nm.s!m.nm.message.area = m.wkey) then
      g.nm.display.key (TRUE)
   else
      $(
         // NOTE that g.sc.mess cannot be used directly, in case the
         // string contains escape sequences (%c, %n, etc.) which are
         // mis-interpreted
         g.sc.mess ("") // clear message area & fill with background colour
         g.sc.movea (m.sd.message, m.sd.mesXtex, m.sd.mesYtex)
         test g.nm.s!m.nm.message.area = m.wtitle then
            g.sc.oprop (g.context + m.itemrecord)
         else
            g.sc.oprop (g.nm.s + m.nm.primary.units.string)
      $)
$)


/*
      g.nm.top.menu

         draws the top level menu bar for the Mappable data operations;
         the contents depend on whether any text is available and on which
         state the Title/Key toggle is in
*/

and g.nm.top.menu () be
$(
   let nill32 = table -1, -1

   for i = m.box1 to m.box6 do
      g.nm.s!(m.nm.menu + i) := m.sd.act

   if ( g.ut.cmp32 (g.nm.s + m.nm.private.text.address,     nill32) = m.eq &
        g.ut.cmp32 (g.nm.s + m.nm.descriptive.text.address, nill32) = m.eq &
        g.ut.cmp32 (g.nm.s + m.nm.technical.text.address,   nill32) = m.eq )
   then

      g.nm.s!(m.nm.menu + m.box5) := m.wblank


   if (g.nm.s!m.nm.message.area ~= m.wtitle) then
      g.nm.s!(m.nm.menu + m.box6) := m.wtitle

   g.sc.menu (g.nm.s + m.nm.menu)
$)


/**
         G.NM.MAP.TO.COM - MAPPABLE DATA TO COMPARE TRANSITION
         -----------------------------------------------------

         Initialisation for entering compare operation
         from top level of mappable data.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.map.to.com []
         ---------------

         initialise entry mode flag
         initialise linked.display flag
         initialise help.visited flag
         initialise handler pointer
         initialise local menu bar
         check which options should be on menu bar
         draw menu bar
**/

let g.nm.map.to.com () be
$(
   g.nm.s!m.nm.entry.mode := FALSE
   g.nm.s!m.help.visited := FALSE
   g.nm.s!m.linked.display := FALSE
   g.nm.compare.sub.op := 0   // no sub-operation handler yet

   for i = m.box1 to m.box6 do
      g.nm.s!(m.nm.menu + i) := m.sd.act

   g.nm.check.compare.options ()

   g.sc.menu (g.nm.s + m.nm.menu)
$)


/**
         G.NM.CHECK.COMPARE.OPTIONS - CHECK COMPARE OPTIONS
         --------------------------------------------------

         Checks whether the Correlate and Link options should
         be available; sets local menu bar up accordingly,
         but doesn't draw it

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.menu

         PROGRAM DESIGN LANGUAGE:

         g.nm.check.correlate []
         --------------------

         IF all data is missing THEN
            suppress Link option
            suppress Correlate option
         ELSE
            offer Link option
            IF too few areas on display OR
                  dataset type = incidence OR categorised THEN
               suppress Correlate option
            ELSE
               offer Correlate option
            ENDIF
         ENDIF
**/

and g.nm.check.compare.options () be
$(
   test (g.nm.s!m.nm.num.areas = 0) then

      $(
         g.nm.s!(m.nm.menu + m.box3) := m.wblank
         g.nm.s!(m.nm.menu + m.box4) := m.wblank
      $)

   else

      $(
         g.nm.s!(m.nm.menu + m.box3) := m.sd.act

         g.nm.s!(m.nm.menu + m.box4) :=
           (g.nm.s!m.nm.num.areas < m.min.num.correl.points) |
              (g.nm.s!m.nm.value.data.type = m.nm.incidence.type) |
                 (g.nm.s!m.nm.value.data.type = m.nm.categorised.type) ->
                                                         m.wblank, m.sd.act
      $)
$)

.
