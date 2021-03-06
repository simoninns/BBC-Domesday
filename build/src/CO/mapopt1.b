//  UNI SOURCE  4.87

section "mapopt1"

/**
         CM.B.MAPOPT1 - Map Overlay Options Control
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         18.2.86  1        DNH         Initial version
         25.3.86  2                    Cursor key moves
         28.4.86  3                    sideways moves etc
         16.5.86  4                    ermess for no zoom
          1.7.86  5                    turn over handling
          8.7.86  6                    unmute video after Help
         20.10.86 7        DNH         fix turn over in grid ref

         GLOBALS DEFINED:
            g.cm.mapopt ()
            g.cm.optini ()
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/vhhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"

/**
         G.CM.MAPOPT - Action Routine for Map Options
         --------------------------------------------

         Handles map Options first state and grid reference
         suboperation.  Sideways moves, but not zooms, are
         allowed here.

         INPUTS:  No parameters; map statics and g.context flags
         are examined.

         OUTPUTS: None.

         GLOBALS MODIFIED:

         G.key is patched to noact and g.redraw set true if F5 is
         pressed to get into grid reference substate since this
         is fully dealt with here in the action routine.

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:

         procedure g.cm.mapopt ()
                   --------------
            if key pressed switch off pointer
            if data accessed flag set then
               unmute video
               unset data accessed flag
            if turn over pending flag set (moving across Domesday
                                                Wall)
               handle possible reply to turn over
               if in 'grid ref substate' and reply given then
                  redisplay grid reference banner
            case g.key of
               <tab or any shifted cursor key>:
                  handle sideways moves as in g.cm.mapwal ()
               return:
                  if pointer in display area then
                     if in 'grid ref substate' then
                        show grid ref of current pointer pos'n
                     else
                        warn user that zoom is not available
               Help or Main:
                  update g.context globals
               Grid Ref:
                  set substate to 'grid ref substate'
                  display grid reference banner
                  set g.redraw true to force a redraw
                  set g.key to noact
            end case statement
            if g.redraw flag set then
               configure menu bar flags
               redraw menu bar (this unsets g.redraw)
            switch pointer on

**/

let g.cm.mapopt () be
$(
   let barflags = table ?,?,?,?,?,?
   let dispflags = m.cm.frame.bit | m.cm.graphics.bit | m.cm.messages.bit
                              // graphics but no icons (nor border)

   unless g.key = m.kd.noact do g.sc.pointer (m.sd.off)

   if g.cm.s!m.data.accessed do           // unmute video after Help
   $( g.vh.video (m.vh.video.on)
      g.cm.s!m.data.accessed := false
   $)

   if g.cm.s!m.turn.over.pending do    // look for a reply to "Eject disc?"
   $( g.cm.turn.over.reply ()
      if g.cm.s!m.substate = m.grid.ref.substate &
         ~g.cm.s!m.turn.over.pending do
         g.cm.show.grid.banner ()      // redisplay in message area
   $)

   switchon g.key into
   $( case m.kd.tab:                // handle sideways moves
         if g.screen = m.sd.display do
         $( let direc = g.cm.direction ()
            unless direc = m.invalid do
               g.cm.go (direc, dispflags)
         $)
         endcase

      case m.kd.S.left:
         g.cm.go (m.w, dispflags)
         endcase

      case m.kd.S.right:
         g.cm.go (m.e, dispflags)
         endcase

      case m.kd.S.up:
         g.cm.go (m.n, dispflags)
         endcase

      case m.kd.S.down:
         g.cm.go (m.s, dispflags)
         endcase

      case m.kd.return:             // display Grid Ref if in substate
         if g.screen = m.sd.display do
         $( test g.cm.s!m.substate = m.grid.ref.substate then
               g.cm.show.grid.ref ()      // uses current pointer xy position
            else
            $( g.sc.pointer (m.sd.on)     // switch on first
               g.sc.ermess ("Zoom not available in Options")
            $)
         $)
         endcase

      case m.kd.fkey1:        // Help
      case m.kd.fkey2:        // Main
         g.cm.update.globals ()
         endcase

      case m.kd.fkey5:              // enter Grid Ref substate
         g.cm.s!m.substate := m.grid.ref.substate
         g.cm.show.grid.banner ()
         g.redraw := true                       // we need a new menu bar
         g.key := m.kd.noact                    // we've dealt with it
         endcase
   $)

   if g.redraw do                            // things have changed
   $( mapopt.config.mb (barflags)
      g.sc.menu (barflags)
   $)
   g.sc.pointer (m.sd.on)                    // restore pointer
$)


/*
         mapopt.config.mb (barflags) is only called when it is
         necessary to redraw the menu bar due to a change in its
         contents.
*/

and mapopt.config.mb (barflags) be
$( let gl = g.cm.s!m.cmlevel
   barflags!0 := m.sd.act
   move (barflags, barflags+1, 5)
   if gl = 0 | gl = 5 | g.cm.s!m.substate = m.grid.ref.substate do
      barflags!m.box5 := m.sd.wblank
$)


/**
         G.CM.OPTINI - Initialisation for Map Options
         --------------------------------------------

         Sets up for Map Options, in particular clearing display
         area and showing an unhighlit map if we are at level 0.

         INPUTS:  None

         OUTPUTS: None

         GLOBALS MODIFIED: G.context updated.

         SPECIAL NOTES FOR CALLERS: Only call from state machine.

         PROGRAM DESIGN LANGUAGE:

**/

let g.cm.optini () be
$(
   g.sc.pointer (m.sd.off)
   g.cm.s!m.substate := m.options.substate
   if g.cm.s!m.cmlevel = 0 do
      g.cm.showframe (L0.no.highlight)
   g.cm.update.globals ()           // ensure these are set up for return
   g.sc.clear (m.sd.message)
         // clear icons; else only clear border - quicker!
   test g.cm.s!m.clear.is.pending then
      g.sc.clear (m.sd.display)
   else
      g.cm.clear.yellow.border ()
$)
.
