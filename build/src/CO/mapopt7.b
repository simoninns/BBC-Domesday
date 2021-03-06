//  UNI SOURCE  4.87

section "mapopt7"

/**
         CO.MAPOPT7-Options Storage and Calculations Routines
         ------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         28.4.86  1        DNH         Initial version
         20.5.86  2        DNH         g.co.unstore.point
         30.9.87  3        MH          update to measure which enables the
                                       user to measure across maps

         g.co.store.point
         g.co.unstore.point
         g.co.calculate.distance
         g.co.calculate.area
         g.co.area.complete
**/

// needs "flar1"
// needs "flar2"
// needs "flconv"
// needs "flsqrt"

get "H/libhdr.h"
// get "H/fphdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/sdhd.h"
get "H/cmhd.h"
get "H/cm3hd.h"


/**
         G.CO.STORE.POINT-Stores screen coords of current
                                 pointer position
         --------------------------------------------------

         FUNCTION more space:=g.co.store.point ()

         INPUTS: implicit,g.xpoint,g.ypoint

         OUTPUTS: none

         GLOBALS MODIFIED: map static measure vector

         SPECIAL NOTES FOR CALLERS: rather OTT,mostly due to
         the problems of finishing an area with a limited number
         of points.  For the benefit of Distance the last point
         is always moved one down the vector,enabling the
         cumulative distance to be calculated over any number of
         points.  Area can only be invoked when all its points
         are stored at once,though I now believe it would be
         possible to calculate the area incrementally as well.
         However movement from Distance to Area,preserving the
         current set of points,precludes the use of such an
         algorithm without further complications.

         PROGRAM DESIGN LANGUAGE:
         more space:=g.co.store.point ()
            make some room,if necessary
            store new point
            increment pointers
            return boolean status of 'more space'/'vector full'
         end function
**/

let g.co.store.point ()=valof
$(
   let measure=g.cm.s!m.measure
   let last.point.ptr=measure+m.v.last.point

   if measure!m.v.next.point.ptr > last.point.ptr do        // (vec is full)
      // shuffle last back one to make room; store second last point in case
      // we need to reinstate it using g.co.unstore.point ().
   $(
      measure!m.v.second.last.x:=last.point.ptr!(-2)
      measure!m.v.second.last.y:=last.point.ptr!(-1)
      move (last.point.ptr,last.point.ptr-2,2)
      measure!m.v.next.point.ptr:=last.point.ptr
   $)
   measure!m.v.next.point.ptr!0:=g.xpoint      // store the coordinates
   measure!m.v.next.point.ptr!1:=g.ypoint      // in graphics units
   measure!m.v.next.point.ptr!(0+m.v.to.x.y):=G.cm.s!m.measure!m.v.co.relx
   measure!m.v.next.point.ptr!(1+m.v.to.x.y):=G.cm.s!m.measure!m.v.co.rely
   measure!m.v.next.point.ptr:=measure!m.v.next.point.ptr+2
                                       // increment pointer for next time
   if measure!m.v.next.point.ptr > last.point.ptr do
      measure!m.v.full:=true
   resultis ~measure!m.v.full          // true if vector not yet full
$)


/**
         G.CO.UNSTORE.POINT ()-Undoes the last point stored
         ----------------------------------------------------

         PROCEDURE g.co.unstore.point ()

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: map static vector

         SPECIAL NOTES FOR CALLERS:
         Pulls the last but one point out of a special location
         in the measure vector,so may only be called after an
         overflow situation.
         Will always succeed.

         PROGRAM DESIGN LANGUAGE:
         g.co.unstore.point ()
            shuffle last and second last points up one
            reinstate the old second last point in the gap
         end procedure
**/

let g.co.unstore.point () be
$(
   let last.point.ptr=g.cm.s!m.measure+m.v.last.point
      // shuffle second last point onto last point
   move (last.point.ptr-2,last.point.ptr,2)
      // reinstate old second last point
   last.point.ptr!(-2):=g.cm.s!m.measure!m.v.second.last.x
   last.point.ptr!(-1):=g.cm.s!m.measure!m.v.second.last.y
$)

/**
         G.CO.CALCULATE.DISTANCE-Cumulative distance
                                       calculations
         ---------------------------------------------

         PROCEDURE g.co.calculate.distance ()

         Uses floating point package to do pythagoras on the
         latest line.  Given pixels on BBC our longest line is a
         screen diagonal: sqr (1280)+sqr (888 * 13 / 12) is the
         largest number we will get,within Floating Point
         accuracy.  The square root of this is added to the fixed
         point cumulative distance,held at the front of the
         'measure' vector.

         INPUTS: implicit,from measure vector

         OUTPUTS: none

         GLOBALS MODIFIED: measure vector FP value

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.co.calculate.distance ()
            [see comments at ends of lines]
         end procedure
**/

