//  PUK SOURCE  7.87

/**
         NT.NT1   National Contents Init Routines
         ----------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.contents

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         24.1.86  1        H.B.     Initial version
         27.5.86  2        EAJ      Fix highlight bug
         29.5.86  3        DRF      Headings commented out
         18.6.86  4        EAJ      Add video calls
         3.7.86   5        NY       Put back "BRITISH... "
         24.7.86  6        PAC      menu fix & mouse ptr fix
         *****************************
         5.6.87      7     DNH      CHANGES FOR UNI
         15.6.87     8     DNH      add g.nt.trytopage & kdhdr
         *****************************
         24.7.87     9     MH       CHANGES FOR PUK
         27.7.87    10     MH       change to G.nt.coinit for accessing
                                    last hierarchy level

         GLOBALS DEFINED:

         g.nt.conini
         g.nt.coni2
         g.nt.read.thes.recs
         g.nt.read.item.rec
         g.nt.trytopage
         g.nt.xrefs.exist
**/

section "nt1"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNThd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/nthd.h"
get "H/vhhd.h"


/**
         proc G.NT.CONINI ()
              -----------

         Sets up correct screen colour and reads first file record
         for first National Contents operation.

         GLOBALS MODIFIED:

         * g.context!m.itemselected unset: new selection to be
         made, or menu bar exit to another item selection state.

         PROGRAM DESIGN LANGUAGE:

         g.nt.conini []
            turn off pointer
            initialise various NT statics
            unset g.context!m.itemselected
            get last record selected from HIERARCHY file
            show initial contents screen
         RETURN
**/

let g.nt.conini() be
$(
   let p32 = vec 1
   let zero = vec 1

   g.sc.pointer (m.sd.off)       // avoid flicker; not enough to have this
                                 // only in g.nt.dy.init
   // set g.nt.s!m.nt.in.xref to FALSE as initially xrefs are not shown
   // set g.nt.s!m.nt.xref.page.no to 0 as initially no xrefs
   // set g.nt.s!m.nt.curr.high.no to invalid as initially nothing highlighted
   // unset itemselected: we won't necessarily leave by pending state change

   g.nt.s!m.nt.in.xref := FALSE
   g.nt.s!m.nt.xref.page.no := -1
   g.nt.s!m.nt.curr.high.no := m.sd.hinvalid
   g.context!m.itemselected := FALSE

   // read first record of hierarchy file.  This is guaranteed to be the
   // top level of the hierarchy.

   G.ut.set32(0, 0, zero)
                     //MH 27.7.87
   G.ut.mov32(G.context+m.itemh.level, p32)  //load last access to hierarchy
   g.nt.read.thes.recs (p32, g.nt.thes.data, 0, 1)

   // read descendent records and output title strings
   test G.ut.cmp32(p32, zero) = m.eq then
      g.nt.show.terms (m.nt.must.read.data)
   else
      g.nt.show.items (m.nt.must.read.data)
$)


/**
         proc G.NT.CONI2 ()
              ----------

         Initialisation routine, NOT from state tables.

         Called from action routine when Contents is entered by a
         pending state change as indicated by 'justselected'.
         This only happens when the entry is a return from an
         Item Examination State, invoked from Contents some time
         earlier.

         Contents must just redisplay the screen from which the
         item was selected.  The data for this is guaranteed to
         have been cached when Contents was last left, so it
         should not be reread.


         PDL:

         g.nt.coni2 []
            clear message area (not used by Contents)
            if in Cross References
               show current cross ref page
            else
               if at bottom level of thesaurus
                  show items for current term
               else
                  show descendent terms for current term
         RETURN
**/

and g.nt.coni2 () be
$(
   g.sc.clear (m.sd.message)

   test g.nt.s!m.nt.in.xref then
      g.nt.show.xref.page (~m.nt.must.read.data)
   else
      test g.nt.thes.data%m.nt.bottomflag = 128 then
         g.nt.show.items (~m.nt.must.read.data)
      else
         g.nt.show.terms (~m.nt.must.read.data)
$)


$<DEBUG

