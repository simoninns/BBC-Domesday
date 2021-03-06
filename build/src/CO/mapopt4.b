//  UNI SOURCE  4.87

section "mapopt4"

/**
         CM.B.MAPOPT4 - Map Scale Options
         --------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         25.4.86  1        DNH         Initial version
         14.5.86  2        DNH         changes to unitsini
         16.5.86  3        DNH         banding lines in
          9.6.86  4        DNH         g.cm.daini gone
         10.6.86  5        DNH         real g.sc.xor.selcol
         27.6.86  6        DNH         get rid of statics
          8.7.86  7        DNH         unmute video after Help
         30.7.86  8        DNH         fix zero value display
******************************* changes after master press:
         17.12.86 9        DNH         shifted cursor key move
         03.12.87 10       MH          A500 version - fix pointer
                                       handling

         GLOBALS DEFINED:
            g.cm.scaini ()
            g.cm.mapsca ()
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/vhhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"
get "H/cm3hd.h"

static $( dir.turn=? $)

/**
         G.CM.SCAINI - Init. Routine for Map Scale Operation
         ---------------------------------------------------

         PROCEDURE g.cm.scaini ()

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: various map statics

         SPECIAL NOTES FOR CALLERS: state table global

         PROGRAM DESIGN LANGUAGE:
         g.cm.scaini ()
            switch off pointer
            set substate to distance1
            show current units in message area
            clear value boxes
            set statics for pointer screen position to invalid
         end procedure
**/

let g.cm.scaini () be
$(
   g.sc.pointer (m.sd.off)
   g.cm.s!m.substate:=m.distance1.substate
   g.co.show.units ()         // (including scale bar if in distance)
   g.co.options.clear ()
   g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=-1, -1 // init to invalid
   G.cm.s!m.measure!m.v.co.xco, G.cm.s!m.measure!m.v.co.yco:=-1, -1
$)


/**
         G.CM.SCAINI - Action Routine for Map Scale Operations
         -----------------------------------------------------

         PROCEDURE g.cm.scaini

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: various map statics

         SPECIAL NOTES FOR CALLERS: state table global

         PROGRAM DESIGN LANGUAGE:
         g.cm.mapsca ()
            if no key pressed
               switch off pointer
            if necessary unmute video
            [ handle key presses, changing substate as required.
            [ Routines from other modules, particularly mapopt6
            [ are used to calculate and display values etc.
            [ It is not justified to try to PDL this routine
            [ fully.
            redraw menu bar if necessary
            switch on pointer
         end procedure
**/

