//  UNI SOURCE  4.87

section "mapopt5"

// needs "flconv"
// needs "flio2"
// needs "flar1"
// needs "flar2"

/**
         CO.MAPOPT5 - Value Display and Clear
         ------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         28.4.86  1        DNH         Initial version
         12.5.86  2        DNH         Globals to gl3hdr
         19.5.86  3        DNH         Fix Scaling Factors
          6.6.86  4        DNH         All change. Floating
                                          point etc.
         22.7.86  5        DNH         Blank output if zero
         30.7.86  6        DNH         Handle v.small values

         GLOBALS DEFINED:
            g.co.show.value ()
            g.co.options.clear ()
**/

get "H/libhdr.h"
// get "fphdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/sdhd.h"
get "H/cmhd.h"
get "H/cm3hd.h"

/**
         G.CO.SHOW.VALUE - Display the current value for Distance
                              or Area
         --------------------------------------------------------

         PROCEDURE g.co.show.value ()

         Displays the distance or area value in the measurement
         vector in the value field of the screen message area.
         The routine detects whether Distance or Area operation
         is in effect and outputs accordingly.

         The initial value used by the routine must be in scaled
         linear graphics units for Distance operation, or in
         unscaled square graphics units for Area operation.

         No value is output if there is no blue cross on the
         screen or we are in Area but the area is incomplete.

         Very small values are set to zero to avoid scientific
         notation being used by the 'writesg' output routine.
         The cut-off points are 0.01 for Distance, 0.001 for
         Area.  Otherwise all values are output to 3 significant
         figures.

         The value is always output as a positive quantity.  The
         algorithm for calculating areas gives a negative value
         if the points are plotted anticlockwise but this has no
         functional significance.

         INPUTS: no parameters.  The value to output and substate
         details are from map statics.

         OUTPUTS: none

         GLOBALS MODIFIED: various map statics

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.co.show.value ()
            initialise various local copy variables
            clear the value box
            strip sign of FP Graphics Unit value
            convert FP Graphics Unit value in 'measure' vector to
            [ FP metric distance or area value
            if current units are imperial
               convert FP metric value to FP imperial value
            scale area value for screen distortion of 13/12
            nobble any very small value to zero
            output the value
         end procedure
**/

let g.co.show.value () be
$(
   let x.pos, field = ?,?
   let exp.mult.factor = ?    // hm or dm  ->  km or m
   let u.conv = ?             // units conversion factor * 10000

   let cmlevel = g.cm.s!m.cmlevel
   let map = g.cm.s!m.map
   let units = g.cm.s!m.measure!m.v.units
   let in.area.op = (g.cm.s!m.substate & m.area.substate.bit) ~= 0

   let fp.value = g.cm.s!m.measure + m.v.value
   let fp.accuracy.divisor = ?                    // point to one of following
   let fp.result      = vec fp.len           // vec for result
   let temp1 = vec fp.len
   let temp2 = vec fp.len
   let fp.conv.factor = temp1                // recycle vector

   let mw = g.cm.mwidth (cmlevel, map)
   let pw = g.cm.pwidth (cmlevel, map)

   clear.value.field (in.area.op)        // boolean parameter

   // leave the value field as all spaces if in wrong substate
   if g.cm.s!m.substate = m.distance1.substate |
      g.cm.s!m.substate = m.area1.substate     |
      g.cm.s!m.substate = m.area2.substate  RETURN

   fpexcep := 0

   //  we want a positive value, regardless of direction of drawing
   fabs (fp.value, fp.value)

   //  correct for units used in map size tables
   exp.mult.factor := cmlevel = 4 -> +1, -1           // dm -> m; hm -> km
   if in.area.op do
      exp.mult.factor := exp.mult.factor * 2          // square it
   get.exp.value (exp.mult.factor, temp1)
   fmult (fp.value, temp1, fp.result)

   //  screen values to actual values
   fdiv ( ffloat (mw, temp1), ffloat (pw, temp2), fp.conv.factor )
   if in.area.op do
      fmult (fp.conv.factor, fp.conv.factor, fp.conv.factor)
   fmult (fp.result, fp.conv.factor, fp.result)

   //  convert to imperial if requested
   if units = m.imperial do
   $( let u.conv = cmlevel = 4 -> m.metres.to.yards, m.km.to.miles
      fdiv ( ffloat (u.conv, temp1), ffloat (10000, temp2), temp1 )
      if in.area.op do
         fmult ( temp1, temp1, temp1 )       // square the factor
      fmult (fp.result, temp1, fp.result)
   $)

   //  allow for screen distortion here if in Area
   if in.area.op do           // *13/12
   $( fdiv ( ffloat (13, temp1), ffloat (12, temp2), temp1 )
      fmult (fp.result, temp1, fp.result)
   $)

   //  set very small values to zero
   $( let low.limit = in.area.op -> -3, -2      // exp. minimum value
      get.exp.value (low.limit, temp1)
   $)
   if fcomp (fp.result, temp1) = -1 do
      ffloat (0, fp.result)

   if fpexcep do
   $(
      g.sc.mess ("Values too large in calculation")
      g.sc.beep ()
      return            //  can't do any more
   $)

   //  output the value in the value field of the message area
   x.pos := in.area.op -> m.area.value.X.pos, m.distance.value.X.pos
   field := in.area.op -> m.area.value.field, m.distance.value.field
   g.sc.movea (m.sd.message, x.pos, m.sd.mesYtex)
   g.sc.selcol (m.sd.blue)
   writesg (fp.result, field, m.scale.sig.digits)
$)