// collapse on fatal error: record buffers not set up properly.  Records
// must be word aligned or we can't read them efficiently, since
// g.dh.readbytes only takes a word address for the destination vector,
// without a byte offset.

let collapse (insert, duff.offset) be
$(
   g.sc.beep ()
   g.sc.mess ("Can't load %S record at byte offset %S", insert, duff.offset)
   g.ut.abort (999)     // (silly number)
$)

$>DEBUG


/**
         proc G.NT.READ.THES.RECS (p32, dest, dest.offset,
              -------------------               num.recs.to.read)

         Reads 'num.recs.to.read' contiguous thesaurus records,
         starting at the byte offset in the Hierarchy file given
         by the 32 bit value at 'p32' to the data buffer,
         starting at 'dest % dest.offset'.

         'dest.offset' must be word-aligned (ie. divisible by
         bytesperword without remainder).  The record size is
         defined by the manifest 'm.nt.thes.rec.size'.
**/

let g.nt.read.thes.recs (p32, d, doff, num.recs) be
$(
   $<DEBUG
   if doff REM bytesperword ~= 0 do
      collapse ("thesaurus", doff)
   $>DEBUG
   g.dh.read (g.nt.thes.handle, p32, d+doff/bytesperword,
                                          num.recs * m.nt.thes.rec.size)
$)


/**
         proc G.NT.READ.ITEM.REC (rec.num32, dest, dest.offset)
              ------------------

         Reads one item names file record, given by its record
         number 'rec.num32' to a data buffer specified by 'dest %
         dest.offset'.

         'dest.offset' must be word-aligned.  The record size is
         defined byt the manifest 'm.nt.item.rec.size'.
**/

let g.nt.read.item.rec (recno32, d, doff) be
$(
   let t32 = vec 1         // item record size, then file pointer

   $<DEBUG
   if doff REM bytesperword ~= 0 do
      collapse ("item", doff)
   $>DEBUG

//   g.ut.set32 (m.nt.NAMES.rec.size, 0, t32)
//   g.ut.mul32 (recno32, t32)       // record number -> byte offset
   g.dh.read.names.rec (g.nt.names.handle, recno32, d+doff/bytesperword, 
                                                           m.nt.NAMES.rec.size)
$)


/**
         proc G.NT.TRYTOPAGE ()
              --------------

         Page forwards or backwards in xref.  Paging can be in
         the cross references themselves or back further than the
         first page of them onto the 'real' items page for the
         current thesaurus term.

         g.nt.s!m.nt.xref.page.no is modified.

         Calls the usual routines to show a page.
**/


let g.nt.trytopage() be
$(
   let page.no = g.nt.s!m.nt.xref.page.no    // (useful)

   test g.nt.s!m.nt.in.xref then       // (can only page in Xref)
   $(
      test g.key = m.kd.fkey7 then
      $(                            // Previous: page back in Xrefs
         test page.no = 1 then      // back to bottom level items
            g.nt.show.items (m.nt.must.read.data)
         else
         $(                      // back to previous Xref page
            g.nt.s!m.nt.xref.page.no := g.nt.s!m.nt.xref.page.no - 1
            g.nt.show.xref.page (m.nt.must.read.data)
         $)
      $)
      else        // fkey8 = Next: page forward in Xrefs
      $(
         let first.on.next.page = page.no * m.nt.max.items

         test first.on.next.page >= g.nt.s!m.nt.num.xrefs then
            g.sc.beep ()
         else
         $(                      // on to next Xref page
            g.nt.s!m.nt.xref.page.no := g.nt.s!m.nt.xref.page.no + 1
            g.nt.show.xref.page (m.nt.must.read.data)
         $)
      $)
   $)
   else
      g.sc.beep()
$)


/**
         function G.NT.XREFS.EXIST ()
                  ----------------
         Returns a boolean according to existence of cross
         references for this page of items.  These exist if and
         only if the 32bit xref pointer in the current thesaurus
         record is non-zero.
**/

let g.nt.xrefs.exist () = valof
$(
   for j = 0 to 3 do
      if g.nt.thes.data%(m.nt.xref+j) ~= #X00  RESULTIS TRUE
   RESULTIS FALSE
$)
.
