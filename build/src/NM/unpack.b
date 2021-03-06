//  PUK SOURCE  6.87

/**
         NM.UNPACK - DATA UNPACKING FOR NATIONAL MAPPABLE
         ------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         14.01.86 1        D.R.Freed   Initial version
         26.02.86 2        DRF      Unpack fine block returns
                                    boundary data values
                                    rather than values from
                                    areal vector
                                    G.nm.bad.data calls
         02.10.86 3        DRF      Optimisation
         ********************************
         18.6.87     4     DNH      CHANGES FOR UNI
         11.08.87 5        SRY      Modified for DataMerge

         g.nm.init.values.buffer
         g.nm.unpack.fine.block
**/

section "nmunpack"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/nmhd.h"

manifest
$(       // Use a shift manifest for speed.
         // max.ds = 1 (32 bit) => no shift  ( << 0 )
         // max.ds = 2 (16 bit) => shift one ( << 1 )

   m.max.data.size.shift = m.nm.max.data.size - 1

$)

   // Statics used globally by this module

   static   $( s.unpacked.record.number = ?  // record number and
               s.unpacked.offset = ?         // offset of
                                             // unpacked block in
                                             // g.nm.values
            $)


/**
         G.NM.INIT.VALUES.BUFFER - INITIALISE VALUES BUFFER
         --------------------------------------------------

         Sets unpacked record number to indicate that the current
         contents of g.nm.values are rubbish.

         The value chosen is -1, which is 65k when treated as an
         unsigned 16-bit number (which is how frame numbers are
         treated) or huge when treated as an unsigned 32 bit
         number. The maximum valid frame number is around 54k.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:

         This routine must be called before any of the other
         routines in this module are called whenever :
            a) the calling overlay has been loaded
            b) the values vector memory is used as workspace.

         PROGRAM DESIGN LANGUAGE:

         g.nm.init.values.buffer []
         -----------------------

         static unpacked record number = -1
**/

let g.nm.init.values.buffer() be s.unpacked.record.number := -1


/**
         G.NM.UNPACK.FINE.BLOCK - UNPACK A FINE BLOCK INTO VALUES
         --------------------------------------------------------

         Unpacks the specified fine block into the global vector
         g.nm.values, if it is not there already.


         INPUTS:

         Record number of block
         Byte offset to block within record

         OUTPUTS:

         Puts unpacked rasterized data into g.nm.values

         GLOBALS MODIFIED:

         g.nm.values

         PROGRAM DESIGN LANGUAGE:

         g.nm.unpack.fine.block [record.number, byte offset]
         ----------------------

         IF record.number and offset are the same as static
                  unpacked record number and offset THEN

               RETURN
         ELSE
               read specified frame
               set static unpacked record number and offset to input
                                                         parameters
         ENDIF

         initialise values vector

         get number of items

         FOR i = 1 TO number of items

            get the item

            IF raster sub-dataset has dual values THEN
               value at relative location = repeat count
            ELSE
               value at relative location = primary value

               duplicate values in next
                                 (repeat count - 1) locations
            ENDIF
         ENDFOR
**/

and g.nm.unpack.fine.block (record.number, offset) = valof
$(
   manifest
   $( m.squares.per.block = m.nm.fine.blocksize * m.nm.fine.blocksize
   $)
   let   num.items, get.item, next.byte, relative.location  =  ?, ?, ?, ?
   and   index, dual.type = ?, ?
   and   primary.value = vec m.nm.max.data.size - 1
   and   repeat.count  = ?

   test record.number = s.unpacked.record.number & offset = s.unpacked.offset
   then resultis true
   else $( unless g.nm.read.frame (record.number) resultis false
           s.unpacked.record.number := record.number
           s.unpacked.offset := offset
        $)

   // initialize vector as fast as possible;
   // NOTE that element 0 in the array is not used since subtracting 1 for
   // each access to the array is unnecessarily inefficient - it is better to
   // waste a word or two.

   g.nm.values!0 := 0

   MOVE (g.nm.values, g.nm.values + 1,
         ((m.squares.per.block) * m.nm.max.data.size))

   num.items := g.ut.unpack16.signed (g.nm.frame, offset)

   unless 0 <= num.items <= m.squares.per.block
      $(
         g.nm.bad.data ("Num. items =", num.items)
         resultis true
      $)

   // set up the 'get.item' routine for the data size;
   // the routine will get the next item in the rasterized data
   // and unpack it into relative location, repeat count and primary value

   get.item := valof switchon (g.nm.s!m.nm.data.size) into
      $(
         CASE 1 : resultis nm.get.byte.item
         CASE 2 : resultis nm.get.size2.item
         CASE 3 : resultis nm.get.variable.item
         CASE 4 : resultis nm.get.size4.item

         DEFAULT: resultis g.ut.abort
      $)

   dual.type := g.nm.dual.data.type (g.nm.s!m.nm.raster.data.type)

   next.byte := 0

   for i = 1 to num.items do

      $(
         repeat.count := 0
         g.ut.set32 (0, 0, primary.value)

         unless get.item (@relative.location, @repeat.count, primary.value,
                          @offset, @next.byte) resultis false

         unless 1 <= relative.location <= m.squares.per.block
            $(
               g.nm.bad.data ("Rel. loc. =", relative.location)
               relative.location := 1
            $)

         index := relative.location << m.max.data.size.shift

         test dual.type then
            $(
               let wide.repeat.count = vec m.nm.max.data.size - 1

               g.nm.widen (repeat.count, 1, wide.repeat.count)
               g.ut.mov32 (wide.repeat.count, g.nm.values + index)
            $)
         else
            $(
               g.ut.mov32 (primary.value, g.nm.values + index)

               // if repeat count is used properly, then duplicate values

               test (repeat.count > 0) &
                    ( (repeat.count + relative.location) <=
                                             m.squares.per.block + 1 ) then
                  if repeat.count > 1 do
                     MOVE (g.nm.values + index,
                           g.nm.values + index + m.nm.max.data.size,
                           (repeat.count - 1) * m.nm.max.data.size)
               else
                  $(
                     g.nm.bad.data ("Rel.loc.=", relative.location)
                     g.nm.bad.data ("Repeat count =", repeat.count)
                  $)
            $)
      $)
   resultis true
$)