let g.co.calculate.distance () be
$(
   let measure=g.cm.s!m.measure
   let dxsq=vec fp.len   // delta x squared
   let dysq=vec fp.len
   let temp=vec fp.len
   let temp2 =dysq       // recycle vector
   let result=dxsq       // recycle vector
   let old.point.ptr=measure!m.v.next.point.ptr-4

   let dx=vec fp.len        // delta x
   let dy=vec fp.len        // delta y

   cal.len(old.point.ptr!0,old.point.ptr!2,G.cm.s!m.measure!m.v.co.xdir,dx,false)
   cal.len(old.point.ptr!1,old.point.ptr!3,G.cm.s!m.measure!m.v.co.ydir,dy,true)
   fmult (dx,dx,dxsq)                     // dxsq:=dx * dx
      // handle y-axis scaling for screen distortion
   fmult (dy,ffloat (13,temp2),temp)       // dy:=dy * 13
   fdiv (temp,ffloat (12,temp2),temp)        // dy:=dy / 12 (rounded)
   fmult (temp,temp,dysq)                     // dysq:=dy * dy
   fplus (dxsq,dysq,temp)                     // sum :=dxsq+dysq
   fsqrt (temp,result)                         // result:=sqrt (sum)
                                                // total:=total+result
   fplus (result,measure+m.v.value,measure+m.v.value)
$)


and cal.len(pos1,pos2,dir,len,y) be   //calculates distance from last point
$(
   let t1=vec fp.len  //temporary work loactions
   let t2=vec fp.len
   let t3=vec fp.len
   let t4=vec fp.len
   let w.h=m.sd.disw  //width or height may be update to m.sd.dish

   if y w.h:=m.sd.dish
   test dir < 0 then
   $( fminus(ffloat(w.h,t1),ffloat(pos2,t2),t3) //t3=w.h-pos1
      fplus(ffloat(pos1,t1),t3,t2) //t2=pos1+t3
      fmult(ffloat(((-dir)-1),t1),ffloat(w.h,t3),t4) //t4=h.w*((-dir)-1)
      fplus(t2,t4,len)
   $)
   else
   $( fminus(ffloat(w.h,t1),ffloat(pos1,t2),t3) //t3=w.h-pos1
      fplus(t3,ffloat(pos2,t2),t1) //t1=t1+pos2
      fmult(ffloat((dir-1),t2),ffloat(w.h,t3),t4) //t4=w.h*(dir-1)
      fplus(t1,t4,len)
   $)
$)

and cal.pos(pos,dir,len,y) be  //calculates screen co-ordinates from
$(                             //start of 1st position
   let t1=vec fp.len  //temporary work loactions
   let t2=vec fp.len
   let t3=vec fp.len
   let t4=vec fp.len
   let w.h=m.sd.disw  //width or height may be update to m.sd.dish

   if y w.h:=m.sd.dish
   test dir < 0 then
   $( fminus(ffloat(pos,t2),ffloat(w.h,t1),t3) //t3=pos2-w.h
      fmult(ffloat(((-dir)-1),t1),ffloat(w.h,t2),t4) //t4=h.w*((-dir)-1)
      fminus(t3,t4,len)
   $)
   else
   $( ffloat(w.h,t3) //t3=w.h
      fplus(t3,ffloat(pos,t2),t1) //t1=t3+pos2
      fmult(ffloat((dir-1),t2),ffloat(w.h,t3),t4) //t4=w.h*(dir-1)
      fplus(t1,t4,len)
   $)
$)

/**
         G.CO.CALCULATE.AREA-Area calculation on completion of
                                    a closed polygon.
         --------------------------------------------------------

         PROCEDURE g.co.calculate.area ()

         This calculation deals with relatively small values and
         should never overflow.

         Area value is left in g.cm.s!m.measure+m.v.value in
         units of scaled square pixels ready to be output by
         g.co.show.value ().

         INPUTS: implicit,in map static measure vector

         OUTPUTS: none

         GLOBALS MODIFIED: result value in measure vector

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.co.calculate.area ()
            close the polygon exactly
            zero the FP result value
            sum the trapezium areas in square graphics units
            [ using Martin Porter's formula
            divide by 2 to get area
         end procedure
**/


