//  UNI SOURCE  6.87

/**
22.      WALK - NATIONAL WALK AND GALLERY
         --------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.WALK

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         (Notes on previous versions deleted 7.10.86 NRY to make room.)
         ***************************************************
         8.6.87    1       MFP         CHANGES FOR UNI
         16.9.87   2       MH          changes to PLAN
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNWhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/vhhd.h"
get "H/nwhd.h"

static $( direction = ?; plan = ? $)
let r(d) = g.ut.unpack16.signed(g.nw,d+d)
and ru(d) = g.ut.unpack16(g.nw,d+d)

/**
         clear.() clears the message and display areas if
         necessary
**/

let clear.() be
$(  if g.nw!wmess do $(  g.sc.clear(m.sd.message); g.nw!wmess := false $)
    if g.nw!wdisp do $(  g.sc.clear(m.sd.display); g.nw!wdisp := false $)
$)
/**
         arrow.(x,y,dir) draws an arrow at (x,y) in direction
         dir.
**/


and ingallery.() = valof // g.nw!m.syslev = 1 until 15.7.86
$(  let s = g.context!m.state
    if s = m.st.gallery | s = m.st.galmove |
       s = m.st.gplan1 | s = m.st.gplan2 |
       s = m.st.detail & g.nw!gallerydetail resultis true
    resultis false
$)


and arrow.(x,y,dir) be
$(  let cosa = dir ! table 10,  7,  0, -7,-10, -7,  0,  7
    let sina = dir ! table  0,  7, 10,  7,  0, -7,-10, -7
    g.sc.setwin(0, 0, m.sd.disw-1, m.sd.dish-1)  // addition of 15.7.86
    g.sc.selcol(m.sd.blue)
    g.sc.movea(m.sd.display, x-cosa-7*sina, y+sina-7*cosa)
                // '-7' terms added 15.7.86
    g.sc.parallel(m.sd.plot, 5*sina, 5*cosa, 2*cosa, -2*sina)
    g.sc.movea(m.sd.display, x+3*sina, y+3*cosa)
    g.sc.triangle(m.sd.plot, 3*cosa-5*sina, -3*sina-5*cosa, -6*cosa, 6*sina)
    g.sc.defwin() // addition of 15.7.86
    g.nw!wdisp := true  // something in display area
$)

and g.nw.init2() be   // initialisation routine for 'Plan'
$(  let position = (g.nw!view-1)/8*2
    let x, y = ru(g.nw!ptable+position+1), ru(g.nw!ptable+position)
    plan := y >> 12
    direction := (8-(x >> 12)+g.nw!view) rem 8    // -1 removed 14.7.86
    g.sc.pointer(m.sd.off) // added 8.9.86
    clear.()
    G.nw.showframe.(g.nw!m.baseplan+g.nw!m.baseview+plan)// adjustment 14.7.86
    arrow.(x & #XFFF, y & #XFFF, direction)
    g.sc.pointer(m.sd.on) // added 8.9.86
$)

and g.nw.action2() be  // added 15.7.86
$( if g.nw!vrestore do
   $(  g.vh.video(m.vh.video.on)
       g.nw!vrestore := false
   $)
   if G.key = m.kd.change & G.screen = m.sd.display then
   $(
      let position = (G.nw!view-1)/8*2
      let north = ?
      let new.dir = ?

      direction := (direction + 1) rem 8
      north := ru(G.nw!ptable + position + 1)
      new.dir := (((north >> 12) rem 8) + direction) rem 8  //get correct position
      if new.dir = 0 new.dir := 8
      G.nw!view := (position / 2 * 8) + new.dir //set to correct frame
      G.sc.clear(m.sd.display)
      arrow.(ru(G.nw!ptable + position + 1) & #xFFF,
              ru(G.nw!ptable + position) & #xFFF, direction)
   $)
   if G.key = m.kd.action & G.screen = m.sd.display then
   $( let len.sq = vec 1   //shortest distance to a valid position
      let len1.sq = vec 1  //temp store
      let position = 0 // set to 1st position
      let old.pos = (G.nw!view-1)/8*2
      let x, y = G.xpoint, G.ypoint
      let a = (ru(G.nw!ptable + 1) & #xFFF) - x  // horizontal distance
      let b = (ru(G.nw!ptable) & #xFFF) - y      // vertical distance

      dis.sq(a, b, len.sq)  //set len.sq to 1st position in ptable
      for i = 2 to G.nw!dtable - G.nw!ptable - 2 by 2 do
      $( let p = ru(G.nw!ptable + i)  >> 12
         a := (ru(G.nw!ptable + i + 1) & #xFFF) - x
         b := (ru(G.nw!ptable + i) & #xFFF) - y
         dis.sq(a, b, len1.sq)
         if G.ut.cmp32(len1.sq, len.sq) = m.lt & p = plan then
         $(
            G.ut.mov32(len1.sq, len.sq)
            position := i
         $)
      $)
      G.sc.clear(m.sd.display)
      unless G.nw!m.syslev = 1 & ingallery.() then
         test ingallery.() & G.nw!m.syslev ~= 1 then
            if position = G.nw!base.pos - 2 then
               position := G.nw!base.pos + 4
         else if position = G.nw!base.pos then
            position := G.nw!base.pos + 4
      arrow.(ru(G.nw!ptable + position + 1) & #xFFF,
              ru(G.nw!ptable + position) & #xFFF, direction)
      x := ru(G.nw!ptable + position + 1)
      y := (((x >> 12) rem 8) + direction) rem 8  //get correct position
      if y = 0 y := 8
      G.nw!view := (position / 2 * 8) + y //set to correct frame
   $)
$)

// dis.sq returns (a*a) + (b*b) in len.sq
and dis.sq(a, b, len.sq) be
$(
   let A.SQ = vec 1
   let B.SQ = vec 1

   if a < 0 a := -a
   if b < 0 b := -b
   G.ut.set32(a, 0, A.SQ)
   G.ut.mul32(A.SQ, A.SQ)
   G.ut.set32(b, 0, B.SQ)
   G.ut.mul32(B.SQ, B.SQ)
   G.ut.add32(B.SQ, A.SQ)
   G.ut.mov32(A.SQ, len.sq)
$)
