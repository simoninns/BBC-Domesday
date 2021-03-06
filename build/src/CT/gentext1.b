//  AES SOURCE  4.87

/**
         GENTEXT1 - community text Utilities
         -----------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         *********************************
         12.5.87      1    DNH      CREATED FOR UNI
         18.5.87      2    DNH      write stuff to gentext2
                                    this file now gentext1
          2.6.87      3    PAC      Modify diagnostics

         GLOBALS DEFINED:

         g.ct.display.text.body
         g.ct.2oplist
**/

SECTION "gentext1"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/uthd.h"
get "H/cphd.h"


/**
         function g.ct.display.text.body (output.type)
                  ----------------------

         Returns boolean success status.

         Does the main work in output of the body of a text page,
         Schools or AA, to Screen, Printer or Floppy according to
         the output.type parameter specified.

         Relies on various statics having been set up by earlier
         routines, particularly m.cp.first.page.offset used by
         'organise.frames' which works out which frames are needed
         for a given page and loads them.  This is the offset
         from the start of the essay frame to the first byte of
         the first page of the essay.  Due to the data structure
         definition this is always within the first frame.
**/

let g.ct.display.text.body (type) = valof
$(
   let propspaced = ?         // boolean true if PS
   let sort = ?               // opcode for g.sc.opage
   let result = TRUE          // internal status
   let first.char = ?         // first char of page: for PS test
   let first.buff = ?         // first buffer variable
   let second.buff = ?        // second buffer variable

   // arrange that correct data frames are in buffers ready for page output

   first.buff := organise.frames ()
   second.buff := (first.buff = g.cp.buffA) -> g.cp.buffB, g.cp.buffA

   // set proportionally spaced flag according to top bit of 1st byte of page
   first.char := first.buff % (g.cp.context!m.cp.page.start.offset)
   propspaced := (first.char & #X80) = 0        // (bit set => tabular)
   first.buff % (g.cp.context!m.cp.page.start.offset) := first.char & #X7F
                                                               // mask top bit
   // set up according to the type of opage we will use
   switchon type into
   $(
      case m.cp.screen:
         g.sc.clear(m.sd.display)
         g.sc.movea(m.sd.display,m.sd.disXtex,m.sd.disYtex-m.sd.linw)
         sort := m.sd.screen.page
         endcase

      case m.cp.print:
         sort := m.sd.print.page
         endcase

      case m.cp.write:
         sort := m.sd.write.page
         endcase
   $)

   $<DEBUG
   if g.ut.diag () do
   $(
      let op = output ()
      let pr = findoutput ("PRINTER:")
      selectoutput (pr)
      newline ()
      writef ("itemaddress=%N*N", g.context!m.itemaddress)
      writef ("page=%N*N",        g.context!m.page.no)
      writef ("nopages=%N*N", g.cp.context!m.cp.nopages)
      writef ("numtitles=%N*N", g.cp.context!m.cp.numtitles)
      writef ("first.page.offset=%N*N", g.cp.context!m.cp.first.page.offset)
      writef ("frameA=%N*N", g.cp.context!m.cp.frameA)
      writef ("frameB=%N*N", g.cp.context!m.cp.frameB)
      writef ("buffA=%N*N", g.cp.buffA)
      writef ("buffB=%N*N", g.cp.buffB)
      writef ("first.buff=%N*N", first.buff)
      writef ("second.buff=%N*N", second.buff)
      writef ("1st.off=%N*N", g.cp.context!m.cp.page.start.offset)
      writef ("2nd.off=%N*N", g.cp.context!m.cp.page.cont.offset)
      writef ("1st.char=%C*N", first.char & #X7F)
      writef ("PS=%S*N", propspaced -> "true", "false")
      writef ("pagebuff=%N*N", g.cp.context!m.cp.pagebuff)
      endwrite ()
      selectoutput (op)
   $)
   $>DEBUG

   g.sc.opage (first.buff,
               second.buff,
               m.cp.framesize,
               m.cp.framesize,
               g.cp.context!m.cp.page.start.offset,
               g.cp.context!m.cp.page.cont.offset,
               propspaced,
               sort,
               G.cp.context!m.cp.pagebuff)

   // restore top bit of page setting
   first.buff % (g.cp.context!m.cp.page.start.offset) := first.char

   RESULTIS result
$)


/**
         function organise.frames ()
                  ---------------

         Returns the address of the first frame buffer - either
         g.cp.buffA or g.cp.buffB - in which the page of text
         specified by g.context!m.page.no starts.

         This sets up CT's internal buffers so as to facilitate
         calling 'g.sc.opage' which does the actual output.

         If the page fits into the first frame buffer without
         spilling across a continuation (cont) frame then the
         static which indicates the frame number of the cont
         frame is set to m.sd.invalid.

         Use of the buffers is optimised so that if one the
         frames required is already in the buffer it is not
         reread.  'g.dh.readframes' is used.

         GLOBALS REQUIRED
         g.context!m.page.no must be the required page.
         g.context!m.itemaddress must be for this essay.

         STATICS MODIFIED

         The following 2 are updated if the frame numbers in
         them have changed:
         g.cp.context!m.cp.frameA
         g.cp.context!m.cp.frameB

         The following 2 are set up with the offsets to the start
         of the text within their respective frames.
         page.start.offset may be from 0 to m.cp.frame.size;
         page.cont.offset will be zero if the page overruns into
         the cont frame, m.sd.invalid otherwise:
         g.cp.context!m.cp.page.start.offset
         g.cp.context!m.cp.page.cont.offset
**/

and organise.frames () = valof
$(
   let page = g.context!m.page.no         // (constant in this routine)

   let frameA = g.cp.context!m.cp.frameA  // frame number of frame in buffA
   let frameB = g.cp.context!m.cp.frameB

   let start.frame = ?           // number of frame in which text page starts
   let start.offset = vec 1      // byte offset into start.frame

   let cont.frame = ?            // continuation frame
   let fpo = g.cp.context!m.cp.first.page.offset  // 1st byte of 1st text page
   let itemaddress = g.context!m.itemaddress    // start frame of whole essay
   let junk = vec 1

   start.frame := frame.for.page (page, itemaddress, fpo, start.offset)
   cont.frame  := frame.for.page (page+1, itemaddress, fpo, junk)


   // now read the frame(s) if not already read, in the optimal way

   if start.frame ~= frameA &
      start.frame ~= frameB do      // read it
      test frameA = cont.frame | frameB = m.sd.invalid then
      $( g.dh.readframes (start.frame, g.cp.buffB, 1)
         frameB := start.frame
      $)
      else
      $( g.dh.readframes (start.frame, g.cp.buffA, 1)
         frameA := start.frame
      $)

   if cont.frame ~= frameA &
      cont.frame ~= frameB do      // read it
      test frameA = start.frame | frameB = m.sd.invalid then
      $( g.dh.readframes (cont.frame, g.cp.buffB, 1)
         frameB := cont.frame
      $)
      else
      $( g.dh.readframes (cont.frame, g.cp.buffA, 1)
         frameA := cont.frame
      $)

   g.cp.context!m.cp.frameA := frameA     // restore statics
   g.cp.context!m.cp.frameB := frameB

   g.cp.context!m.cp.page.start.offset := g.ut.get32 (start.offset, junk)
   g.cp.context!m.cp.page.cont.offset := (start.frame = cont.frame) ->
                                                            m.sd.invalid, 0
   resultis (start.frame = frameA) -> g.cp.buffA, g.cp.buffB
$)


/**
         function frame.for.page (page, itemaddress,
                  --------------    first.page.offset,
                                       32bit start offset)

         Returns the logical frame number in which to find the
         start of the specified page, given the itemaddress at
         which the whole essay starts.

         page (current page), itemaddress and first.page.offset
         are input parameters.

         The 32bit start offset is an output vector for the
         return of the 32 bit byte offset into the first frame.

         No global variables are required or modified.

         ALGORITHM IS:

         bytes.in.buff.to.page := (page-1)*bytes.per.page +
                                                first.page.offset
         start.offset := bytes.in.buff.to.page REM
                                                bytes.per.frame
         frame := bytes.in.buff.to.page / bytes.per.frame
         resultis frame + itemaddress
**/

and frame.for.page (page, itemaddress, first.page.offset, start.offset32) = valof
$(
   let bibtp32 = vec 1
   let bytes.per.page32 = vec 1
   let bytes.per.frame32 = vec 1
   let first.page.offset32 = vec 1
   let junk = ?

   g.ut.set32 (first.page.offset, 0, first.page.offset32)
   g.ut.set32 (m.cp.pagesize, 0, bytes.per.page32)
   g.ut.set32 (m.cp.framesize, 0, bytes.per.frame32)
   g.ut.set32 (page-1, 0, bibtp32)

   g.ut.mul32 (bytes.per.page32, bibtp32)
   g.ut.add32 (first.page.offset32, bibtp32)
   g.ut.div32 (bytes.per.frame32, bibtp32, start.offset32)
   RESULTIS g.ut.get32 (bibtp32, @junk) + itemaddress    // return the frame
$)


/**
         G.CT.2OPLIST - routine to print or write titles
         ------------

         INPUTS:
         type - print or write
         itemno - number to be displayed
         textptr - address of string to be displayed

         OUTPUTS:
         none

         PROGRAM DESIGN LANGUAGE:
         IF itemno too large
         THEN truncate
         ENDIF
         check characters to be output
         IF itemno = seenumber
         THEN
            put "see: " into buffer string
            set length byte
         ELSE
            convert to 6 digit string
            replace leading zeros with spaces
            move leftwards in buffer one place
            set length byte
         ENDIF
         copy title into text buffer
         IF type = print
         THEN print line
         ELSE write line
         ENDIF
**/

And g.ct.2oplist (itemno, textptr, type) = VALOF
$(
   LET result = ?
   LET buff = vec 40/BYTESPERWORD

// DATA SHOULD ALL BE GOOD NOW.  LEAVE THIS OUT.
//   FOR i = 1 TO textptr%0 DO          // check each char in list text
//      UNLESS G.ut.printingchar (textptr%i) | textptr%i = 0 DO
//         textptr%i := '#'                    // default character

   TEST itemno = m.sd.seenumber THEN      // "See: " at start of line
      g.ut.movebytes ("See: ", 1, buff, 1, 5)
   ELSE                                   // item number at start of line
   $(
      g.vh.word.asc (itemno, buff)  // convert item number to string
      for j = 2 to 4 do             // pad leading zeros of 4 chars to spaces
         buff%j := (buff%j = '0') -> '*S', buff%j
      g.ut.movebytes (buff, 2, buff, 1, 4)      // move back one
      buff%5 := ' '
   $)

   buff%0 := 5 + textptr%0
   G.ut.movebytes (textptr, 1, buff, 6, textptr%0)      // copy text

   TEST type = m.cp.print THEN
      result := g.ut.print(buff)
   ELSE
      result := ( g.ut.write (buff*BYTESPERWORD+1, buff%0, m.ut.text) =
                                                               m.ut.success )
   RESULTIS result
$)
.