/*
      nm.get.byte.item

         gets and unpacks a byte item (an item with data
         size = 1) into relative location, repeat count and
         primary value
*/

and nm.get.byte.item (relative.location.ptr, repeat.count.ptr,
                      primary.value.ptr, frame.ptr, next.byte.ptr) = valof
$(
   test (!next.byte.ptr = 0) then

      $(
         unless g.nm.inc.frame.ptr (frame.ptr) resultis false
         !relative.location.ptr := g.nm.frame % (!frame.ptr)
         !repeat.count.ptr      := g.nm.frame % (!frame.ptr + 1)

         unless g.nm.inc.frame.ptr (frame.ptr) resultis false
         g.nm.widen (g.nm.frame % (!frame.ptr), 1, primary.value.ptr)

         !next.byte.ptr := 1
      $)

   else
      $(
         !relative.location.ptr := g.nm.frame % (!frame.ptr + 1)
         unless g.nm.inc.frame.ptr (frame.ptr) resultis false
         !repeat.count.ptr      := g.nm.frame % (!frame.ptr)

         g.nm.widen (g.nm.frame % (!frame.ptr + 1), 1, primary.value.ptr)

         !next.byte.ptr := 0
      $)
   resultis true
$)


/*
      nm.get.size2.item

         gets and unpacks an item with data size = 2 into
         relative location, repeat count and primary value
*/

and nm.get.size2.item (relative.location.ptr, repeat.count.ptr,
                       primary.value.ptr, frame.ptr) = valof
$(
   unless g.nm.inc.frame.ptr (frame.ptr) resultis false
   !relative.location.ptr := g.nm.frame % (!frame.ptr)
   !repeat.count.ptr      := g.nm.frame % (!frame.ptr + 1)

   unless g.nm.inc.frame.ptr (frame.ptr) resultis false
   g.nm.widen ( g.ut.unpack16 (g.nm.frame, !frame.ptr), 2, primary.value.ptr)
   resultis true
$)


/*
      nm.get.size4.item

         gets and unpacks an item with data size = 4 into
         relative location, repeat count and primary value
*/

and nm.get.size4.item (relative.location.ptr, repeat.count.ptr,
                       primary.value.ptr, frame.ptr) = valof
$(
   unless g.nm.inc.frame.ptr (frame.ptr) resultis false
   !relative.location.ptr := g.nm.frame % (!frame.ptr)
   !repeat.count.ptr      := g.nm.frame % (!frame.ptr + 1)

   unless g.nm.inc.frame.ptr (frame.ptr) resultis false
   g.nm.unpack32 (frame.ptr, primary.value.ptr)
   resultis true
$)


/*
      nm.get.variable.item

         gets and unpacks a variable size item (an item with data
         size = 2 or 4, depending on top bit of relative
         location) into relative location, repeat count and
         primary value
*/

and nm.get.variable.item (relative.location.ptr, repeat.count.ptr,
                          primary.value.ptr, frame.ptr) = valof
$(
   unless g.nm.inc.frame.ptr (frame.ptr) resultis false
   !relative.location.ptr := g.nm.frame % (!frame.ptr)
   !repeat.count.ptr      := g.nm.frame % (!frame.ptr + 1)

   test (!relative.location.ptr & #X0080) = #X0080 then

      $(
         !relative.location.ptr := !relative.location.ptr & #Xff7f
         unless g.nm.inc.frame.ptr (frame.ptr) resultis false
         g.nm.unpack32 (frame.ptr, primary.value.ptr)
      $)

   else

      $(
         unless g.nm.inc.frame.ptr (frame.ptr) resultis false
         g.nm.widen ( g.ut.unpack16 (g.nm.frame, !frame.ptr), 2,
                                                         primary.value.ptr)
      $)
   resultis true
$)
.







