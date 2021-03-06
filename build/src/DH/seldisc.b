//  $MSC
//  AES SOURCE  4.87

section "seldisc"

/**
         DH.B.SELDISC - Select Disc (Turnover) Function
         ----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.seldisc  (a library to link with)

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         19.6.86     1     DNH         Initial version
         24.6.86     2     DNH
          2.7.86     3     DNH         video off mode on exit
                                       close all open files
                                       no disc in drive test
         22.7.86     4     DNH         messages & loop test
          4.8.86     5     DNH         User Codes testing
         18.8.86     6     PAC         Mod to seldisc for side 4
         11.9.86     7     DNH         Enable video after eject
                                       Remove "..video.off" call
                                       Fix nul to CR for reply
                                          code not ready
         1.10.86     8     DNH         Pause mode for NatB
         15.10.86    9     DNH         debug bracket changes
          3.11.86   10     DNH         Show copyright for NatB

         g.dh.select.disc
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "H/dhhd.h"
get "H/sdhd.h"
get "H/vhhd.h"

$<debug
static $( count = 0 $)
$>debug

let disable.switches () be
$(
   debugmess ("Disable switches")
   g.vh.video (m.vh.micro.only)
//   g.vh.video (m.vh.video.off)    // default so not necessary. wastes time
//   g.vh.audio (m.vh.no.channel)   //   ditto

   g.vh.send.fcode ("I0")       // disable front panel buttons
   g.vh.send.fcode ("J0")       // disable remote control
   g.vh.send.fcode ("$0")       // disable replay switch

   $<debug
      // DOES JUST THE REVERSE, FOR TESTING PURPOSES  **************
   g.vh.send.fcode ("I1")       // ENABLE front panel buttons
   g.vh.send.fcode ("J1")       // ENABLE remote control
   g.vh.send.fcode ("$1")       // ENABLE replay switch
   $>debug
$)

$<debug
            // looks at CMOS RAM byte 34
and messages.allowed () = g.ut.diag()
$>debug       

and debugmess (str, p1, p2, p3) be
$(
   $<debug
   if messages.allowed () do
      g.sc.mess (str, p1, p2, p3)
   $>debug

   return
$)


      // show the result of a 'g.vh.call.oscli'
and show.result (rc) be
$(
   $<debug
   let str = "OK "
   if messages.allowed () do
   $( if rc ~= 0 do str := "FAILED %N "
      g.sc.movea (m.sd.message, 25 * m.sd.charwidth, m.sd.mesYtex)
      g.sc.ofstr (str, rc)
   $)
   $>debug

   return
$)


      // show the reply from a 'poll'
and show.reply (reply, rc) be
$(
   $<debug
   let j = 0
   let str = vec 1
   if messages.allowed () do
   $( str%0 := 1
      g.sc.movea (m.sd.message, 25 * m.sd.charwidth, m.sd.mesYtex)
      g.sc.ofstr ("*"")
      $( if reply%j = '*C' break
         str%1 := reply%j
         g.sc.ofstr (str)
         j := j+1
      $) repeat
      g.sc.ofstr ("*" rc=%N %N", rc, count)
      count := count+1
   $)
   $>debug

   return
$)


and prompt.user.for (requested.side) be
$(
   let insert1, insert2 = ?,?
   let body = "Please insert %S %S Disc"
   let community.mess = "Community"
   let national.mess = "National"

   test requested.side = m.dh.south | requested.side = m.dh.north then
   $(
      insert1 := community.mess
      insert2 := requested.side = m.dh.south -> "South", "North"
   $)
   else
   $(
      insert1 := national.mess
      insert2 := requested.side = m.dh.natA -> "A", "B"
   $)
   g.sc.beep ()
   g.sc.mess (body, insert1, insert2)
$)


/**
         G.DH.SELECT.DISC - Load a different video disc
         ----------------------------------------------

         Allows changing of discs under software control without
         enabling of the front panel.  The old disc is ejected
         and the requested one prompted for.  The routine does
         not return unless the eject fails (in which case the
         disc side remains the same) or the requested disc
         side has been inserted and initialised.

         INPUTS:

         One parameter: requested side:- a manifest from dhhdr
         such as m.dh.south.

         One global: g.context!m.discid is used as the
         authoritative statement of which disc is initially in
         the drive.

         OUTPUTS:

         returns  true: => disc has been turned to the requested
                           side
                 false: => eject of disc has failed; the disc
                           side is the initial side

         GLOBALS MODIFIED:

         g.context!m.discid is updated to the discid of the disc
         in the player when the call returns.
         Note that ALL open files on VFS are closed if the eject
         was allowed but no files are closed if the eject was
         disallowed by VFS.

         SPECIAL NOTES FOR CALLERS:

         There is nothing that the software can do if the
         eject was disallowed.  All callers must be able to
         recover from this.  The global discid remains unchanged
         in this case.

         If a wrong disc is detected it is re-ejected and the
         prompt is repeated.

         g.dh.discid () is used to get the actual disc id.  It
         uses fcode "?U" to obtain the User Code.  This should
         be unique to a certain disc type but due to lack of
         any control by Philips this cannot be guaranteed.  It
         is unlikely to be a problem, though, since we CAN tell
         all the Domesday discs apart.

         g.dh.select.disc prompts with one of the following
         messages at least once during the process:
            "Please insert Community South disc"
            "Please insert Community North disc"
            "Please insert National A disc"
            "Please insert National B disc"

         On return player status is always:
         Display area, menu bar unchanged
         Message area cleared
         Video mode 'm.vh.micro.only'
         Video status 'm.vh.video.off'
         Audio status 'm.vh.no.channel'
         If the NatB CLV disc has been selected then the disc is
         'Paused' to avoid run-on.  This mutes video.


         PROGRAM DESIGN LANGUAGE:

**/

