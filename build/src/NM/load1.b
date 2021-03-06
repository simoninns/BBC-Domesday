//  AES SOURCE  6.87

/**
         NM.LOAD1 - DATASET LOADING ROUTINES FOR NATIONAL MAPPABLE
         ---------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         13.01.86 1        D.R.Freed   Initial version
         25.04.86 2        DRF      units string handling
                                       modified to ignore
                                       abbreviation character
                                       calls to g.nm.bad.data
                                    load.dataset.header
                                       modified to cope with
                                       two subset indexes
                                    Indexes contain relative
                                       record numbers rather
                                       than absolute;
                                       converted when process
                                       variable
                                    Coarse index removed from
                                       g.nm.s and held in
                                       dedicated vectors
         ********************************
         18.6.87     4     DNH      CHANGES FOR UNI
                                    g.nm.get.size4.value
                                    g.nm.skip.fields

         g.nm.load.coarse.index
         g.nm.load.fine.index
         g.nm.load.dataset.header
         g.nm.get.size4.value
         g.nm.skip.fields
**/

section "nmload1"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/dhhd.h"
get "H/nmhd.h"
get "H/nmldhd.h"


/**
         G.NM.LOAD.COARSE.INDEX - LOAD COARSE INDEX FOR SUB-DATASET
         ----------------------------------------------------------

         Loads the coarse index for the current sub-dataset into
         global areas.

         Relative record numbers and offsets are loaded straight
         from disc without conversion.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.num.we.blocks
         g.nm.s!m.nm.num.sn.blocks
         g.nm.coarse.index.record
         g.nm.coarse.index.offset


         SPECIAL NOTES FOR CALLERS:

         The coarse index is guaranteed to be wholly contained
         within a frame.


         PROGRAM DESIGN LANGUAGE:

         g.nm.load.coarse.index []
         ----------------------

         read frame containing start of data
         get number of blocks WE and SN from header

         FOR i = 1 TO total number of blocks

            coarse index record number (i-1) = record number
            coarse index offset (i-1) = offset

         ENDFOR
**/

let g.nm.load.coarse.index () be
$(
   let offset  =  ?

   g.nm.read.frame (g.nm.s!m.nm.data.record.number)

   offset := g.nm.s!m.nm.data.offset   // for efficiency - index can be v.large

   g.nm.s!m.nm.num.we.blocks := g.ut.unpack16.signed (g.nm.frame, offset)
   g.nm.s!m.nm.num.sn.blocks := g.ut.unpack16.signed (g.nm.frame, offset + 2)

   if (g.nm.s!m.nm.num.we.blocks < 0) |
         (g.nm.s!m.nm.num.sn.blocks < 0) |
            (g.nm.s!m.nm.num.we.blocks * g.nm.s!m.nm.num.sn.blocks >
                                                m.nm.coarse.index.size) then
      $(
         g.nm.bad.data ("Num WE blcks =", g.nm.s!m.nm.num.we.blocks)
         g.nm.bad.data ("Num SN blcks =", g.nm.s!m.nm.num.sn.blocks)
         g.nm.s!m.nm.num.sn.blocks :=
                     m.nm.coarse.index.size / g.nm.s!m.nm.num.we.blocks
      $)

   for i = 1 to (g.nm.s!m.nm.num.we.blocks * g.nm.s!m.nm.num.sn.blocks) do
      $(
         offset := offset + 4
         g.nm.coarse.index.record!(i - 1) :=
                                 nm.get.record.number (g.nm.frame, offset)
         g.nm.coarse.index.offset!(i - 1) :=
                                 nm.get.record.number (g.nm.frame, offset + 2)
      $)
$)


/**
         G.NM.LOAD.FINE.INDEX - LOAD A FINE INDEX
         ----------------------------------------

         Loads the specified fine index into a global area.

         Relative record numbers and offsets are loaded straight
         from disc without conversion.

         INPUTS:

         Absolute record number for required index
         Offset within record of index

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.fine.index.record.number
         g.nm.s!m.nm.fine.index.offset


         SPECIAL NOTES FOR CALLERS:

         The fine index is guaranteed to be wholly contained
         within a frame.


         PROGRAM DESIGN LANGUAGE:

         g.nm.load.fine.index [record.number, offset]
         --------------------

         read specified frame

         FOR i = 0 TO 15

            fine index record number (i) = record number
            fine index offset (i) = offset

         ENDFOR
**/