and g.co.calculate.area () be
$(
   let measure=g.cm.s!m.measure
   let end.ptr=measure!m.v.next.point.ptr-2 // last point recorded
   let p=measure+m.v.first.point            // pointer into coordinates
   let a.total=measure+m.v.value            // pointer to result field
   let a.increment=vec fp.len
   let x1=vec fp.len                          // coordinates storage
   let y1=vec fp.len
   let x2=vec fp.len
   let y2=vec fp.len
   let x.offset=vec fp.len
   let y.offset=vec fp.len
   let x.smallest,y.smallest=0,0
   let temp=a.increment                       // recycle vector
   //calculate offset as negative numbers give wrong results
   ffloat(0,x.offset)  //initialise offsets
   ffloat(0,y.offset)
   move (p,end.ptr,2)
   $( p:=p+2
      if p!m.v.to.x.y < x.smallest x.smallest:=p!m.v.to.x.y
      if p!(m.v.to.x.y+1) < y.smallest y.smallest:=p!(m.v.to.x.y+1)
   $) repeatuntil p=end.ptr
   if x.smallest < 0 then
   $( let t=vec fp.len
      ffloat(-x.smallest,x.offset)
      ffloat(m.sd.disw,t)
      fmult(t,x.offset,x.offset)
   $)
   if y.smallest < 0 then
   $( let t=vec fp.len
      ffloat(-y.smallest,y.offset)
      ffloat(m.sd.dish,t)
      fmult(t,y.offset,y.offset)
   $)
   // first set the last point to complete the figure by setting it to the
   // same as,rather than within one pixel of,the first point.
   end.ptr:=measure!m.v.next.point.ptr-2 // last point recorded
   p:=measure+m.v.first.point            // pointer into coordinates
   move (p,end.ptr,2)

   // now initialise the area total value to 0
   ffloat (0,a.total)

   // float first points into temporary vectors
    cal.pos(p!0,p!m.v.to.x.y,x2,false)
    fplus(x.offset,x2,x2)
    cal.pos(p!1,p!(1+m.v.to.x.y),y2,true)
    fplus(y.offset,y2,y2)
   // now sum the area: "2A=(sum for each line (X2-X1)*(Y2+Y1))"
   // (this is a trapezium formula).
   $(
      p:=p+2       // point to next coordinate pair
      move (x2,x1,fp.len+1)
      move (y2,y1,fp.len+1)
      cal.pos(p!0,p!m.v.to.x.y,x2,false)
      fplus(x.offset,x2,x2)
      cal.pos(p!1,p!(1+m.v.to.x.y),y2,true)
      fplus(y.offset,y2,y2)
      fmult (fminus (x2,x1,x1),fplus (y2,y1,y1),a.increment)
      fplus (a.total,a.increment,a.total)
   $) repeatuntil p=end.ptr

   // A:=2A / 2
   fdiv  (a.total,ffloat (2,temp),a.total)
$)


/**
         G.CO.AREA.COMPLETE-Test for polygon completed
         -----------------------------------------------

         FUNCTION is complete:=g.co.area.complete ()

         INPUTS: implicit,in static measure vector

         OUTPUTS: Returns true => area is complete,
                          false otherwise

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         is.complete=g.co.area.complete ()
            if 2 points or fewer have been plotted
               RETURN false
            endif
            if last point within one pixel of 2nd last point
               RETURN true
            else
               RETURN false
            endif
         end function
**/

and g.co.area.complete ()=valof
$(
   let measure=g.cm.s!m.measure
   unless G.cm.s!m.measure!m.v.co.relx=0 & G.cm.s!m.measure!m.v.co.rely=0 then
      resultis false
   if measure!m.v.next.point.ptr <= measure+m.v.first.point+4
      resultis false                   // too few points
   resultis within.one.pixel ( measure!m.v.first.point,
                               measure!(m.v.first.point+1),
                               measure!m.v.next.point.ptr!(-2),
                               measure!m.v.next.point.ptr!(-1) )
$)


/**
         within.one.pixel (first point x coord
                           first point y coord
                          second point x coord
                          second point y coord)
         Returns a boolean,true if the first point is within one
         pixel of the second point.  The value of 4 graphics
         units per pixel is assumed.
**/

and within.one.pixel (x1,y1,x2,y2) =
   abs (x2-x1) <= 4 & abs (y2-y1) <= 4

