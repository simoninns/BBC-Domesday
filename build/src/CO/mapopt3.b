//  UNI SOURCE  4.87

section "mapopt3"

/**
         CM.B.MAPOPT3 - Map Overlay Key Option
         -------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         16.4.86  1        DNH         Initial version
          2.5.86  2        DNH         Frame changes etc.
         10.6.86  3        DNH         bugfix L0 frame
          8.7.86  4        DNH         unmute video after Help

         GLOBALS DEFINED:
            g.cm.keyini ()
            g.cm.mapkey ()
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/dhhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/vhhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"

/**
         G.CM.KEYINI - Init. for 'Key' operation
         ---------------------------------------

         PROCEDURE g.cm.keyini ()

         INPUTS:
         Map static map level.

         OUTPUTS: none

         GLOBALS MODIFIED:
         Map statics are initialised to indicate the correct
         key frame sequence for the current map level and set the
         substate to 'key' operation.

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.cm.keyini ()
            set pointer into key frame table by map level
            set statics for key frame info
            clear message and display areas
            set static substate
         end procedure
**/

let g.cm.keyini () be
$(

/*
   key.pic.tab holds 4 values for each map level (row of table):

   !0   start frame for 'text' for key
   !1   number of frames of 'text' for key
   !2   start frame for 'key proper'
   !3   number of frames of 'key proper'

   The 'text' is shown first and always exists; the 'key proper'
   is tagged onto the end and sometimes exists.
*/

   let key.pic.tab = table
      18751, 1,     0,  0,    // L0
      18752, 1,     0,  0,
      18753, 1, 18759,  3,
      18754, 2, 18762, 10,
      18756, 1, 18772, 19     // L4       (no Options at L5)

   let ptr = g.cm.s!m.cmlevel * 4 + key.pic.tab   // find entry for this level
   g.sc.pointer (m.sd.off)
   g.cm.s!m.key.tab.ptr := ptr
   g.cm.s!m.key.pic     := ptr!0                 // set initial pic
   g.sc.clear (m.sd.message)
   g.sc.clear (m.sd.display)
   g.cm.s!m.substate := m.key.substate
$)


/**
         G.CM.MAPKEY - Action Routine for Map Key Operation
         --------------------------------------------------

         PROCEDURE g.cm.mapkey ()

         INPUTS: none directly

         OUTPUTS: none

         GLOBALS MODIFIED:
         Various map statics.

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.cm.mapkey ()
            unmute video if necessary
            if no key pressed and g.redraw unset then RETURN
            switch off pointer
            determine next frame direction from key press
            show next frame if not already on display
            redraw menu bar if altered
            switch on pointer
         end procedure
**/

and g.cm.mapkey () be
$(
   let barflags = table ?,?,?,?,?,?
   let dir = ?
   let old.key.pic = g.cm.s!m.key.pic

   if g.cm.s!m.data.accessed do           // unmute video after Help
   $( g.vh.video (m.vh.video.on)
      g.cm.s!m.data.accessed := false
   $)

   if g.key = m.kd.noact & ~g.redraw do         // nothing to do
      return

   g.sc.pointer (m.sd.off)
   dir := key.pic.direction ()      // looks at g.key
   g.cm.s!m.key.pic := next.key.pic (g.cm.s!m.key.pic,
                                                g.cm.s!m.key.tab.ptr, dir)
   if g.cm.s!m.key.pic ~= old.key.pic | g.redraw do
   $(
      let local.redraw = mapkey.config.mb (barflags)
      $<DEBUG
      g.cm.sel.fs (m.dh.vfs)
      $>DEBUG
      g.vh.frame (g.cm.s!m.key.pic)
      if g.redraw | local.redraw do g.sc.menu (barflags)
   $)
   g.sc.pointer (m.sd.on)
$)

/**
         key.pic.direction ()
         Returns a manifest value according to the calculated
         virtual direction (first/previous/next/invalid)
         determined by the key pressed and the screen area in
         which the pointer is.
**/

and key.pic.direction () = valof
$(
   let rc = ?
   switchon g.key into
   $( case m.kd.fkey3:
         rc := m.first; endcase
      case m.kd.fkey7:
         rc := m.previous; endcase
      case m.kd.fkey8:
         rc := m.next; endcase
      case m.kd.tab:
         if g.screen = m.sd.display do
         $( test g.xpoint < m.sd.disw / 3 then rc := m.previous
            else
            test g.xpoint > m.sd.disw * 2 / 3 then rc := m.next
            else g.sc.beep ()
            endcase
         $)
      default:
         resultis m.invalid
   $)
   g.key := m.kd.noact
   resultis rc
$)

/**
         next.key.pic (current frame, table pointer, direction)
         Returns the frame number of the next video frame to be
         displayed given the current frame number, a pointer into
         the table of frames and the direction of movement as
         determined by 'key.pic.direction ()'.
**/

and next.key.pic (pic, tab.ptr, dir) = valof switchon dir into
$(
   case m.invalid:
      resultis pic            // no change

   case m.first:
      resultis tab.ptr!0      // the very first

   case m.previous:
      test pic = tab.ptr!2 then                       // first of second lot
         pic := tab.ptr!0 + tab.ptr!1 - 1             // last of first lot
      else
      test pic = tab.ptr!0 then                       // at very beginning
         g.sc.beep ()
      else
         pic := pic - 1                               // next back
      resultis pic

   case m.next:
      test pic = tab.ptr!0 + tab.ptr!1 - 1 then       // last of first lot
         test tab.ptr!2 ~= 0 then
            pic := tab.ptr!2                          // first of second lot
         else
            g.sc.beep ()                              // no more
      else
      test pic = tab.ptr!2 + tab.ptr!3 - 1 then       // last of second lot
         g.sc.beep ()                                 // at very end
      else
         pic := pic + 1                               // next along
      resultis pic
$)


/**
         mapkey.config.mb (barflags)
         Returns a boolean according to whether it is necessary
         to redraw the menu bar due to a change in its contents.
         A new menu bar is constructed and compared with the
         current one in g.context to determine this.
**/

and mapkey.config.mb (barflags) = valof
$(
   barflags!0 := m.sd.act
   move (barflags, barflags+1, 2)
   if g.cm.s!m.key.pic = g.cm.s!m.key.tab.ptr!0 do    // at first pic
      barflags!m.box3 := m.sd.wblank                  // clear "first" box
   resultis g.cm.cmpw (barflags, g.menubar, 3) ~= -1
$)
.