and g.dh.select.disc (requested.side) = valof   // true => turned over
$(                                              // false => no change
   let initial.side = g.context!m.discid
   let discid = ?                               // manifest from dhhdr
   let rc = ?
   let reply = vec m.vh.poll.buf.words

   g.sc.mess ("Ejecting disc...")      // don't repeat message
   $(                                  // since might have been empty
      rc := g.vh.call.oscli ("EJECT*C")
      show.result (rc)                          // VFS result code
      unless rc = 0 do                          // non-zero => not allowed
      $(
         g.sc.clear (m.sd.message)
         g.sc.ermess ("Eject not allowed")
         discid := initial.side                 // still logged on so OK
         break                                  // break to get out of loop
      $)

      disable.switches ()                    // reenable micro output
      g.dh.close (0)                         // close all open files on VFS

      $(
         debugmess ("Waiting for lid Open...")
         rc := g.vh.poll (m.vh.read.reply, reply) // read reply from the eject
         show.reply (reply, rc)
      $) repeatuntil rc = m.vh.lid.open

      prompt.user.for (requested.side)
      debugmess ("Stop Unit...")
      rc := g.vh.call.oscli ("BYE*C")   // stop unit: official way to log off
      show.result (rc)
      disable.switches ()     // necessary since 'stop unit' enables all

      $(                      // old disc logged off; now try to reload
         $( g.ut.wait (50)        // (give it time to actually eject)
            debugmess ("Waiting for drawer closed...")
            rc := g.vh.poll (m.vh.player.status.poll, reply)
            show.reply (reply, rc)
         $) repeatwhile rc = m.vh.lid.open

         debugmess ("Trying to load disc...")
         g.vh.send.fcode (",1")

         $( rc := g.vh.poll (m.vh.read.reply, reply)
            show.reply (reply, rc)
         $) repeatwhile reply%0 = '*C' // CR => not ready with reply code
      $) repeatuntil reply%0 = 'S'     // loaded OK

      g.sc.mess ("Initialising disc...")  // real message !
      debugmess ("Start Unit...")
      rc := g.vh.call.oscli ("RESET*C")   // send start unit;
      show.result (rc)

      // g.dh.discid uses user code to determine disc id.  It will succeed
      // first time here since the 'start unit' reply ensures that the disc
      // is up to speed

      discid := g.dh.discid ()            // non.domesday => duff,
                                          // else a manifest
      test discid = requested.side then
      $(
         test discid = m.dh.natB then     // special handling for CLV
         $(
            g.ut.wait (100)               // wait a sec - show copyright mess.
            disable.switches ()
            g.vh.send.fcode ("/")         // pause disc
         $)
         else                             // mount a CAV disc
         $(
            debugmess ("Mount...")
            rc := g.vh.call.oscli ("MOUNT 0*C")
            show.result (rc)
            disable.switches ()        // need disabling after reset/mount
            unless rc = 0 do           // (shouldn't fail; user code OK)
            $( g.sc.mess ("Disc fault: failed to initialise this disc")
               g.sc.beep ()
               discid := m.dh.not.domesday   // duff disc; try again
            $)
         $)
      $)
      else
      $(
         g.sc.mess ("Wrong disc side")
         g.sc.beep ()                     // beep, then eject straight away
      $)
   $) repeatuntil discid = requested.side

   g.context!m.discid := discid
   g.sc.clear (m.sd.message)
   resultis (discid = requested.side)     // true if turned over
$)                                        // false if disallowed
.

