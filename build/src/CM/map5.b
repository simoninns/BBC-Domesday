
//  UNI SOURCE  4.87

section "map5"

/**
         CM.B.MAP5 - Turn Disc Over Operation for Map
         --------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         12.6.86  1        DNH         Initial version
         30.6.86  2        DNH         Major changes
         17.9.86  3        DNH         Keyboard flush
                                       L0, L1 record rereads

         GLOBAL ROUTINES
         g.cm.turn.over.setup
         g.cm.turn.over.reply
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/dhhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/vhhd.h"
get "H/cmhd.h"


/**
         G.CM.TURN.OVER.SETUP - Prompts user to Turn Over Disc
                  for maps on the other side
         -----------------------------------------------------

         PROCEDURE g.cm.turn.over.setup ()

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: map statics

         SPECIAL NOTES FOR CALLERS:
         Alters the Map static flag 'turn.over.pending' which
         reminds action routines that the turn over question is
         on display and the next key press should be treated as
         an answer.  The flag should be unset by calling
         g.cm.turn.over.reply from the action routine.

         PROGRAM DESIGN LANGUAGE:

         g.cm.turn.over.setup ()
            output prompt in message area
            move graphics cursor to end of question
            select blue
            set 'turn over pending' flag
         end procedure
**/

let g.cm.turn.over.setup () be
$(
   let question = "Do you wish to eject the disc (Y/N)? "
   g.sc.mess (question)
   g.sc.movea (m.sd.message, g.sc.width (question) + m.sd.mesXtex,
                                                               m.sd.mesYtex)
   g.sc.selcol (m.sd.blue)
   g.cm.s!m.turn.over.pending := true        // waiting for reply
$)


/**
         function select.disc (latest key, side to turn to)

         Returns a boolean, true if the disc was successfully
         turned over after an affirmative response, false
         otherwise.
         The key press is echoed if a negative reply (anything
         other than a 'Y') was received.  Note that it will
         return false if eject was disallowed by VFS.
         Select disc must ONLY be called if the reply key is not
         m.kd.noact.
         Local routine, only called by g.cm.turn.over.reply.
**/

let select.disc (reply.key, requested.side) = valof   // true => turned over
$( let ch = capch (reply.key) = 'Y' -> 'Y', 'N'
   g.sc.ofstr ("%C", ch)            // echo
   if ch = 'Y' then
   $( g.sc.clear (m.sd.display)
      if g.dh.select.disc (requested.side) do
      $( g.sc.clear (m.sd.message)
         g.vh.video (m.vh.superimpose)    // ensure correct video mode
         resultis true                    // turned over OK
      $)
   $)
   g.ut.wait (50)                // let user see 'No' response
   g.sc.clear (m.sd.message)
   resultis false                // not turned over
$)


/**
         G.CM.TURN.OVER.REPLY - Handle Turn Over
         ---------------------------------------

         PROCEDURE g.cm.turn.over.reply ()

         INPUTS: no parameters; examines g.key

         OUTPUTS: none

         GLOBALS MODIFIED: indirectly, by called routines.

         SPECIAL NOTES FOR CALLERS:
         Only to be called from action routines when the turn
         over prompt is on display (as indicated by the 'turn
         over pending' flag.

         PROGRAM DESIGN LANGUAGE:
         g.cm.turn.over.reply ()
            work out which side to turn to
            if g.key not noact then
               if reply affirmative and disc turned over then
                  close mapdata file
                  open mapdata file on new side
                  clear map records cache
                  read L0 and L1 records
                  read parent map record
                  set map statics to map sought on this side
                  show the map
               endif
               unset 'turn over pending' flag
               flush keyboard buffer
            endif
         end procedure
**/

and g.cm.turn.over.reply () be
$(
   let rc = ?
   let requested.side = (g.context!m.discid = m.dh.south -> m.dh.north,
                                                                  m.dh.south)
   unless g.key = m.kd.noact do
   $(
      if select.disc (g.key, requested.side) do
      $(           // disc has been turned over as requested
         $<DEBUG
         g.cm.sel.fs (m.dh.adfs)
         $>DEBUG
         g.dh.close (g.cm.s!m.fhandle)
         g.cm.s!m.fhandle := g.dh.open ("MAPDATA1")
         g.cm.clear.cache ()

         for offset = 5 to 0 by -1 do
            g.cm.findmaprec (map.L1 + offset)
         g.cm.findmaprec (map.L0)

         g.cm.s!m.recptr := g.cm.findmaprec (g.cm.s!m.other.side.parent)
         g.cm.s!m.sind := g.cm.s!m.other.side.sind
         g.cm.s!m.map := g.cm.submap (g.cm.s!m.recptr, g.cm.s!m.sind)

         $<DEBUG
         if g.cm.s!m.map = 0 do
            g.cm.collapse ("Bad sind %N of map %N on turnover",
               g.cm.s!m.other.side.sind, g.cm.s!m.other.side.parent)
         $>DEBUG

         g.cm.submapinfo ()
         g.cm.showmap (m.cm.frame.bit | m.cm.icons.bit)
      $)

      g.cm.s!m.turn.over.pending := false       // no longer pending
      g.sc.keyboard.flush ()
   $)
$)
.
