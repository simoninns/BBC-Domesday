//  UNI SOURCE  4.87

section "cm3"

/**
         CM.B.CM3 - Move Direction Interpretation
         ----------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         18.2.86  1        DNH         Initial version

         GLOBALS DEFINED:
         g.cm.direction
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/sdhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"

/**
         procedure g.cm.direction () returns the direction of
         sideways move to be attempted given the current screen
         cursor position.  The screen display area is divided
         into a symmetrical set of regions according to
         functional spec. sect. 4.3.3.  The shapes of the regions
         may be adjusted by changing m.dve, m.dvn etc. in
         h.cm2hdr.  All values are in BBC graphics units.
         Colloquially known as the 'lozenge program'.  For fuller
         documentation of the algorithm see DNH in person.
**/

let g.cm.direction () = valof
$(
   let x, y = g.xpoint, g.ypoint
   let quadrant, dir = ?,?

   if g.screen ~= m.sd.display resultis m.invalid
   quadrant := x > m.mide -> m.e, m.w
   quadrant := quadrant | (y > m.midn -> m.n, m.s)

   if x > m.mide do x := m.tope - x
   if y > m.midn do y := m.topn - y

   dir := get.dir.as.if.sw (x, y)
   dir := convert.to.real.dir (quadrant, dir)
   if dir = m.beep do
   $( g.sc.beep ()
      dir := m.invalid
   $)
   resultis dir
$)


/**
         function get.dir.as.if.sw (x,y) returns the direction
         indicated mapping all posibilities onto the south west
         quadrant of the display area.  This uses the 2-axis
         reflective symmetry of the lozenge diagram.
**/

and get.dir.as.if.sw (x, y) = valof
$(
   if x > m.dve resultis y > m.dsn -> m.beep, m.s
   if y > m.dsn resultis m.w

   if muldiv (x - m.dve, m.topn, m.tope) + m.dvn > y resultis m.s
   if muldiv (x - m.dse, m.topn, m.tope) + m.dsn < y resultis m.w
   resultis m.sw
$)


/**
         function convert.to.real.dir (quadrant, direction)
         returns the real direction expanded from the quadrant
         that the original point was in and the direction mapped
         to the SW quadrant.
**/

and convert.to.real.dir (quadrant, dir) = valof switchon quadrant into
$(
   case m.sw:  resultis dir
   case m.nw:  switchon dir into
               $( case m.w:   resultis m.w
                  case m.sw:  resultis m.nw
                  case m.s:   resultis m.n
               $)  endcase
   case m.ne:  switchon dir into
               $( case m.w:   resultis m.e
                  case m.sw:  resultis m.ne
                  case m.s:   resultis m.n
               $)  endcase
   case m.se:  switchon dir into
               $( case m.w:   resultis m.e
                  case m.sw:  resultis m.se
                  case m.s:   resultis m.s
               $)
   default:    resultis m.beep
$)
.