and g.nm.load.fine.index (record.number, offset) be
$(
   g.nm.read.frame (record.number)

   for i = 0 to 15 do

      $(
         g.nm.s!(m.nm.fine.index.record.number + i) :=
                                 nm.get.record.number (g.nm.frame, offset)
         g.nm.s!(m.nm.fine.index.offset + i) :=
                                 nm.get.record.number (g.nm.frame, offset + 2)
         offset := offset + 4
      $)
$)


/*
         function nm.get.record.number (s, soff)
                  --------------------

         Returns a record number from a dataset index unpacked
         from s%soff.  Handles the 16 bit "uniform missing"
         special value by preserving it.  Handles other uniform
         values (bit 15 set) by sign extension if on 32 bit
         machine.
*/

and nm.get.record.number (buf.addr, byte.offset) = valof
$(
   let value = g.ut.unpack16.signed (buf.addr, byte.offset)
   let trimmed.value = value & #XFFFF

   test (trimmed.value = m.nm.uniform.missing) then
      RESULTIS trimmed.value        // special value
   else
      RESULTIS value                // sign-extended, if necessary
$)


/**
         G.NM.LOAD.DATASET.HEADER - LOAD HEADER INFO FOR DATASET
         -------------------------------------------------------

         Loads the relevant fields of the dataset header, at the
         specified sector, into globals.


         INPUTS:

         Pointer to absolute sector number of dataset, which is a
         4 byte value.

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.dataset.record.number
         g.nm.s!m.nm.dataset.type
         g.nm.s!m.nm.private.text.address
         g.nm.s!m.nm.descriptive.text.address
         g.nm.s!m.nm.technical.text.address
         g.nm.s!m.nm.data.type
         g.nm.s!m.nm.sub.dataset.index.record.number
         g.nm.s!m.nm.sub.dataset.index.offset
         g.nm.s!m.nm.raster.index.record
         g.nm.s!m.nm.raster.index.offset
         g.nm.s!m.nm.primary.units.string
         g.nm.s!m.nm.secondary.units.string


         PROGRAM DESIGN LANGUAGE:

         g.nm.load.dataset.header [sector number]
         ------------------------

         determine absolute record number and offset of dataset
                                             from sector number
         read frame at record number
         get dataset type from frame buffer
         IF dataset type is areal boundary data THEN

            discard most of following header information (since
                  it is read from the areal mappable dataset
                  header)
         ELSE
            global dataset type = type read from frame buffer
            load all following header information into globals
         ENDIF

         extract relevant information from dataset header, using
            above criteria
**/

