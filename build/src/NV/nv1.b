//  AES SOURCE  4.87

section "nv1"

/**
         NV.NV1 - Action Routine for National Video
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.film

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         1.7.86      1     DNH      Initial version
         22.7.86     2              Bugfix Help state etc.
         18.9.86     3              Keyboard flush in
         12.11.86    4     DNH      Escape trap: no restart
         *****************************
         20.5.87     5     DNH      CHANGES FOR UNI
                                    vec in prompt.for...
         5.6.87      6     DNH      allow escape using 'Q'

         GLOBALS DEFINED:
            g.nv.film
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNVhd.h"
get "H/dhhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/vhhd.h"

get "H/nvhd.h"


/**
         procedure 'prompt.for.turn.over ()' prompts the user by
         writing text in the message area.
**/

let prompt.for.turn.over () be
$(
   let prompt = "Turn videodisc over "
   let tag = "for this item"
   let question = "Do you wish to eject the disc (Y/N)? "
   let temp.vec = vec 40/BYTESPERWORD

   g.sc.clear (m.sd.message)
   test g.context!m.discid = m.dh.NatA then     // turning over to film item
   $(
      g.ut.movebytes (prompt, 1, temp.vec, 1, prompt%0)
      g.ut.movebytes (tag,    1, temp.vec, prompt%0+1, tag%0)
      temp.vec%0 := prompt%0 + tag%0
      g.sc.ermess (temp.vec)
   $)
   else                                      // back to item select operation
      g.sc.ermess (prompt)
   g.sc.mess (question)
   g.nv.s!m.response.xpos := g.sc.width (question) + m.sd.mesXtex
$)


/**
         Function 'select.disc (key, requested side)' returns
         true if the disc has been turned over, false otherwise.
         It looks at the key passed to determine whether the user
         has responded to 'prompt.user.for' message and if so it
         calls the DH primitive to eject the current disc and get
         the requested side loaded.  If the user gives a negative
         response (pressing any key other than 'Y' or 'y') 'N' is
         printed at the current cursor position and held for half
         a second.  The message area is always cleared and the
         keyboard buffer flushed to clear out any keypresses
         that would not be cleared by Getact if the last
         character was an alphabetic.
**/

and select.disc (key, requested.side) = valof   // true => turned over
$(
   let ch = capch (key) = 'Y' -> 'Y', 'N'
   let rc = false                // default: negative response or failed

   g.sc.movea (m.sd.message, g.nv.s!m.response.xpos, m.sd.mesYtex)
   g.sc.selcol (m.sd.blue)
   g.sc.ofstr ("%C", ch)         // show response

   test ch = 'Y' then
      rc := g.dh.select.disc (requested.side)         // try to turn over
   else
      g.ut.wait (50)             // let user see 'No' response

   g.sc.clear (m.sd.message)
   g.sc.keyboard.flush ()        // get rid of any stored keypresses
   resultis rc                   // turned over or not
$)


/**
         procedure 'highlight.list ()' calls g.sc.high to
         highlight an item in the film selection menu.  The
         currently highlit entry is updated in g.nv.s!m.film.
**/

and highlight.list () be      // highlight a film number in the list
   g.nv.s!m.film := g.sc.high (1, g.nv.s!m.num.entries, false,
                                                      m.nv.screen.list.offset)


/**
         G.NV.FILM - State Action Routine for National Video
         ---------------------------------------------------

         INPUTS:  No parameters.  Examines g.key and g.redraw.

         OUTPUTS:  None

         GLOBALS MODIFIED:

         * g.key is set to m.kd.noact when a special key has been
         intercepted by the action routine and should not be
         allowed to drop through to 'general'.  In one case g.key
         is set to fkey2 to exit via Main.

         SPECIAL NOTES FOR CALLERS: Only called from state tables.

         PROGRAM DESIGN LANGUAGE:

         procedure g.nv.film []
                   ------------
            if key pressed then
               switch off pointer
            endif

            case substate of

               initial.substate:
                  prepare for turn over to film side of disc
                  enter 'entry.question.substate'

               entry.question.substate:
                  if response is positive then
                     call procedure to play initial film
                              as selected in previous operation
                     enter 'play.substate'
                  else
                     if key is Help
                        leave it alone
                     else
                        set key to fkey2 to cause exit via Main
                     endif
                  endif

               play.substate:
                  if at end of film or escape key pressed
                     abort film and enter Pause mode
                     show the film menu
                     enter 'select.substate'
                  endif
                  set g.key to noact to prevent escape getting to
                                                         'general'

               select.substate:
                  if no key pressed
                     call highlight routine
                  endif

               help.substate:
                  if Exit was pressed
                     set g.key to noact
                     redisplay film menu list
                     enter 'select.substate'
                  endif

               exit.question.substate:
                  if no key pressed
                     call highlight routine
                  else
                     if positive response and disc turned over
                                                    successfully
                        set g.key to fkey2 to exit via Main
                     else
                        enter 'select.substate'
                     endif
                  endif

            end case statement


            case g.key of
               fkey1:
                  if normal Help is unavailable
                     show private Help page
                     enter 'help.substate'
                  endif

               fkey2:
                  if Main was pressed on side B
                     prompt turn back to side A
                     enter 'exit.question.substate'
                  endif

               return key:
                  show another film if selected and in the
                                        correct substate
            end case statement

            if necessary, redraw menu bar
            switch on pointer
         end
**/


