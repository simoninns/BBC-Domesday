//  PUK SOURCE  6.87


/**
         NM.COMPARE2 - COMPARE OPERATION FOR MAPPABLE DATA
         -------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         16.06.86 1        D.R.Freed   Initial version
         30.09.87 2        SRY         Shuffle menu bar options right

         g.nm.to.link.ini
         g.nm.to.correl.ini
         g.nm.to.name.ini
**/

section "nmcomp2"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sihd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/nmhd.h"

get "H/nmcphd.h"


/**
         G.NM.TO.LINK.INI - TRANSITION INTO LINK SUB-OPERATION
         -----------------------------------------------------

         Initialisation routine for the transition into the
         link operation from anywhere within compare.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.key
         g.nm.compare.sub.op
         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.to.link.ini []
         ----------------

         turn off mouse pointer
         suppress Link option on menu bar
         load child overlay "cnmLINK"
         reposition videodisc for underlay
         output prompt
         enable text entry mode and restore pointer
         set sub-operation handler to link handler
**/

let g.nm.to.link.ini () be
$(
   let entry.state = ?

   // turn off mouse pointer so that it can't be moved around during
   // the preparation for enabling entry mode, which does a vertical
   // kick up
   entry.state := g.sc.pointer (m.sd.off)

   g.nm.s!(m.nm.menu + m.box4) := m.wblank
   g.sc.menu (g.nm.s + m.nm.menu)

   g.nm.load.child ("cnmLINK")
   g.nm.position.videodisc ()

   enable.entry.mode (entry.state)
   g.nm.compare.sub.op := g.nm.link.handler
$)


/**
         G.NM.TO.CORREL.INI - TRANSITION INTO CORRELATE SUB-OP
         -----------------------------------------------------

         Initialisation routine for the transition into the
         correlate sub-operation from anywhere within compare.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.key
         g.nm.compare.sub.op
         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.to.correl.ini []
         ------------------

         IF enough memory to correlate no. of values in AOI THEN
            turn off mouse pointer
            suppress Correlate option on menu bar
            load child overlay "cnmCORR"
            reposition videodisc for underlay
            IF too many values to use the fast method THEN
               output warning message that slow method
                  will be used
            ENDIF
            output prompt
            enable text entry mode and restore pointer
            set sub-operation handler to correlate handler
         ELSE
            output error message
         ENDIF
**/

and g.nm.to.correl.ini () be
$(
   let entry.state, num.values = ?, ?

   // calculate the number of values within the area of interest;
   // it is important to include missing data values since these
   // affect the ranking procedure; for areal data, the count made
   // during the display will include missing values
   num.values :=
      (g.nm.s!m.nm.dataset.type = m.nm.grid.mappable.data) ->
          ((g.nm.s!m.nm.grid.sq.top.e - g.nm.s!m.nm.grid.sq.low.e) *
           (g.nm.s!m.nm.grid.sq.top.n - g.nm.s!m.nm.grid.sq.low.n)),
          g.nm.s!m.nm.num.areas

   // check that there is enough memory to unpack all the values (including
   // missing ones) in the area of interest - note that 1 more area can be
   // correlated than m.nm.max.num.areas, since element 0 of the areal vector
   // is available; when loading areal values into the vector, element 0 is
   // reserved for "missing data" value

   test num.values > (m.nm.max.num.areas + 1) then
         g.sc.ermess ("Too much detail to correlate")
   else
      $(
         // turn off mouse pointer so that it can't be moved around during
         // the preparation for enabling entry mode, which does a vertical
         // kick up
         entry.state := g.sc.pointer (m.sd.off)

         g.nm.s!(m.nm.menu + m.box5) := m.wblank
         g.sc.menu (g.nm.s + m.nm.menu)

         g.nm.load.child ("cnmCORR")
         g.nm.position.videodisc ()

         if num.values > m.max.num.fast.correl.points then
            $( // avoid using g.sc.ermess, because we don't want old
               // message area restored
               g.sc.beep ()
               g.sc.mess ("%n pts. - correlate will be very slow",
                          num.values)
               g.ut.wait (m.sd.errdelay)
            $)

         enable.entry.mode (entry.state)
         g.nm.compare.sub.op := g.nm.correlate.handler
      $)
$)


/**
         G.NM.TO.NAME.INI - TRANSITION INTO NAME SUB-OPERATION
         -----------------------------------------------------

         Initialisation routine for the transition into the
         name operation from anywhere within compare.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.key
         g.nm.compare.sub.op
         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.to.name.ini []
         ----------------

         turn off mouse pointer
         suppress Name option on menu bar
         load child overlay "cnmLINK"
         reposition videodisc for underlay
         output prompt
         enable text entry mode and restore pointer
         set sub-operation handler to name handler
**/

and g.nm.to.name.ini () be
$(
   let entry.state = ?

   // turn off mouse pointer so that it can't be moved around during
   // the preparation for enabling entry mode, which does a vertical
   // kick up
   entry.state := g.sc.pointer (m.sd.off)

   g.nm.s!(m.nm.menu + m.box6) := m.wblank
   g.sc.menu (g.nm.s + m.nm.menu)

   g.nm.load.child ("cnmLINK")
   g.nm.position.videodisc ()

   enable.entry.mode (entry.state)
   g.nm.compare.sub.op := g.nm.name.handler
$)


/*
      enable.entry.mode

         enables entry mode by putting up a prompt,
         putting the text cursor after it and
         initialising the item name string

         if the mouse pointer is in the menu bar area,
         it is kicked up out of it, to ensure that
         RETURN will close entry mode, rather than generating
         a function key press

         the mouse pointer is then restored to entry.state
*/

and enable.entry.mode (entry.state) be
$(
   let prompt = "Name:"

   g.sc.mess (prompt)

   if g.screen = m.sd.menu then
      g.sc.moveptr (g.xpoint, g.sc.dtob (m.sd.display, 4))

   g.sc.movea (m.sd.message,
               m.sd.mesXtex + g.sc.width (prompt), m.sd.mesYtex)

   g.key := m.kd.noact
   g.nm.s!m.itemname := 0
   g.sc.input (g.nm.s + m.itemname, m.sd.blue, m.sd.cyan, m.namelength)

   g.sc.pointer (entry.state)

   g.nm.s!m.nm.entry.mode := TRUE
$)

.