and g.nm.load.dataset.header (sector) be
$(
   let ptr, type, keep, high  =  ?, ?, ?, ?
   and value = ?              // storage for unpacked 16 bit value
   and abs.sector.no = vec 1
   and num.sectors = vec 1
   and remainder = vec 1

   //g.sc.ermess( "sector %n", sector!0 )

   // convert absolute sector number of dataset into absolute record number and
   // byte offset

   g.ut.set32 (m.dh.sectors.per.frame, 0, num.sectors)
   g.ut.mov32 (sector, abs.sector.no)

   if g.ut.div32 (num.sectors, abs.sector.no, remainder) then  // always true
      $(
         g.nm.s!m.nm.dataset.record.number := g.ut.get32 (abs.sector.no, @high)
         ptr := g.ut.get32 (remainder, @high) * m.dh.bytes.per.sector
      $)

   //g.sc.ermess( "frame %n", g.nm.s!m.nm.dataset.record.number)

   g.nm.read.frame (g.nm.s!m.nm.dataset.record.number)

   type := g.nm.frame%(ptr + 1)

   if (type < m.nm.grid.mappable.data) |
                  (type > m.nm.areal.mappable.data) then
      g.nm.bad.data ("Dataset type =", type)

   test (type = m.nm.areal.boundary.data) then
      keep := m.nm.discard
   else
      $(
         g.nm.s!m.nm.dataset.type := type
         keep := m.nm.keep
      $)

   g.nm.get.size4.value (keep, @ptr, g.nm.s + m.nm.private.text.address)
   g.nm.get.size4.value (keep, @ptr, g.nm.s + m.nm.descriptive.text.address)
   g.nm.get.size4.value (keep, @ptr, g.nm.s + m.nm.technical.text.address)

   // skip past irrelevant items, namely:
   //    Thesauraus terms pointers (10), item names file pointer (4),
   //    title string (40) [item name is used for title string]
   //    Total skip: 54 bytes

   g.nm.skip.fields (54, @ptr)

   nm.get.units.string (keep, @ptr, g.nm.s + m.nm.primary.units.string)
   nm.get.units.string (keep, @ptr, g.nm.s + m.nm.secondary.units.string)
   g.nm.inc.frame.ptr (@ptr)

   value := g.ut.unpack16.signed (g.nm.frame, ptr)

   test (type = m.nm.areal.mappable.data) then
   $(
      g.nm.s!m.nm.value.data.type := value
      g.nm.inc.frame.ptr (@ptr)
      g.nm.s!m.nm.sub.dataset.index.record.number :=
                                             g.nm.current.frame.number ()
      g.nm.s!m.nm.sub.dataset.index.offset := ptr
   $)

   else

      test (type = m.nm.areal.boundary.data) then
      $(
         g.nm.s!m.nm.raster.data.type := value
         g.nm.inc.frame.ptr (@ptr)
         g.nm.s!m.nm.raster.index.record := g.nm.current.frame.number ()
         g.nm.s!m.nm.raster.index.offset := ptr
      $)

      else     // grid mappable data

      $(
         g.nm.s!m.nm.value.data.type := value
         g.nm.s!m.nm.raster.data.type := value
         g.nm.inc.frame.ptr (@ptr)
         g.nm.s!m.nm.sub.dataset.index.record.number :=
                                          g.nm.current.frame.number ()
         g.nm.s!m.nm.raster.index.record :=
                                 g.nm.s!m.nm.sub.dataset.index.record.number
         g.nm.s!m.nm.sub.dataset.index.offset := ptr
         g.nm.s!m.nm.raster.index.offset := ptr
      $)
$)


/*
      nm.get.units.string

         reads a units string as a sequence of characters from
         the frame buffer, converts them into a BCPL packed
         string and puts the string at the address given, if the
         keep flag is set, otherwise discards it.

         the first character is changed to a space; it is an
         abbreviation character which we are not using
*/

and nm.get.units.string (keep.flag, frame.ptr, string.ptr) be
$(
   test (keep.flag = m.nm.keep) then

      $(
         for i = 1 to m.nm.units.string.length / 2 do

            $(
               g.nm.inc.frame.ptr (frame.ptr)

               string.ptr%(i*2 - 1) := g.nm.frame%(!frame.ptr)
               string.ptr%(i*2) := g.nm.frame%(!frame.ptr + 1)

            $)

         // overwrite abbreviation character and
         // set up BCPL string length in bytes

         string.ptr%1 := ' '
         string.ptr%0 := m.nm.units.string.length
      $)

   else

      g.nm.skip.fields (m.nm.units.string.length, frame.ptr)
$)


/**
      g.nm.get.size4.value

         reads 4 consecutive bytes from frame and assigns them
         to given vector if keep flag is set, otherwise discards
         them
**/

let g.nm.get.size4.value (keep.flag, ptr, dest.ptr) be
$(
   test (keep.flag = m.nm.keep) then

      $(
         g.nm.inc.frame.ptr (ptr)
         g.nm.unpack32 (ptr, dest.ptr)
      $)

   else
         g.nm.skip.fields (4, ptr)
$)


/**
      g.nm.skip.fields

         skips past the specified number of bytes in the frame
         MUST ONLY BE CALLED WITH 'bytes.to.skip' EVEN, >= 2
**/

let g.nm.skip.fields (bytes.to.skip, frame.ptr) be
$(
   for i = 1 to (bytes.to.skip / 2) do
      g.nm.inc.frame.ptr (frame.ptr)      // increment by 2 bytes
$)

.
