//  PUK SOURCE  6.87

/**
         NM.COMPARE1 - COMPARE OPERATION FOR MAPPABLE DATA
         -------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         16.06.86 1        D.R.Freed   Initial version
         ********************************
         30.06.87 2        DNH         CHANGES FOR UNI
         11.08.87 3        SRY         Modified for DataMerge
         29.09.87 4        SRY         Changed order of menu boxes

         g.nm.compare
         g.nm.comp.to.map.ini
**/

section "nmcomp1"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/uthd.h"
get "H/iohd.h"
get "H/nmhd.h"

get "H/nmcphd.h"


/**
         G.NM.COMPARE - ACTION ROUTINE FOR COMPARE OPERATION
         ---------------------------------------------------

         Action routine for the whole compare operation; this
         is all contained within a single kernel state.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.key
         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.compare []
         ------------

         IF (g.key = Help) AND display is linked THEN
            set help visited flag
         ENDIF

         IF within a sub-operation THEN
            IF key = RETURN AND entry mode is enabled THEN
               disable entry mode
               IF item name is found in NAMES file OR
                     Bookmark name was found THEN
                  IF dataset type is mappable data THEN
                     IF sub-operation was successful THEN
                        put option back on menu bar
                     ELSE
                        restore entry mode
                     ENDIF
                  ELSE
                     output error message
                     restore entry mode
                  ENDIF
               ELSE
                  output error message
                  restore entry mode
               ENDIF
               reposition videodisc for underlay map
           ELSE IF entry mode is enabled THEN
                   add character to item name string
                   IF function key for a sub-operation THEN
                      put option back on menu bar
                      disable entry mode
                   ENDIF
                ENDIF
           ENDIF
         ENDIF
**/

let g.nm.compare () be
$(
   let itemname = g.nm.s + m.itemname
   let item.record = vec m.itemrecord.length / BYTESPERWORD
   and error.mess.ptr = ?

   if g.key = m.kd.tab g.nm.toggle.video.mode()

   if ((g.key = m.kd.fkey1) & g.nm.s!m.linked.display)
      g.nm.s!m.help.visited := TRUE

   unless g.nm.compare.sub.op = 0
      $(
         test (g.key = m.kd.return) & g.nm.s!m.nm.entry.mode then

            $( let found = false
               // disable entry mode (remove text cursor)
               g.sc.input ("", m.sd.blue, m.sd.cyan, m.namelength)
               g.nm.s!m.nm.entry.mode := FALSE
               g.key := m.kd.noact  // prevent kernel beeping

               test itemname%1 = '~'
               then if user.data(itemname, item.record)
                       found := true
               else test find.item.record (itemname, item.record, @error.mess.ptr)
                    then found := true
                    else g.sc.ermess (error.mess.ptr)

               test found
               then $( let type = item.record%m.type
                       test type = m.nm.grid.mappable.data |
                            type = m.nm.areal.mappable.data
                       then test g.nm.compare.sub.op (item.record)
                            then put.option.back ()
                            else restore.entry.mode ()
                       else $( g.sc.ermess ("Not a mappable dataset")
                               restore.entry.mode ()
                            $)
                    $)
               else restore.entry.mode ()
               g.nm.position.videodisc ()
            $)

         else if g.nm.s!m.nm.entry.mode & (g.key ~= m.kd.noact) &
                     (g.key ~= m.kd.fkey1)         // if Help leave cursor on
              $( g.sc.input (itemname, m.sd.blue, m.sd.cyan, m.namelength)
                 if m.kd.fkey4 <= g.key <= m.kd.fkey6 // was 3 to 5 SRY 29.9.87
                 $( put.option.back ()
                    g.nm.s!m.nm.entry.mode := FALSE
                 $)
              $)
      $)
$)


/**
         G.NM.COMP.TO.MAP.INI - TRANSITION FROM COMPARE UPTO TOP
         -------------------------------------------------------

         Initialisation routine for the transition from the
         compare operation up to the top level of mappable data.

         PROGRAM DESIGN LANGUAGE:

         g.nm.comp.to.map.ini []
         --------------------

         IF current display is linked THEN
            IF help has been visited THEN
               clear display area
            ENDIF
            restore screen
         ENDIF

         call g.nm.to.map to complete transition
**/

and g.nm.comp.to.map.ini () be
$(
   if g.nm.s!m.linked.display
      $(
         // if screen needs replotting, clear display area here to
         // prevent weird palette effects if key is displayed
         if g.nm.s!m.help.visited then
            g.sc.clear (m.sd.display)

         g.nm.restore.screen (g.nm.s!m.help.visited)
      $)

   // perform rest of transition initialisation
   g.nm.to.map ()
$)


