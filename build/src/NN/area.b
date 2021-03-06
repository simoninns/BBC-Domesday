//  PUK SOURCE  6.87

/**
         NM.AREA - LIBRARY ROUTINE TO GET AREA NAME
         ------------------------------------------

         NAME OF FILES CONTAINING RUNNABLE CODE:

         cnmRETR
         cnmWRIT
         cnmRANK

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         28.09.86 1        D.R.Freed   Initial version
         ********************************
         7.7.87      2     DNH      CHANGES FOR UNI
         12.08.87 3        SRY      Fixed vec 32 -> vec 1

         g.nm.get.area.name
**/

section "nmarea"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/nmhd.h"

get "H/nmrehd.h"


/*
      function g.nm.get.area.name (area number, dest.vec)
               ------------------
         get name string for given area number from gazetteer;
         The string starts at byte 2 of the record.
         The record indexed by area number contains a
         cross-reference to record containing correct name.
         Copies string into supplied vector to word-align it.
         Dest.vec should be declared as 'vec 40 / BYTESPERWORD'
         Returns pointer to destination vector (same as param)
*/

let g.nm.get.area.name (area.no, dest.vec) = valof
$(
   let offset = vec 1
   and const32 = vec 1
   and gaz.rec = g.nm.s + m.gaz.record    // (just convenient)

   g.ut.set32 (area.no - 1, 0, offset)
   g.ut.set32 (m.gaz.record.length, 0, const32)
   g.ut.mul32 (const32, offset)
   g.ut.add32 (g.nm.s + m.nm.names.offset, offset)

   g.dh.read (g.nm.s!m.nm.gaz.handle, offset, gaz.rec, m.gaz.record.length)
   // unpack 32 bit pointer to record
   g.ut.unpack32 (gaz.rec, 42, offset)

   g.dh.read (g.nm.s!m.nm.gaz.handle, offset, gaz.rec, m.gaz.record.length)
   g.ut.movebytes (gaz.rec, 2, dest.vec, 0, 40)    // total length 40 bytes

   resultis dest.vec
$)

.
