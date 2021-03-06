//  PUK SOURCE  6.87

/**
         NM.UTILS - UTILITIES FOR NATIONAL MAPPABLE
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         10.01.86 1        D.R.Freed   Initial version
         26.02.86 2        DRF         G.nm.set.map.entry,
                                       G.nm.apply.areal.map,
                                       G.nm.map.hit,
                                       G.nm.load.child
                                             added
                                       Check for video player
                                             prescence
                                       G.nm.min, G.nm.max added
                                       G.nm.bad.data restores
                                          default graphics
                                          window where necessary
                                       G.nm.bad.data takes
                                          value parameter
                                       G.nm.position.videodisc
                                          turns on video for
                                          VP415 player
                                       G.nm.set.plot.window,
                                       G.nm.unset.plot.window
                                          added
                                       Areal map handling revised
         ********************************
         18.6.87     3     DNH      CHANGES FOR UNI
                                     + add g.nm.unpack32
                                    remove debug stuff
                                    correct filename length
         16.7.87     4     DNH      fix g.nm.widen
         20.8.87     5     SA       Add fixes to UNI bugs
         27.8.87     6     SRY      fix load.child

         g.nm.unpack32
         g.nm.dual.data.type
         g.nm.widen
         g.nm.min
         g.nm.max
         g.nm.set.map.entry
         g.nm.apply.areal.map
         g.nm.map.hit
         g.nm.bad.data
         g.nm.set.plot.window
         g.nm.unset.plot.window
         g.nm.position.videodisc
         g.nm.load.child
**/

section "nmutils"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/vhhd.h"
get "H/dhhd.h"
get "H/nmhd.h"


/**
         G.NM.UNPACK32 - UNPACK A 32 BIT VALUE FROM DATA
         -----------------------------------------------

         Reads 4 consecutive bytes from videodisc frame buffer,
         starting with the byte indicated by the value of
         !frame.ptr, and unpacks them in the correct order.

         The bytes have to be moved out of the freame bugger in
         two stages, with an intermediate increment, in case they
         span a frame boundary.  It is for this reason that
         g.ut.unpack32 cannot be used directly.

         INPUTS:

         Pointer to byte offset in buffer;
         Destination pointer.

         OUTPUTS: none

         GLOBALS MODIFIED: none


         PROGRAM DESIGN LANGUAGE:

         g.nm.unpack32 [frame.ptr, dest.ptr]
         -------------

         copy first 2 bytes into local buffer
         increment frame.ptr
         copy next 2 bytes into local buffer
         unpack local buffer, as 32 bit value, into dest.ptr
**/

let g.nm.unpack32 (frame.ptr, dest.ptr) = valof
$(
   let buffer = vec m.nm.max.data.size - 1
   let soff = ?

   soff := !frame.ptr
   buffer%0, buffer%1 := g.nm.frame%soff, g.nm.frame%(soff+1)

   g.nm.inc.frame.ptr (frame.ptr)

   soff := !frame.ptr
   buffer%2, buffer%3 := g.nm.frame%soff, g.nm.frame%(soff+1)

   resultis g.ut.unpack32 (buffer, 0, dest.ptr)
$)


/**
         G.NM.DUAL.DATA.TYPE - TEST FOR DUAL VALUE DATA TYPE
         ---------------------------------------------------

         Determines whether the given data type has dual values

         INPUTS:

         Data type

         OUTPUTS:

         Returns TRUE if the data type is a dual value type
                 FALSE otherwise

         GLOBALS MODIFIED:

         none


         PROGRAM DESIGN LANGUAGE:

         g.nm.dual.data.type [data.type] RETURNS TRUE or FALSE
         -------------------

         RETURN (data.type = one of the dual value types)
**/

let g.nm.dual.data.type(data.type) = valof
$(
   resultis (data.type = m.nm.ratio.and.numerator.type) |
            (data.type = m.nm.percentage.and.numerator.type)
$)


/**
         G.NM.WIDEN - WIDEN A VALUE INTO A DOUBLE WORD
         ---------------------------------------------

         Widens a byte or 2 byte value into a 4 byte value.
         Maximum negative value is widened to the maximum
         negative value for a 4 byte signed integer.

         INPUTS:

         Value to be widened
         Length of value in bytes
         Pointer to result vector

         OUTPUTS:

         Widened value put at result vector

         GLOBALS MODIFIED: none

         PROGRAM DESIGN LANGUAGE:

         g.nm.widen [value, value.length, -> 4.byte.value]
         ----------

         IF value.length = 1 THEN
               IF value = max. neg. value THEN
                     4.byte.value = max. neg. value
               ELSE
                     propogate top bit
               ENDIF
         ELSE
               IF value = max. neg. value THEN
                     4.byte.value = max. neg. value
               ELSE
                     propogate top bit
               ENDIF
         ENDIF
**/

