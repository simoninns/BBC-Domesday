//  UNI SOURCE  4.87

section "cm2"

/**
         CM.B.CM2 - Control Routines for Map Overlay
         -------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         18.2.86  1        DNH         Initial version
          5.3.86  2        DNH         Split across cm1,cm2
                                       and GR top bits in
         30.6.86  3        DNH         Turn over handling
          8.7.86  4        DNH         Return from Help: unmute
                                       Find unavailable at L5

         GLOBALS DEFINED:
         g.cm.mapwal
         g.cm.cmpw
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/grhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/vhhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"

/**
         procedure g.cm.mapwal () is the main action routine for
         mapwalking and is entered on start up of the Community
         Disc.  If the map overlay has only just been selected by
         a non menu bar transition then g.cm.mapini is called to
         set things up.
**/

let g.cm.mapwal() be
$(
   let barflags = table ?,?,?,?,?,?
   let dispflags = m.cm.frame.bit | m.cm.graphics.bit |
                   m.cm.messages.bit | m.cm.icons.bit
   let oldframe = g.cm.s!m.frame

   if g.context!m.justselected do
   $( g.cm.mapini.special ()        // catch power-up and 'Find' pending state change
      g.context!m.justselected := false
   $)

   unless g.key = m.kd.noact do g.sc.pointer (m.sd.off)

            //  clear of final box after zoom out to L1, L2
   if g.cm.s!m.substate = m.box.clear.pending.substate then
      if g.key ~= m.kd.noact |
         g.xpoint ~= g.cm.s!m.old.xpoint |
         g.ypoint ~= g.cm.s!m.old.ypoint do
      $( g.sc.selcol (m.sd.yellow)
         g.cm.box (false, g.cm.s!m.old.a0, g.cm.s!m.old.b0,
                                          g.cm.s!m.old.a1, g.cm.s!m.old.b1)
         g.cm.box (true, 0, 0, m.sd.disw-1, m.sd.dish-1)  // restore border
         g.cm.s!m.substate := m.mapwalk.substate          // reset to normal
      $)

            //  waiting for reply to "Eject disc?" prompt
   if g.cm.s!m.turn.over.pending do
      g.cm.turn.over.reply ()

            //  the main key handling
   switchon g.key into
   $( case m.kd.tab:                // handle sideways moves
         if g.screen = m.sd.display do
         $( let direc = g.cm.direction ()
            unless direc = m.invalid do g.cm.go (direc, dispflags)
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

      case m.kd.return:       // handle zoom in, including graphics etc.
         if g.screen = m.sd.display do g.cm.down (dispflags)
                    // ... and go on to check for highlight needed

      case m.kd.noact:        // handle L0 pointer shifting
         if g.cm.s!m.cmlevel = 0 do g.cm.highlight.level0 ()
         endcase

      case m.kd.fkey3:        // 'Out' on menu bar - zoom out
         g.cm.up (dispflags)
         if g.cm.s!m.cmlevel = 0 do g.cm.highlight.level0 ()
         g.key := m.kd.noact           // we've dealt with function key
   $)

   if g.cm.s!m.frame ~= oldframe | g.redraw do
   $(                                       // things have changed
      let local.redraw = mapwalk.config.mb (barflags)
      if g.redraw | local.redraw do g.sc.menu (barflags)
      if g.cm.s!m.frame = 0 do               // returned from options
         g.cm.showmap (m.cm.frame.bit | m.cm.icons.bit)
                           // so show the frame and overlay the icons
   $)

   if g.cm.s!m.data.accessed do           // unmute video after Help
   $( g.vh.video (m.vh.video.on)
      g.cm.s!m.data.accessed := false
   $)

   g.sc.pointer (m.sd.on)
$)


/**
         function mapwalk.config.mb (barflags) returns whether it
         is necessary to redraw the menu bar due to a change in
         its contents.  A new menu bar is constructed and
         compared with the current one in g.context to determine
         this.
**/

and mapwalk.config.mb (barflags) = valof
$( let gl = g.cm.s!m.cmlevel
   barflags!0 := m.sd.act
   move (barflags, barflags+1, 5)
   if g.cm.s!m.cmlevel = 5 do
   $( barflags!m.box2 := m.sd.wblank   // no Options
      barflags!m.box6 := m.sd.wblank   // no Find
   $)
   if g.cm.s!m.cmlevel = 0 do
      barflags!m.box3 := m.sd.wblank   // no Out
   unless g.cm.s!m.photos do
      barflags!m.box4 := m.sd.wblank   // no Photo
   unless g.cm.s!m.texts do
      barflags!m.box5 := m.sd.wblank   // no Text
   resultis g.cm.cmpw (barflags, g.menubar, 6) ~= -1
$)             // ie. display if different


/**
         function g.cm.cmpw (vector 1, vector 2, number of words)
         returns the offset to the first differing word of the
         vectors within the given number of words, or -1 for
         identical.
         There is no check that the number of words is within the
         actual length of the vectors.
**/

and g.cm.cmpw (v1, v2, n) = valof
$( let x = 0
   $( unless v1!x = v2!x resultis x    // different - return offset
      x := x+1
   $)  repeatuntil x = n
   resultis -1                         // same
$)
.