and g.nv.film () be           // Film Action Routine
$(
   let barflags = table ?,?,?
   let old.substate = g.nv.s!m.substate
   unless g.key = m.kd.noact do g.sc.pointer (m.sd.off)

   switchon old.substate into
   $(SW1
      case m.nv.initial.substate:      // prepare for turn over to film side
         g.sc.pointer (m.sd.off)       // (prevents winking at startup)
         g.sc.clear (m.sd.display)
         prompt.for.turn.over ()
         g.nv.s!m.substate := m.nv.entry.question.substate
         endcase

      case m.nv.entry.question.substate:     // get reply to "Eject disc?"
         unless g.key = m.kd.noact do
            test select.disc (g.key, m.dh.natB) then
            $( g.nv.start.chosen.film ()     // issue the play chapter
               g.nv.s!m.substate := m.nv.play.substate
            $)
            else                             // didn't select film side
               unless g.key = m.kd.fkey1 do  // Help
                  g.key := m.kd.fkey2        // otherwise set to Main
         endcase

      case m.nv.play.substate:               // poll for escape or end of film
      $( let reply.buf = vec m.vh.poll.buf.words
         if g.key = '*E' |    // Escape
            g.key = 'Q'  |    // Q (allows dev't env't to be interrupted)
            g.vh.poll (m.vh.read.reply, reply.buf) = m.vh.finished do
         $(
            g.vh.send.fcode ("X")            // send a Clear command
            g.vh.send.fcode ("/")            // send a Pause command
            g.nv.show.film.list ()
            g.nv.s!m.substate := m.nv.select.substate    // into film menu
         $)
         g.key := m.kd.noact     // mustn't let Escape get to General;
                                 // trap it here so as not to put a message up.
         endcase
      $)

      case m.nv.select.substate:             // highlight & select from list
         if g.key = m.kd.noact do            // (return key handled below)
            highlight.list ()
         endcase

      case m.nv.help.substate:         // test for Exit key pressed
         if g.key = m.kd.fkey1 do
         $( g.key := m.kd.noact        // kill this key
            g.nv.show.film.list ()
            g.nv.s!m.substate := m.nv.select.substate
         $)
         endcase

      case m.nv.exit.question.substate:      // get reply to "Eject disc?"
         test g.key = m.kd.noact then             // no key press
            highlight.list ()
         else
            // note that Return key for film selection or Help key for
            // entering Help will be handled later

            test select.disc (g.key, m.dh.natA) then
               g.key := m.kd.fkey2           // Main, to get out
            else
            $( g.nv.s!m.substate := m.nv.select.substate
               if g.key = '*E' do            // trap escape  12.11.86
                  g.key := m.kd.noact        // without warning message
                     // (substate change may be overridden later if Help or
                     //  Return was pressed)
            $)
         endcase
   $)SW1


   // now handle g.key, either as originally entered or as patched above

   switchon g.key into
   $(SW2
      case '*E':                    // trap escape; can't restart here
         g.sc.ermess ("Restart is not available on this disc side")
         g.key := m.kd.noact
         endcase

      case m.kd.fkey1:              // Help
         if g.context!m.discid = m.dh.NatB do
         $(
            g.key := m.kd.noact
            g.nv.show.help.page ()
            g.nv.s!m.substate := m.nv.help.substate
         $)
         endcase
            // (note that Help on NatA disc side is not
            // intercepted since the REAL Help facility is entered)

      case m.kd.fkey2:              // Main
         if g.context!m.discid = m.dh.NatB do
         $(
            g.key := m.kd.noact     // need to turn back first
            prompt.for.turn.over ()
            g.nv.s!m.substate := m.nv.exit.question.substate
         $)
         endcase

      case m.kd.return:             // may be a film selection
         if g.nv.s!m.substate = m.nv.select.substate &
            1 <= g.nv.s!m.film <= g.nv.s!m.num.entries do
         $(
            g.nv.s!m.current.entry.offset := m.nv.list.offset +
                                          (g.nv.s!m.film - 1) * m.nv.entry.size
            g.nv.start.chosen.film ()
            g.nv.s!m.substate := m.nv.play.substate
         $)
         endcase
   $)SW2


   if g.redraw | g.nv.s!m.substate ~= old.substate do
   $( let local.redraw = nv.config.mb (barflags)
      if g.redraw | local.redraw do g.sc.menu (barflags)
   $)

   g.sc.pointer (m.sd.on)
$)


/**
         function 'nv.config.mb (barflags)' returns true if a
         redraw of the menu bar is needed due to a local change
         of substate.  The barflags are set up if this is so.
**/

and nv.config.mb (barflags) = valof
$(
   let substate = g.nv.s!m.substate
   barflags!m.box1, barflags!m.box2 := m.sd.act, m.sd.act

   if substate = m.nv.exit.question.substate |
      substate = m.nv.help.substate do
   $( barflags!m.box2 := m.wblank               // Main -> blank
      if substate = m.nv.help.substate do
         barflags!m.box1 := m.wExit             // Help -> Exit
   $)
   resultis barflags!m.box1 ~= g.menubar!m.box1 |
            barflags!m.box2 ~= g.menubar!m.box2
$)
.