/*
      put.option.back

         puts the option for the operation just completed back
         on the menu bar
*/

and put.option.back () be
$( let box = (g.nm.compare.sub.op = g.nm.link.handler) -> m.box4,
             (g.nm.compare.sub.op = g.nm.correlate.handler) -> m.box5, m.box6

   g.nm.s!(m.nm.menu + box) := m.sd.act
   g.sc.menu (g.nm.s + m.nm.menu)
$)


/*
      restore.entry.mode

         resumes entry mode by putting the text cursor back
         at the end of the string that is on display
*/

and restore.entry.mode () be
$( g.sc.input (0, m.sd.blue, m.sd.cyan, m.namelength)
   g.nm.s!m.nm.entry.mode := TRUE
$)


/*
      find.item.record

         IF the string = "BOOKMARK" THEN
            IF a bookmark has been set THEN
               make the bookmarked item name the search string
            ELSE
               returns an error message and FALSE
            ENDIF
         ENDIF

         searches for the item name string in the NAMES file;
         IF found THEN
            returns the item record and TRUE
         ELSE
            returns an error message and FALSE
         ENDIF

         the NAMES file is in alphabetical order, so a binary search
         is used for speed
*/

and find.item.record (string, item.record.ptr, error.mess.ptr) = valof
$(
   let handle, match, result = ?, ?, ?
   and length32 = vec 1
   and rec.len32 = vec 1
   and lwb32 = vec 1
   and upb32 = vec 1
   and middle32 = vec 1
   and byte.offset32 = vec 1
   and rem32 = vec 1
   and one32 = vec 1
   and two32 = vec 1

   if COMPSTRING (string, "BOOKMARK") = 0

      $(
         // use frame buffer as workspace to restore bookmarked context
         g.nm.init.frame.buffer ()
         result := g.ut.restore (g.nm.frame, m.contextsize, m.io.context.cache)

         // if restore failed, a bookmark has not been set
         // if it succeeded, extract the item name for searching
         // the NAMES file. NOTE that we cannot just pick up the
         // item address because if the Bookmark was set within Text,
         // then it will be the address of the data-associated text essay
         // and not the address of the mappable dataset

         test result
         then string := g.nm.frame + m.itemrecord
         else $( !error.mess.ptr := "BOOKMARK has not been set"
                 resultis result
              $)
      $)


   handle := g.dh.open ("NAMES")

   // record length in bytes
   g.ut.set32 (m.itemrecord.length, 0, rec.len32)

   // determine file length in records to set up bounds for log chopping
   g.dh.length (handle, length32)            // in bytes
   g.ut.div32 (rec.len32, length32, rem32)   // in records

   g.ut.set32 (1, 0, one32)
   g.ut.set32 (2, 0, two32)

   // records are from 0 --> length-1
   g.ut.sub32 (one32, length32)

   match := FALSE
   !error.mess.ptr := "Unknown data item name"

   g.ut.set32 (0, 0, lwb32)
   g.ut.mov32 (length32, upb32)

   until match | (g.ut.cmp32 (lwb32, upb32) = m.gt)

      $( // find mid-point of current bounds
         g.ut.mov32 (lwb32, middle32)
         g.ut.add32 (upb32, middle32)
         g.ut.div32 (two32, middle32, rem32) // in records
         g.ut.mov32 (middle32, byte.offset32)
         g.ut.mul32 (rec.len32, byte.offset32)

         g.dh.read (handle, byte.offset32, item.record.ptr,
                    g.ut.get32 (rec.len32, @result))

         result := COMPSTRING (string, item.record.ptr)
         match := result = 0

         unless match
            test result < 0
            then $( g.ut.sub32 (one32, middle32)
                    g.ut.mov32 (middle32, upb32)
                 $)
            else $( g.ut.add32 (one32, middle32)
                    g.ut.mov32 (middle32, lwb32)
                 $)
      $)

   g.dh.close (handle)

   resultis match
$)

and user.data(username, item.record.ptr) = valof
$( let handle = ?
   let b = ?
   let leveltype = vec 1
   let string =
      "-ADFS-*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S"
   let zero = vec 1
   G.ut.set32(0, 0, zero)
   for i = 2 to username%0 string%(i+5) := username%i
   string%0 := username%0 + 5
   handle := G.ud.open(string)
   if handle = 0 resultis false
   b := G.ud.read(handle, zero, leveltype, 2)
   G.dh.close(handle)
   if b = 0 resultis false
   item.record.ptr%m.type := leveltype%1
   g.ut.movebytes(username, 0, item.record.ptr, 0, username%0+1)
   g.ut.movebytes(zero, 0, item.record.ptr, m.address, 4)
   resultis true
$)
.