/**
         G.CO.DRAW.LINES()
         --------------------------------------------------------

         PROCEDURE g.co.draw.lines()

         This procedure draws an lines that intersect the newly seleted
         map.

         INPUTS: implicit,in map static measure vector

         OUTPUTS: none

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.co.draw.lines ()
            IF on 1st map THEN
               draw cross
            IF 2 or move points THEN
               set window
               draw lines
               setdefault window
         end procedure
**/


and g.co.draw.lines() be
$(
   let measure=g.cm.s!m.measure
   let end.ptr=measure!m.v.next.point.ptr  // last point recorded
   let p=measure+m.v.first.point            // pointer into coordinates
   let temp=vec fp.len
   let x,y=0,0
   let x1,y1=0,0
   let xdir,ydir=0,0
   let xdir1,ydir1=0,0
   let clip.x=vec fp.len
   let clip.y=vec fp.len
   let clip.x1=vec fp.len
   let clip.y1=vec fp.len
   let clip=false

   if G.cm.s!m.measure!m.v.co.xco=G.cm.s!m.x0 &
            G.cm.s!m.measure!m.v.co.yco=G.cm.s!m.y0 then //draw cross
   $( G.sc.movea(m.sd.display,G.cm.s!m.measure!m.v.first.point,
        G.cm.s!m.measure!(m.v.first.point+1))
      G.sc.icon(m.sd.cross1,m.sd.plot)
   $)


   move (p,end.ptr,2)
   G.sc.setwin(0,0,m.sd.disw-1,m.sd.dish-1)
   G.sc.selcol(m.sd.blue)
   if end.ptr-p > 0 then
      while end.ptr-p > 2 do
      $(
         clip:=false
         xdir:=p!m.v.to.x.y-measure!m.v.co.relx
         ydir:=p!(m.v.to.x.y+1)-measure!m.v.co.rely
         test (abs xdir) < 24 & (abs ydir < 24) then
         $( x:=no.clip.point.of(!p,xdir,false)  // IF under 16 bit size THEN
            y:=no.clip.point.of(p!1,ydir,true)  //  do fast calculation
         $)
         else
         $( slow.point.of(!p,xdir,false,clip.x)
            slow.point.of(p!1,ydir,true,clip.y)
            clip:=true
         $)
         p:=p+2
         xdir1:=p!m.v.to.x.y-measure!m.v.co.relx
         ydir1:=p!(m.v.to.x.y+1)-measure!m.v.co.rely
//         test (abs xdir1) < 24 & (abs ydir24) < 1 then //not sure how 
                                                         //'24' got here ?
         test (abs xdir1) < 24 & (abs ydir) < 1 then
         $( x1:=no.clip.point.of(!p,xdir1,false)  // IF under 16 bit size THEN
            y1:=no.clip.point.of(p!1,ydir1,true)  //  do fast calculation
            if clip then
            $( ffloat(x1,clip.x1)
               ffloat(y1,clip.y1)
            $)
         $)
         else
         $( slow.point.of(!p,xdir1,false,clip.x1)
            slow.point.of(p!1,ydir1,true,clip.y1)
            unless clip then
            $( ffloat(x,clip.x)
               ffloat(y,clip.y)
            $)
            clip:=true
         $)
         if clip then //if line needs to be cliped then use interoplation
         $(
            G.co.clip.line(clip.x,clip.y,clip.x1,clip.y1,xdir,ydir,xdir1,ydir1)
            x:=ffix(clip.x)
            y:=ffix(clip.y)
            x1:=ffix(clip.x1)
            y1:=ffix(clip.y1)
         $)
         G.sc.movea(m.sd.display,x,y)
         G.sc.linea(m.sd.plot,m.sd.display,x1,y1)
      $)
   G.sc.defwin()
$)

and no.clip.point.of(old.pos,dir,y)=VALOF //screen co-ordinate calculation
$(                                        // for under 16 bit sized.
   let h.w=y -> m.sd.dish,m.sd.disw
   let temp=dir * h.w

   old.pos:=old.pos+temp
   resultis old.pos
$)

and slow.point.of(old.pos,dir,y,new.pos) be //48 bit calculation for screen
$(                                          // coorinates greater than 16 bit
   let h.w=y -> m.sd.dish,m.sd.disw
   let t=vec fp.len
   let t1=vec fp.len

   ffloat(h.w,t)
   ffloat(dir,t1)
   fmult(t,t1,t)
   ffloat(old.pos,t1)
   fplus(t1,t,new.pos)
$)

and line.crosses.map(x,y,x1,y1) =
   ((x <= 0 & x1 >= 0) | (x >= 0 & x1 <= 0)) &
        ((y <= 0 & y1 >= 0) | (y >= 0 & y1 <= 0))
.