/**
         get.exp.value (exponent, floating point value)
         Returns the floating point value of the given exponent
         in the vector provided.  Handles +ve and -ve exponents.
         eg. exponent +4 -> FP value 10,000
             exponent  0 -> FP value      1
**/

and get.exp.value (exponent, fp.value) be
$(
   let ten = vec fp.len
   let routine = exponent > 0 -> fmult, fdiv

   exponent := abs exponent
   ffloat (10, ten)
   ffloat (1, fp.value)
   while exponent > 0 do                    // no loops if zero
   $( routine (fp.value, ten, fp.value)
      exponent := exponent - 1
   $)
$)


/**
         G.CO.OPTIONS.CLEAR - Reset Values for Scale to zero
         ---------------------------------------------------

         PROCEDURE g.co.options.clear ()

         Clears the measurement storage vector by resetting its
         pointers and the value field, and clears the value field
         in the message area and old lines from the display area
         if necessary.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: various map statics

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.co.options.clear ()
            set local copy variables
            reset measure vector FP value to zero
            reset point storage vector pointers
            clear the value field (see below)
            clear display area - gets rid of old lines on screen
         end procedure
**/

and g.co.options.clear () be
$(
   let substate = g.cm.s!m.substate
   let measure = g.cm.s!m.measure
   let in.area.op = (g.cm.s!m.substate & m.area.substate.bit) ~= 0

         // clear measurement storage area
   ffloat (0, measure+m.v.value)
   measure!m.v.next.point.ptr := measure+m.v.first.point
   measure!m.v.full := false
         // (leave units as they are.  Only initialised in mapini.special)

         // clear the display area and the value field
   clear.value.field (in.area.op)       // value field of message area
   g.sc.clear (m.sd.display)
$)


/**
         clear.value.field (in area operation boolean)
         Clears the value field of the message area without
         clearing the current units name.  The value field is
         returned to a cyan region without any blue digits.
**/

and clear.value.field (in.area.op) be
$( let x.pos = in.area.op -> m.area.value.X.pos, m.distance.value.X.pos
   let field = in.area.op -> m.area.value.field, m.distance.value.field

   g.sc.movea (m.sd.message, x.pos, 0)
   g.sc.selcol (m.sd.cyan)
   g.sc.rect (m.sd.plot, field * m.sd.charwidth - 1, m.sd.mesh - 1)
$)
.
