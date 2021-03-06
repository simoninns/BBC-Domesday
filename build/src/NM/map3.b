//  PUK SOURCE  6.87

/**
         NM.MAP3 - NATIONAL MAPPABLE INITIALISATION
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         01.08.86 1        D.R.Freed   Initial version
         20.02.86 2        DRF         Created from MAP1
                                          to compile
         ********************************
         30.6.87     3     DNH      CHANGES FOR UNI
         1.10.87     4     SRY      No exit after illegal area

         g.nm.map.ini
         g.nm.toggle.video.mode
         g.nm.goto.text
         g.nm.return.from.text
**/

section "nmmap3"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sthd.h"
get "H/vhhd.h"
get "H/sdhd.h"
get "H/nmhd.h"
get "H/nmcohd.h"


/*
      g.nm.map.ini

         initialisation for the National Mappable operation;
         includes display of the current variable

         returns TRUE if initialisation was completed successfully,
                 FALSE if a forced area state change has been set up OR
                       if a Main has been forced
*/

let g.nm.map.ini () = valof
$(
   // if area of interest is undefined, force area operation

   if ( ((g.context!m.grbleast & #X8000) = 0) &
        ((g.context!m.grblnorth & #X8000) = #X8000) ) then

      $(
         g.key := - m.st.area   // pending state change
         resultis FALSE
      $)


   // initialise statics

   g.nm.s!m.nm.overlay.mode :=
      (g.context!m.underlay.frame.no = 0) ->
                                    m.vh.micro.only, m.vh.transparent
   g.nm.s!m.nm.window.set := FALSE
   g.nm.s!m.nm.windowed := FALSE
   g.nm.s!m.nm.intervals.changed := FALSE

   g.nm.s!m.nm.num.auto.cut.points := m.nm.conf.num.of.cut.points

   // initialise current child name - there is no current child overlay
   g.nm.s!m.nm.curr.child := 0  // set length to zero to get null string

   // set special screen mode for NM operation
   g.sc.mode (2)

   // set currently selected video mode
   nm.set.video.mode ()

   // load child overlay and display the current variable

   g.nm.load.child ("cnmDISP")

   test g.nm.pick.initial.subset () then

      $(
         g.nm.init.display ()
         g.nm.init.class.colours (g.nm.class.colour)
         g.nm.shuffle.key ()

         g.sc.mess ("Loading data")
         g.nm.display.variable ()

         g.nm.restore.message.area ()    // display title
         g.nm.top.menu ()  // display appropriate menu bar
         resultis TRUE
      $)

   else
      $(
         // g.key := m.kd.fkey2  // failed to find suitable parameters for an
                              // initial display so exit back to previous
                              // search state

         // New action: leave in top level state
         let menu = table m.sd.act, m.sd.act, m.sd.wBlank,
                          m.sd.act, m.sd.wBlank, m.sd.wBlank

         move(menu, g.nm.s+m.nm.menu+m.box1, 6)
         g.sc.menu(menu)
         g.sc.mess("Select new area, or Main to exit")
         g.nm.position.videodisc ()    // get underlay map, if available
         resultis FALSE
      $)
$)


/*
      g.nm.toggle.video.mode

         toggles the video output mode between transparent and
         solid micro output modes
*/

and g.nm.toggle.video.mode () be
$(
   g.nm.s!m.nm.overlay.mode :=
      (g.nm.s!m.nm.overlay.mode = m.vh.transparent) ->
                                       m.vh.micro.only, m.vh.transparent
   nm.set.video.mode ()
$)


/*
      nm.set.video.mode

         sets the video mode according to the global static
*/

and nm.set.video.mode () be
$(
   // in test environment, ensure that vfs is selected for vh access and
   // restore current filing system before exit

   g.vh.video (g.nm.s!m.nm.overlay.mode)
$)


/**
         G.NM.GOTO.TEXT - PREPARE TO GOTO ESSAY STATE
         --------------------------------------------

         Loads up g.context with the essay addresses,
         saves the current palette and sets up a pending
         state change to the Essay state.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.context
         g.key
         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.goto.text []
         --------------

         set up item addresses in g.context
         save palette
         make pending state change to Essay handler
**/

and g.nm.goto.text () be
$(
   let missing.value = vec 1
   and private.text.address     = g.nm.s + m.nm.private.text.address
   and descriptive.text.address = g.nm.s + m.nm.descriptive.text.address
   and technical.text.address   = g.nm.s + m.nm.technical.text.address

   g.ut.set32 (-1, -1, missing.value)

   // set up item addresses in g.context so that all non-missing
   // addresses are rippled towards Private

   if g.ut.cmp32 (descriptive.text.address, missing.value) = m.eq then
      $(
         g.ut.mov32 (technical.text.address, descriptive.text.address)
         g.ut.mov32 (missing.value, technical.text.address)
      $)

   if g.ut.cmp32 (private.text.address, missing.value) = m.eq then
      $(
         g.ut.mov32 (descriptive.text.address, private.text.address)
         g.ut.mov32 (technical.text.address, descriptive.text.address)
         g.ut.mov32 (missing.value, technical.text.address)
      $)

   g.ut.mov32 (private.text.address,     g.context + m.itemaddress)
   g.ut.mov32 (descriptive.text.address, g.context + m.itemadd2)
   g.ut.mov32 (technical.text.address,   g.context + m.itemadd3)

   // read palette and save physical colours for restoring
   // when we come back
   for i = 1 to m.nm.num.of.class.intervals do
      g.nm.s!(m.nm.gen.purp + i) := g.sc.physical.colour (g.nm.class.colour!i)

   // make pending state change to Essay handler
   g.key := - m.st.ntext
$)


/**
         G.NM.RETURN.FROM.TEXT - RETURN FROM ESSAY STATE
         -----------------------------------------------

         Restores g.context and the mappable data environment
         to its state before visiting Essay; this includes
         regenration of the display.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.context

         PROGRAM DESIGN LANGUAGE:

         g.nm.return.from.text []
         ---------------------

         restore item address in g.context
         initialise itemadd2 and itemadd3 in g.context
         set screen mode 2
         restore palette
         restore video mode
         restore display by replot
         reload previous child overlay
         position videodisc for underlay map
         restore message area
         draw top level menu bar
**/

and g.nm.return.from.text () be
$(
   let missing.value = vec 1

   g.ut.set32 (-1, -1, missing.value)

   // restore context item addresses
   g.ut.mov32 (g.nm.s + m.nm.item.address, g.context + m.itemaddress)
   g.ut.mov32 (missing.value, g.context + m.itemadd2)
   g.ut.mov32 (missing.value, g.context + m.itemadd3)

   g.sc.mode (2)

   // reassign palette using physical colours that
   // were saved before going
   for i = 1 to m.nm.num.of.class.intervals do
      g.sc.palette (g.nm.class.colour!i, g.nm.s!(m.nm.gen.purp + i))

   nm.set.video.mode ()

   // replot variable using context in g.nm.s,
   // rewindow if it was windowed before,
   // reload child overlay that was current before,
   // reposition videodisc for underlay map
   g.nm.replot (FALSE, FALSE, g.nm.s!m.nm.windowed)

   g.nm.restore.message.area ()
   g.nm.top.menu ()
$)

.
