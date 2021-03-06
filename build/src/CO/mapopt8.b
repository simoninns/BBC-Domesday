//  UNI SOURCE  9.87

section "mapopt8"

/**
         CM.B.MAPOPT( - Map Scale Options
         --------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
******************************* changes after master press:
         30.9.87  1        MH          Mapopt4 split and mapopt8 made

         GLOBALS DEFINED:
            g.co.band.line.to
            g.co.clip.line
**/


// needs "flar1"
// needs "flar2"
// needs "flconv"
// needs "flsqrt"

get "H/libhdr.h"
// get "H/fphdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/vhhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"
get "H/cm3hd.h"


/**
         G.CO.BAND.LINE.TO - draws line from current point to current pointer postion
         ----------------------------------------------------------------------------

         PROCEDURE g.co.band.line.to

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: various map statics

         SPECIAL NOTES FOR CALLERS: state table global

         PROGRAM DESIGN LANGUAGE:
         g.co.band.line.to()
            IF mode = band.line THEN
               draw fixed line
            ELSE
               draw EXOR'ed line
         end procedure
**/


/*
         G.co.band.line.to (routine, final x, final y)
         Draws a line from the point specified by the statics
         'g.cm.s!m.old.- xpoint, g.cm.s!m.old.ypoint' to x,y
         specified by parameters.  The plot is in the display
         area.  The colour is dark blue.  The caller may choose
         to band the line, selecting m.band.line manifest which
         XOR plots the line, or plot the line permanently,
         selecting m.fix.line.
*/

let G.co.band.line.to (plot.mode, x, y) be
$(
   let old.xpos, old.ypos=?, ?
   let routine=(plot.mode=m.band.line) -> g.sc.xor.selcol, g.sc.selcol
   if plot.mode=m.band.line & (G.cm.s!m.substate=m.distance1.substate |
             G.cm.s!m.substate=m.area1.substate |
                G.cm.s!m.substate=m.area3.substate) then
      return
   G.sc.setwin(0, 0, m.sd.disw-1, m.sd.dish-1)
   test G.cm.s!m.turn.over.pending then
   $( old.xpos:=point.of(G.cm.s!m.measure!m.v.co.oldx, G.cm.s!m.measure!m.v.co.xdir, false)
      old.ypos:=point.of(G.cm.s!m.measure!m.v.co.oldy, G.cm.s!m.measure!m.v.co.ydir, true)
   $)
   else
   $( old.xpos:=point.of(G.cm.s!m.old.xpoint, G.cm.s!m.measure!m.v.co.xdir, false)
      old.ypos:=point.of(G.cm.s!m.old.ypoint, G.cm.s!m.measure!m.v.co.ydir, true)
   $)
   g.sc.movea (m.sd.display, old.xpos, old.ypos)
   routine (m.sd.blue)
   g.sc.linea (m.sd.plot, m.sd.display, x, y)
   G.sc.defwin()
$)

and point.of(old.pos, dir, y)=VALOF  // calculates screen coordinates
$(                                   //for last fix point
   let temp=dir < 0 -> dir+1, dir-1
   let h.w=m.sd.disw

   if temp > 24 temp:=24    //if screen point greater than 16 bits then
   if temp < -24 temp:=-24  //move nearer so it can be ploted
   if y then
   $( h.w:=m.sd.dish
      old.pos:=old.pos-m.sd.disY0
   $)
   temp:=temp * h.w
   test dir < 0 then
      old.pos:=h.w+old.pos-temp
   else
      old.pos:=old.pos-h.w-temp
   if y old.pos:=old.pos+m.sd.disY0
   resultis old.pos
$)

and G.co.clip.line(x,y,x1,y1,xd,yd,xd1,yd1) be
$(
   let x2=vec fp.len
   let y2=vec fp.len
   let t=vec fp.len
   let t1=vec fp.len
   let t2=vec fp.len
   test (abs xd) > (abs yd) then
      if (abs xd) > 0 then
      $(
          test xd < 0 then
          $( ffloat(m.sd.disX0,x2)
             formula.y(y1,y,y2,x1,x,x2)
          $)
          else
          $( ffloat(m.sd.disw,x2)
             formula.y(y,y1,y2,x,x1,x2)
          $)
          move(x2,x,fp.len)
          move(y2,y,fp.len)
      $)
   else if (abs yd) > 0 then
   $(
      test yd < 0 then
      $( ffloat(0,y2)
//         formula.x(x,x1,x2,y,y1,y2) //DON'T KNOW WHAT HAPPENED TO FORMULA.X
         formula.y(x,x1,x2,y,y1,y2)
      $)
      else
      $( ffloat(m.sd.dish+m.sd.disY0,y2)
//         formula.x(x1,x,x2,y1,y,y2) //DON'T KNOW WHAT HAPPENED TO FORMULA.X
         formula.y(x,x1,x2,y,y1,y2)
      $)
      move(x2,x,fp.len)
      move(y2,y,fp.len)
   $)
   test (abs xd1) > (abs yd1) then
      if (abs xd1) > 0 then
      $(
          test xd1 < 0 then
          $( ffloat(m.sd.disX0,x2)
             formula.y(y,y1,y2,x,x1,x2)
          $)
          else
          $( ffloat(m.sd.disw,x2)
             formula.y(y,y1,y2,x,x1,x2)
          $)
          move(x2,x1,fp.len)
          move(y2,y1,fp.len)
      $)
   else if (abs yd1) > 0 then
   $(
      test yd1 < 0 then
      $( ffloat(0,y2)
         formula.y(x,x1,x2,y,y1,y2)
      $)
      else
      $( ffloat(m.sd.dish+m.sd.disY0,y2)
         formula.y(x,x1,x2,y,y1,y2)
      $)
      move(x2,x1,fp.len)
      move(y2,y1,fp.len)
   $)
$)

and formula.y(a,a1,a2,b,b1,b2) be
$(
   let t=vec fp.len
   let t1=vec fp.len
   let t2=vec fp.len

   fminus(b2,b,t)
   fminus(a1,a,t1)
   fminus(b1,b,t2)
   fmult(t,t1,t1)
   fdiv(t1,t2,t1)
   fplus(a,t1,a2)
$)
.