and g.nm.widen (value, value.length, result.ptr) be
$(


   test value.length = 1 then

      test (value & #Xff) = (m.nm.max.neg.high >> 8) then
   // missing data
         g.ut.set32 (0, m.nm.max.neg.high, result.ptr)
      else
         test (value & #X80) ~= 0 then
         // negative: extend bits
            g.ut.set32 (value | #Xff00, #Xffff, result.ptr)
         else
                                  // positive
            g.ut.set32 (value & #X00ff, 0, result.ptr)

   else                 // value.length = 2

      test value = m.nm.max.neg.high then
         g.ut.set32 (0, value, result.ptr)
      else
         g.ut.set32 (value, ( (value & #X8000) = 0 -> 0, #Xffff ), result.ptr)

$)


/*
      g.nm.min

         returns the minimum of the two input values
*/
and g.nm.min (a, b) = a < b -> a, b


/*
      g.nm.max

         returns the maximum of the two input values
*/
and g.nm.max (a, b) = a > b -> a, b


/**
         G.NM.SET.MAP.ENTRY - SET ENTRY IN AREAL MAP
         -------------------------------------------

         Sets the specified entry in the bit map which indicates
         which areal vector elements have been accessed.

         INPUTS:

         Index of areal vector element

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.areal.map

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.set.map.entry [index]
         ------------------

         IF index is within range THEN
            calculate word & bit position corresponding to index
            set the bit in the word
         ELSE
            issue bad data warning
         ENDIF
**/

and g.nm.set.map.entry (index) be
$(
   let word.index = index / BITSPERWORD

   test (0 <= index <= g.nm.s!m.nm.nat.num.areas) then
      g.nm.areal.map!word.index :=
               g.nm.areal.map!word.index | (1 << (index REM BITSPERWORD) )
   else
      g.nm.bad.data ("Area number =", index)
$)


/**
         G.NM.APPLY.AREAL.MAP - APPLY MAP TO AREAL VECTOR
         ------------------------------------------------

         Uses the areal bit map to move all the areal vector
         elements, which have been accessed, down to the start of
         the vector. Returns the index of the last of these
         elements.

         INPUTS:

         Exclude missing values flag

         OUTPUTS:

         RETURNS index of last element in rearranged areal vector
                  (-1 if no elements were accessed)
                 index+1 = number of areal units in area of
                           interest
         GLOBALS MODIFIED:

         g.nm.areal


         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.apply.areal.map [exclude.missing.flag] RETURNS last
         --------------------

         last = -1
         FOR i = 1 to total number of areas
               IF element i has bit set in map THEN
                  IF include.missing.flag OR
                          i th value is not missing THEN
                     last = last + 1
                     move i th element in areal vector to last th
                        element
                  ENDIF
               ENDIF
         ENDFOR

         RETURN last
**/

and g.nm.apply.areal.map (exclude.missing.values) = valof
$(
   let last = -1
   and max.neg32 = vec m.nm.max.data.size - 1

   g.ut.set32 (0, m.nm.max.neg.high, max.neg32)

   for i = 1 to g.nm.s!m.nm.nat.num.areas do

      if g.nm.map.hit (i) then
      $(
         if (NOT exclude.missing.values) |
            (g.ut.cmp32 (g.nm.areal + (i * m.nm.max.data.size),
                                                   max.neg32) ~= m.eq) then
         $(
            last := last + 1
            MOVE (g.nm.areal + i * m.nm.max.data.size,
                  g.nm.areal + last * m.nm.max.data.size, m.nm.max.data.size)
         $)
      $)

   resultis last
$)


/**
         G.NM.MAP.HIT - TEST IF ENTRY IN AREAL MAP IS SET
         ------------------------------------------------

         Sees if the specified entry in the bit map is set.

         INPUTS:

         Index of areal vector element

         OUTPUTS:

         RETURNS TRUE if the bit is set (ie. element accesed)
                 FALSE otherwise

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.map.hit [index] RETURNS BOOLEAN
         ------------

         calculate word and bit position corresponding to index
         RETURN value of bit
**/

and g.nm.map.hit (index) =
   (g.nm.areal.map!(index / BITSPERWORD) &
                        (1 << (index REM BITSPERWORD))) ~= 0


/**
         G.NM.BAD.DATA - ISSUE BAD DATA WARNING
         --------------------------------------

         Issues a warning that there is bad data within a dataset
         on the disc.

         INPUTS:

         String giving specific information
         Value

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none


         SPECIAL NOTES FOR CALLERS:

         This should be called whenever it is possible to range
         check a value read from disc.

         PROGRAM DESIGN LANGUAGE:

         g.nm.bad.data [string, value]
         -------------

         IF the plot window has been set THEN
            restore default window so that message is visible
         ENDIF

         write standard fixed error message to message area
         IF debug THEN
            write error message with string and value
         ENDIF

         IF plot window was in force THEN
            set it back again
         ENDIF
**/

and g.nm.bad.data (string, value) be
$(
   let window = ?

   window := g.nm.s!m.nm.window.set

   if window then
      g.nm.unset.plot.window ()

   g.sc.ermess ("**** WARNING: SUSPECT DATA ON DISC ****")

$<debug
   g.sc.ermess ("%s %n", string, value)
$>debug

   if window then
      g.nm.set.plot.window ()
$)


/**
         G.NM.SET.PLOT.WINDOW - SET GRAPHICS WINDOW FOR PLOTTING
         -------------------------------------------------------

         Redefines the graphics window for plotting a variable

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.window.set


         PROGRAM DESIGN LANGUAGE:

         g.nm.set.plot.window []
         --------------------

         set graphics window using calculated limits
         set window.set flag in g.nm.s
**/

and g.nm.set.plot.window () be
$(
   // define graphics window (in graphics coordinates) which corresponds
   // exactly to the area of interest and is responsible for clipping parts
   // of grid squares which fall outside

   g.sc.setwin (g.nm.s!m.nm.x.min, g.nm.s!m.nm.y.min,
                g.nm.s!m.nm.x.max, g.nm.s!m.nm.y.max)

   g.nm.s!m.nm.window.set := TRUE
$)


/**
         G.NM.UNSET.PLOT.WINDOW - RESTORE GRAPHICS WINDOW
         ------------------------------------------------

         Restores the graphics window to its Domesday default

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.window.set


         PROGRAM DESIGN LANGUAGE:

         g.nm.unset.plot.window []
         ----------------------

         restore graphics window to default
         clear window.set flag in g.nm.s
**/

and g.nm.unset.plot.window () be
$(
   g.sc.defwin ()

   g.nm.s!m.nm.window.set := FALSE
$)


/**
         G.NM.POSITION.VIDEODISC - POSITION DISC TO UNDERLAY MAP
         -------------------------------------------------------

         Positions videodisc and turns on video output to display
         underlay map, if there is one.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: none


         PROGRAM DESIGN LANGUAGE:

         g.nm.position.videodisc []
         -----------------------

         IF there is an underlay map THEN
            position videodisc to its frame number
            turn on video output
         ENDIF
**/

and g.nm.position.videodisc () be
$(
   if (g.context!m.underlay.frame.no ~= 0) then

      $(
         g.vh.frame (g.context!m.underlay.frame.no)
         g.vh.video (m.vh.video.on)
      $)
      // machine-specific filing system swaps gone 18.6.87  DNH
$)


/**
         G.NM.LOAD.CHILD - LOAD CHILD OVERLAY
         ------------------------------------

         Loads the specified child overlay, if it is not already
         loaded.

         INPUTS:

         Filename

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.curr.child


         PROGRAM DESIGN LANGUAGE:

         IF filename ~= current child name THEN
            (restore filing system to overlay entry state)
            load child overlay using g.ov.load
            (set filing system back for reading data)
            update current child name
         ENDIF
**/

and g.nm.load.child (file.name) be
$(
   if (COMPSTRING (file.name, g.nm.s + m.nm.curr.child) ~= 0) then

      $(
         $<RCP                  // UNI bug fixed 13.8.87
         g.nm.child.ovly := g.ov.load (file.name, g.nm.child.ovly)
         $>RCP                  // fix SRY 27.8

         g.ut.movebytes (file.name, 0,
                         g.nm.s + m.nm.curr.child, 0,
                         m.nm.file.name.length)
      $)
$)
.
