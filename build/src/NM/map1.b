//  PUK SOURCE  6.87
//$$debug
/**
         NM.MAP1 - TOP LEVEL OF NATIONAL MAPPABLE OPERATION
         --------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         11.02.86 1        D.R.Freed   Initial version
         20.02.86 2        DRF         Nm.map.ini:
                                         child ovly loaded
                                         call to
                                         g.nm.init.class.colours
                                         moved after call to
                                         g.nm.init.display
                                         init intervals changed
                                          flag
                                         init local data unpacked
                                          flag
                                         init m.nm.curr.child
                                         init window flag
                                         Picks initial display &
                                          exits if this fails
                                         Pending state change
                                          to forced area
                                       Function key handling
                                          revised
                                       NM statics reorganised
                                       Menu bar handling revised
                                       Diagnostics if CMOS 34 = 0
                                       Check for video player
                                          presence
                                       nm.map.ini made global
                                          and moved to MAP3
                                          to compile
                                       g.nm.toggle.video.mode
                                          made global & --> MAP3
                                       exit confirmation at top
                                          level
                                       Text operation implemented
                                       TAB in message area toggles
                                          between key & units
         ********************************
         30.6.87     3     DNH      CHANGES FOR UNI
 
         g.nm.map
**/

section "nmmap1"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/kdhd.h"
get "H/nmhd.h"


static
$(
   s.confirmation.pending = FALSE   // doesn't need to be cached, since
                                    // it should always be FALSE when
                                    // this overlay has just been loaded
$)


/**
         G.NM.MAP - ACTION ROUTINE FOR MAPPABLE DATA OPERATION
         -----------------------------------------------------

         Action routine for top level of the mappable data
         operation.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.key
         g.context!m.justselected
         g.context!m.itemaddress
         g.context!m.itemadd2
         g.context!m.itemadd3

         g.nm.s
         g.nm.class.colour

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.map []
         --------

         IF just selected THEN
            clear just selected flag
            initialise NM package
            clear "gone to text" flag
         ENDIF

         IF just returned from Text operation THEN
            clear "gone to text" flag
            restore environment
         ENDIF

         IF function key corresponding to Text pressed THEN
            set "gone to text" flag
            prepare for going to Essay state
         ENDIF

         IF function key corresponding to Main pressed AND
                                          exit was not forced THEN
            display confirmation question
            set confirmation pending flag
            suppress Main from menu bar
            clear g.key to prevent exit from mappable data
         ENDIF

         IF confirmation pending flag is set AND
                              a key has been pressed THEN
            echo 'Y' or 'N'
            clear confirmation pending flag
            wait a while so echo can be seen
            IF 'Y' or 'y' pressed THEN
               set g.key to function key for Main (to exit)
            ELSE
               restore message area
               restore Main on menu bar
            ENDIF
            flush keyboard buffer
         ENDIF

         IF tab key or change button pressed THEN
            IF pointer is in message area THEN
               IF message area contains key or units AND
                            data is not of incidence type THEN
                  toggle to key or units
               ENDIF
            ELSE
               toggle video overlay mode between solid and
                                             transparent
            ENDIF
         ENDIF

         IF function key corresponding to Key/Title pressed THEN
            toggle message area between key and title
         ENDIF
**/

let g.nm.map () be
$(
   let question = "Are you sure you wish to exit (Y/N)? "
   and echo, forced.exit = ?, ?

   forced.exit := FALSE

   if (g.context!m.justselected) then
      $( g.context!m.justselected := FALSE
         // initialise static that indicates message area contents;
         // this really belongs inside g.nm.map.ini but is included
         // here to get past the compiler's symbol table limitations
         g.nm.s!m.nm.message.area := m.wtitle

         // initialise the mappable data environment
         forced.exit := NOT g.nm.map.ini ()
         g.nm.s!m.nm.gone.to.text := FALSE
      $)

   if g.nm.s!m.nm.gone.to.text then
      $(
         g.nm.s!m.nm.gone.to.text := FALSE
         g.nm.return.from.text ()
      $)

   if g.key = m.kd.fkey5 then
      $(
         g.nm.s!m.nm.gone.to.text := TRUE
         g.nm.goto.text ()
      $)

   if (g.key = m.kd.fkey2) & (NOT forced.exit) then
      $(
         g.sc.mess (question)
         g.sc.movea (m.sd.message,
                     g.sc.width (question) + m.sd.mesXtex,
                     m.sd.mesYtex)

         s.confirmation.pending := TRUE   // waiting for reply

         // suppress Main from menu bar
         g.nm.s!(m.nm.menu + m.box2) := m.wblank
         g.sc.menu (g.nm.s + m.nm.menu)

         g.key := m.kd.noact
      $)

   if s.confirmation.pending & (g.key ~= m.kd.noact) then

      $(
         echo := (CAPCH (g.key) = 'Y') -> 'Y', 'N'
         g.sc.ofstr ("%c", echo)
         g.ut.wait (50)    // let user see response

         s.confirmation.pending := FALSE

         test echo = 'Y' then
            g.key := m.kd.fkey2
         else
            $(
               g.nm.restore.message.area ()

               // restore Main on menu bar
               g.nm.s!(m.nm.menu + m.box2) := m.sd.act
               g.sc.menu (g.nm.s + m.nm.menu)
            $)

         // since we were waiting for a printable character to be typed,
         // we should make sure that the buffer is flushed, since the
         // kernel won't do it
         g.sc.keyboard.flush ()
      $)

   if g.key = m.kd.tab then
      $(
      test g.screen = m.sd.message then
         if (g.nm.s!m.nm.message.area ~= m.wtitle) &
              (g.nm.s!m.nm.value.data.type ~= m.nm.incidence.type) then
            $(
               g.nm.s!m.nm.message.area :=
                  (g.nm.s!m.nm.message.area = m.wkey) -> m.wunits, m.wkey
               g.nm.restore.message.area ()
               g.key := m.kd.noact
            $)
      else
         $(
            // toggle the video output mode between transparent and
            // solid micro output
            g.nm.toggle.video.mode ()
            // g.key := m.kd.noact
         $)
      $)

   if g.key = m.kd.fkey6 then    // Key/Title
      $(  // toggle the message area between title and key
          // displays and update the menu bar to offer the option that
          // isn't on display
         g.nm.s!m.nm.message.area :=
            (g.nm.s!m.nm.message.area = m.wtitle) -> m.wkey, m.wtitle
         g.nm.restore.message.area ()
         g.nm.top.menu ()
      $)


$<debug

if g.ut.diag () & (g.key = '?') then
$(
   let norm.factor   =  ?
   and number = vec 1

   norm.factor :=
      g.nm.dual.data.type (g.nm.s!m.nm.value.data.type) ->
         g.nm.s!m.nm.secondary.norm.factor, g.nm.s!m.nm.primary.norm.factor

   g.sc.mess ("")
   g.sc.movea (m.sd.message, 0, m.sd.mesYtex)
   g.sc.oprop ("No=")
   g.ut.set32 (g.nm.s!m.nm.num.areas, 0, number)
   g.sc.opnum (number, 0, 5)
   g.sc.oprop ("Min=")
   g.sc.opnum (g.nm.s + m.nm.local.min.data.value, norm.factor, 5)
   g.sc.oprop ("Max=")
   g.sc.opnum (g.nm.s + m.nm.local.max.data.value, norm.factor, 5)
   g.sc.oprop ("Ave=")
   g.sc.opnum (g.nm.s + m.nm.local.average, norm.factor, 5)
$)
$>debug

$)

.