let g.cm.mapsca () be
$(
   let ermess.="Move not available in Scale at this level"
   let barflags=table ?,?,?,?,?,?
   let dispflags=m.cm.frame.bit | m.cm.graphics.bit | m.cm.messages.bit
                               // graphics but no icons (nor border)
   let old.substate=g.cm.s!m.substate

   unless g.key=m.kd.noact do g.sc.pointer (m.sd.off)
   if g.cm.s!m.data.accessed do           // unmute video after Help
   $( g.vh.video (m.vh.video.on)
      g.cm.s!m.data.accessed:=false
   $)
   if g.cm.s!m.turn.over.pending do    // look for a reply to "Eject disc?"
   $( g.cm.turn.over.reply ()
      unless g.cm.s!m.turn.over.pending do
      $( G.cm.s!m.old.xpoint, G.cm.s!m.old.ypoint:=G.cm.s!m.measure!m.v.co.oldx, G.cm.s!m.measure!m.v.co.oldy
         g.co.show.units()      // redisplay in message area
           if capch(G.key)='Y' then
           $( unless (dir.turn & m.n)=0 then
               $( G.cm.s!m.measure!m.v.co.ydir:=G.cm.s!m.measure!m.v.co.ydir+1
                  G.cm.s!m.measure!m.v.co.rely:=G.cm.s!m.measure!m.v.co.rely+1
               $)
               unless (dir.turn & m.e)=0 then
               $( G.cm.s!m.measure!m.v.co.xdir:=G.cm.s!m.measure!m.v.co.xdir+1
                  G.cm.s!m.measure!m.v.co.relx:=G.cm.s!m.measure!m.v.co.relx+1
               $)
               unless (dir.turn & m.s)=0 then
               $( G.cm.s!m.measure!m.v.co.ydir:=G.cm.s!m.measure!m.v.co.ydir-1
                  G.cm.s!m.measure!m.v.co.rely:=G.cm.s!m.measure!m.v.co.rely-1
               $)
               unless (dir.turn & m.w)=0 then
               $( G.cm.s!m.measure!m.v.co.xdir:=G.cm.s!m.measure!m.v.co.xdir-1
                  G.cm.s!m.measure!m.v.co.relx:=G.cm.s!m.measure!m.v.co.relx-1
               $)
              G.co.draw.lines()
              G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                            g.cm.s!m.old.pointer.y)
           $)
      $)
   $)
   switchon g.key into
   $(
      case m.kd.noact:                    // handle 'banding' of lines
         // only do banding if in correct substate and pointer has moved
         if (old.substate=m.distance2.substate |
             old.substate=m.distance3.substate |
             old.substate=m.area2.substate) &
            (g.xpoint ~= g.cm.s!m.old.pointer.x |
             g.ypoint ~= g.cm.s!m.old.pointer.y) do
         $(
            if g.cm.s!m.old.pointer.x ~= -1 do  // unband last line on screen
            $(
//               g.sc.pointer (m.sd.off) -removed 03.12.87 MH
               G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                                                      g.cm.s!m.old.pointer.y)
            $)

            test g.screen=m.sd.display then   // band new line to pointer
            $(
//               g.sc.pointer (m.sd.off) // -removed 03.12.87 MH
               G.co.band.line.to (m.band.line, g.xpoint, g.ypoint)
               g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=g.xpoint,
                                                                     g.ypoint
            $)
            else
               g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=-1, -1    // set to invalid
         $)
         endcase

      case m.kd.return:
         if g.cm.s!m.old.pointer.x ~= -1 do           // clear old banding line
            G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y)

         if g.screen=m.sd.display do
         $(
            switchon old.substate into
            $(
               case m.distance1.substate:    // enter Distance2 substate
               case m.area1.substate:        // enter Area2 substate
                  G.cm.s!m.measure!m.v.co.relx, G.cm.s!m.measure!m.v.co.rely:=0, 0
                  G.cm.s!m.measure!m.v.co.xdir, G.cm.s!m.measure!m.v.co.ydir:=0, 0
                  g.co.store.point ()
                  G.cm.s!m.measure!m.v.co.xco:=G.cm.s!m.x0
                  G.cm.s!m.measure!m.v.co.yco:=G.cm.s!m.y0
                  g.sc.movea (m.sd.display, g.xpoint, g.ypoint)
                  g.sc.icon (m.sd.cross1, m.sd.plot)  // dark blue cross icon
                  g.cm.s!m.old.xpoint, g.cm.s!m.old.ypoint:=g.xpoint, g.ypoint  // store for banding
                  g.cm.s!m.substate:=old.substate=m.distance1.substate ->
                                                          m.distance2.substate,
                                                          m.area2.substate
                  g.co.show.value ()         // shows a '0' if distance2
                  endcase

               case m.distance2.substate:
               case m.distance3.substate:
                  G.co.band.line.to (m.fix.line, g.xpoint, g.ypoint)
                  g.cm.s!m.old.xpoint, g.cm.s!m.old.ypoint:=g.xpoint,
                                                                     g.ypoint
                  g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=-1, -1

                  unless g.co.store.point () do       // false => vector full
                     g.cm.s!m.substate:=m.distance3.substate

                                                      // (blanks "Area" in MB)
                  g.co.calculate.distance ()
                  g.co.show.value ()                  // show distance so far
                  G.cm.s!m.measure!m.v.co.xdir, G.cm.s!m.measure!m.v.co.ydir:=0, 0
                  endcase

               case m.area2.substate:   // record point; show area if complete
               $( let rc=?
                  rc:=g.co.store.point ()
                  if g.co.area.complete () do
                  $( g.co.calculate.area ()
                     g.cm.s!m.substate:=m.area3.substate     // completed
                     g.co.show.value ()
                  $)
                                       // only fix line if point stays
                  test rc | g.co.area.complete () then
                  $( G.co.band.line.to (m.fix.line, g.xpoint, g.ypoint)
                                       // set point
                     g.cm.s!m.old.xpoint, g.cm.s!m.old.ypoint:=g.xpoint,
                                                                     g.ypoint
                     g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=-1, -1
                     G.cm.s!m.measure!m.v.co.xdir, G.cm.s!m.measure!m.v.co.ydir:=0, 0
                  $)
                  else
                  $( g.co.unstore.point ()   // allow more chances to complete
                     g.sc.pointer (m.sd.on)
                     g.sc.ermess ("Too many points/lines")     // give warning
                     g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=-1, -1
                        // (we have already unbanded the last line)
                  $)
                  endcase
               $)

               case m.area3.substate:  // area completed...
                  g.sc.beep ()         // ... can't do any more until Cleared
                  endcase
            $)
         $)
         endcase

      case m.kd.tab:                // handle sideways moves
         test G.cm.s!m.cmlevel=1 then
            G.sc.ermess(ermess.)
         else if g.screen=m.sd.display do
         $( let direc=g.cm.direction ()
            unless direc=m.invalid do
            $(
               if g.cm.go (direc, dispflags) then
               $( unless (direc & m.n)=0 then
                  $( G.cm.s!m.measure!m.v.co.ydir:=G.cm.s!m.measure!m.v.co.ydir+1
                     G.cm.s!m.measure!m.v.co.rely:=G.cm.s!m.measure!m.v.co.rely+1
                  $)
                  unless (direc & m.e)=0 then
                  $( G.cm.s!m.measure!m.v.co.xdir:=G.cm.s!m.measure!m.v.co.xdir+1
                     G.cm.s!m.measure!m.v.co.relx:=G.cm.s!m.measure!m.v.co.relx+1
                  $)
                  unless (direc & m.s)=0 then
                  $( G.cm.s!m.measure!m.v.co.ydir:=G.cm.s!m.measure!m.v.co.ydir-1
                     G.cm.s!m.measure!m.v.co.rely:=G.cm.s!m.measure!m.v.co.rely-1
                  $)
                  unless (direc & m.w)=0 then
                  $( G.cm.s!m.measure!m.v.co.xdir:=G.cm.s!m.measure!m.v.co.xdir-1
                     G.cm.s!m.measure!m.v.co.relx:=G.cm.s!m.measure!m.v.co.relx-1
                  $)
                  G.co.draw.lines()
                  G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                                                      g.cm.s!m.old.pointer.y)
               $)
               if G.cm.s!m.turn.over.pending dir.turn:=direc
            $)
         $)
         endcase

      case m.kd.S.left:
         test G.cm.s!m.cmlevel=1 then
            G.sc.ermess(ermess.)
         else
         $(
            G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                                                g.cm.s!m.old.pointer.y)
            if g.cm.go (m.w, dispflags) then
            $( G.cm.s!m.measure!m.v.co.xdir:=G.cm.s!m.measure!m.v.co.xdir-1
               G.cm.s!m.measure!m.v.co.relx:=G.cm.s!m.measure!m.v.co.relx-1
               G.co.draw.lines()
            $)
            if G.cm.s!m.turn.over.pending dir.turn:=m.w
            G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                                                g.cm.s!m.old.pointer.y)
         $)
         endcase

      case m.kd.S.right:
         test G.cm.s!m.cmlevel=1 then
            G.sc.ermess(ermess.)
         else
         $(
            if g.cm.go (m.e, dispflags) then
            $( G.cm.s!m.measure!m.v.co.xdir:=G.cm.s!m.measure!m.v.co.xdir+1
               G.cm.s!m.measure!m.v.co.relx:=G.cm.s!m.measure!m.v.co.relx+1
               G.co.draw.lines()
               G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                                                   g.cm.s!m.old.pointer.y)
            $)
            if G.cm.s!m.turn.over.pending dir.turn:=m.e
         $)
         endcase

      case m.kd.S.up:
         test G.cm.s!m.cmlevel=1 then
            G.sc.ermess(ermess.)
         else
         $(
            if g.cm.go (m.n, dispflags) then
            $( G.cm.s!m.measure!m.v.co.ydir:=G.cm.s!m.measure!m.v.co.ydir+1
               G.cm.s!m.measure!m.v.co.rely:=G.cm.s!m.measure!m.v.co.rely+1
               G.co.draw.lines()
               G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                                                   g.cm.s!m.old.pointer.y)
            $)
            if G.cm.s!m.turn.over.pending dir.turn:=m.n
         $)
         endcase

      case m.kd.S.down:
         test G.cm.s!m.cmlevel=1 then
            G.sc.ermess(ermess.)
         else
         $(
            if g.cm.go (m.s, dispflags) then
            $( G.cm.s!m.measure!m.v.co.ydir:=G.cm.s!m.measure!m.v.co.ydir-1
               G.cm.s!m.measure!m.v.co.rely:=G.cm.s!m.measure!m.v.co.rely-1
               G.co.draw.lines()
               G.co.band.line.to (m.band.line, g.cm.s!m.old.pointer.x,
                                                   g.cm.s!m.old.pointer.y)
            $)
            if G.cm.s!m.turn.over.pending dir.turn:=m.s
         $)
         endcase


         // case m.kd.fkey3:     Units is handled by init routine

      case m.kd.fkey4:                       // "Distance" or "Clear"
         g.co.options.clear ()
         g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=-1, -1
         G.cm.s!m.measure!m.v.co.xco, G.cm.s!m.measure!m.v.co.yco:=-1, -1
         if (old.substate & m.distance.substate.bit)=0    // in from Area
         $( g.cm.s!m.substate:=m.distance1.substate  // (for correct units)
            g.co.show.units ()
         $)
         g.cm.s!m.substate:=m.distance1.substate       // always enter this
         endcase

      case m.kd.fkey5:                       // "Area" or "Clear"
         switchon old.substate into
         $(
            case m.distance1.substate:       // "Area"
               g.cm.s!m.substate:=m.area1.substate
               g.co.show.units ()
               endcase

            case m.distance2.substate:       // keep lines in Area
               g.cm.s!m.substate:=m.area2.substate
               g.co.show.units ()            // "square wotsits"
                  // we need to test for a completed area here too...
               if g.co.area.complete () do
               $( g.co.calculate.area ()
                  g.cm.s!m.substate:=m.area3.substate
                  g.co.show.value ()
               $)
               endcase

            // (case m.distance3.substate: can't occur. Blanked in menu bar)

            default:                      // all Area substates: "Clear"
               g.co.options.clear ()
               g.cm.s!m.old.pointer.x, g.cm.s!m.old.pointer.y:=-1, -1
               G.cm.s!m.measure!m.v.co.xco, G.cm.s!m.measure!m.v.co.yco:=-1, -1
               g.cm.s!m.substate:=m.area1.substate     // reinitialise
               endcase
         $)
         endcase
   $)

   if g.redraw | g.cm.s!m.substate ~= old.substate do    // things have changed
   $( let local.redraw=mapsca.config.mb (barflags)
      if g.redraw | local.redraw do g.sc.menu (barflags)
   $)
   g.sc.pointer (m.sd.on)                    // restore pointer
$)
/*
         mapsca.config.mb (barflags)
         Called when it may be necessary to redraw the menu bar
         due to a change in its contents.  It returns true if the
         menu must be redrawn.  Only function keys 0 to 5 are
         used.
*/

and mapsca.config.mb (barflags)=valof
$(
   let gl=g.cm.s!m.cmlevel
   let substate=g.cm.s!m.substate

   barflags!0:=m.sd.act
   move (barflags, barflags+1, 4)

   test (substate & m.distance.substate.bit) ~= 0 then      // in Distance op.
   $(
             // "Distance" -> "  " or "Clear"
      barflags!m.box4:=substate=m.distance1.substate ->
                                                      m.sd.wblank, m.sd.wclear
      if substate=m.distance3.substate do  // blank "Area" box
         barflags!m.box5:=m.sd.wblank
   $)
   else        // in Area operation
   $(
             // "Area" -> "  " or "Clear"
      barflags!m.box5:=substate=m.area1.substate ->
                                                      m.sd.wblank, m.sd.wclear
   $)
   resultis g.cm.cmpw (barflags, g.menubar, 5) ~= -1
$)
.








