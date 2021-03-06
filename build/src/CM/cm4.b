//  UNI SOURCE  4.87

section "cm4"

/**
         CM.B.CM4 - Graphics for Move and Zoom in Map
         --------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         18.2.86  1        DNH         Initial version
          9.5.86  2        DNH         shrink box not cleared

         GLOBALS DEFINED:
         g.cm.expand.frame.from
         g.cm.shrink.frame.to
         g.cm.box
         g.cm.moving.arrow
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/sdhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"

/**
         procedure g.cm.expand.frame.from (x1,y1, x2,y2) displays
         an expanding yellow framework for zoom in, starting
         from a box specified by the vertex coordinate
         parameters.
         The delay between successive frames is configurable.
         The very last box is the yellow border of the new map,
         and this is not drawn by this routine but by its caller,
         g.cm.showmap.
**/

let g.cm.expand.frame.from (x1,y1, x2,y2) be
$(
   let ix1 = x1/m.cm.frame.steps
   let iy1 = y1/m.cm.frame.steps
   let ix2 = (m.sd.disw-1-x2)/m.cm.frame.steps
   let iy2 = (m.sd.dish-1-y2)/m.cm.frame.steps
   let bx1, by1, bx2, by2 = x1, y1, x2, y2

   for j = 1 to m.cm.frame.steps-1
   $(
      g.cm.box (true,  bx1, by1, bx2, by2)   // draw new one
      g.ut.wait (m.cm.frame.pause)
      bx1, by1, bx2, by2 := bx1-ix1, by1-iy1, bx2+ix2, by2+iy2
      g.cm.box (false, bx1+ix1, by1+iy1, bx2-ix2, by2-iy2)  // clear old box
   $)           // don't draw the very last box.  Yellow border done later
$)


/**
         procedure g.cm.shrink.frame.to (x1,y1, x2,y2) displays
         the shrinking yellow framework during the dark interval
         of a zoom out.  It is configurable with values in the
         code. There is a trade-off between speed and smoothness.
         The last box remains on the screen until cleared
         elsewhere in the system.
**/

and g.cm.shrink.frame.to (x1, y1, x2, y2) be
$(
   let ix1 = x1/m.cm.frame.steps
   let iy1 = y1/m.cm.frame.steps
   let ix2 = (m.sd.disw-1-x2)/m.cm.frame.steps
   let iy2 = (m.sd.dish-1-y2)/m.cm.frame.steps
   let bx1, by1, bx2, by2 = 0, 0, m.sd.disw-1, m.sd.dish-1

   for j = 1 to m.cm.frame.steps-1
   $(
      g.cm.box (true,  bx1, by1, bx2, by2)   // draw new box
      g.ut.wait (m.cm.frame.pause)
      bx1, by1, bx2, by2 := bx1+ix1, by1+iy1, bx2-ix2, by2-iy2
      g.cm.box (false, bx1-ix1, by1-iy1, bx2+ix2, by2+iy2)  // draw new one
   $)
   g.cm.box (true,  x1, y1, x2, y2)          // absolute position for final box

   if g.cm.s!m.cmlevel = 1 | g.cm.s!m.cmlevel = 2 do
   $( g.cm.s!m.substate := m.box.clear.pending.substate
      g.cm.s!m.old.a0 := x1                  // save final coordinates
      g.cm.s!m.old.b0 := y1
      g.cm.s!m.old.a1 := x2
      g.cm.s!m.old.b1 := y2
      g.cm.s!m.old.xpoint := g.xpoint        // and current pointer position
      g.cm.s!m.old.ypoint := g.ypoint
   $)                   // final box cleared in mapwal when pointer moves
$)


/**
         procedure g.cm.box (show it flag, x1,y1, x2,y2) displays
         in the current graphics colour or clears a box using the
         bottom left and top right coordinates.  It turns the
         screen pointer off before starting and finally restores
         it to what it was.
**/

and g.cm.box (show.it, x1, y1, x2, y2) be
$(                              //  show or clear a box in the display area
   let old.ptr = g.sc.pointer (m.sd.off)
   let f = show.it -> m.sd.plot, m.sd.clear
   if x2 >= m.sd.disw do x2 := m.sd.disw-1    // upper bound checks.
   if y2 >= m.sd.dish do y2 := m.sd.dish-1      // (no lower bound check)
   g.sc.movea (m.sd.display, x1, y1)
   g.sc.linea (f, m.sd.display, x2, y1)
   g.sc.linea (f, m.sd.display, x2, y2)
   g.sc.linea (f, m.sd.display, x1, y2)
   g.sc.linea (f, m.sd.display, x1, y1)
   g.sc.pointer (old.ptr)
$)


/**
         procedure g.cm.moving.arrow (dir, is second stage flag)
         does one half of the actual moving arrow procedure.
**/

and g.cm.moving.arrow (dir, is.second.stage) be
$(
   let x, y, inx, iny, p, a = ?,?,?,?,?,?

      // convertion table to get row number from direction.
      // contains all valid directions.
   let ct = table
    //      N   S       E  NE  SE        W  NW  SW
       -1,  0,  1, -1,  2,  3,  4,  -1,  5,  6,  7

      // table holding coordinate values
      // for the arrow itself
   let arrow.table = table
   // ix1  iy1  ix2  iy2
      -24, -48, +48,   0,     // N
      +24, +48, -48,   0,     // S
      -48, +24,   0, -48,     //  E
      -48, -12, +36, -36,     // NE
      -12, +48, -36, -36,     // SE
      +48, -24,   0, +48,     //  W
      +12, -48, +36, +36,     // NW
      +48, +12, -36, +36      // SW

      // table holding information about where to display the arrow
      // The increment values rely on 6 steps.
   let position.table = table
   // inx  iny    x    y
        0, +65, 640,  56,     // N
        0, -65, 640, 832,     // S
      +98,   0,  56, 444,     //  E
      +98, +65,  56,  56,     // NE
      +98, -65,  56, 832,     // SE
      -98,   0,1224, 444,     //  W
      -98, +65,1224,  56,     // NW
      -98, -65,1224, 832      // SW


   p := position.table + ct!dir * 4      // pointers into tables
   a := arrow.table    + ct!dir * 4
   inx := p!0           // get increments from table
   iny := p!1
   test is.second.stage then
   $( x := p!2          // get initial position from table
      y := p!3
   $)
   else
   $( x := 640          // initialise position to centre of screen
      y := 444
   $)

   for pos = 1 to m.cm.arrow.steps do
   $(
      arrow (true, a, x, y)
      g.ut.wait (m.cm.arrow.pause)
      arrow (false, a, x, y)
      x := x+inx           // add increments to absolute positions
      y := y+iny
   $)
$)


/**
         procedure arrow (show it flag, a, x, y,) displays in the
         current graphics colour (or clears) an arrow using the
         coords of the arrow and the initial xy position.
**/

and arrow (show.it, a, x, y) be
$(
   let f = show.it -> m.sd.plot, m.sd.clear
   g.sc.movea (m.sd.display, x, y)
   g.sc.triangle (f, a!0, a!1, a!2, a!3)
$)
.
