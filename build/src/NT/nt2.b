//  PUK SOURCE  7.87

/**
         NT.NT2 - National Contents Action routine
         -----------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.contents

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
          27.1.86  1        H.B.    Initial version
          28.5.86  2        EAJ     Add nat. chart selection
          12.6.86  3        EAJ     Alter nat.essay selection
          23.6.86  4        EAJ     Change m.st.surjou to m.st.walk
          25.6.86  5        EAJ     Switch magic nos to manifests &
                                    add itemselected setting
          3.7.86   6        NY      Level 0 highlighting at line 8, not 6
          24.7.86  7        PAC     Fix mouse pointer flash
          ******************************
          5.6.87      8     DNH      CHANGES FOR UNI
          ******************************
          24.7.87     9     MH       CHANGES FOR PUK
           4.8.87    10     MH       update to G.nt.item.data

         GLOBALS DEFINED:

         g.nt.contents - state action routine
         g.nt.min
         g.nt.is.nill32
**/

section "nt2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNThd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/nthd.h"


/**
         proc G.NT.CONTENTS ()
              -------------

         National Contents Action Routine.

         Central control routine.
         Tests current action to be taken and calls relevant
         display and exit routines.

         GLOBALS MODIFIED:

         If an item at the bottom level is selected then
         the 'itemrecord' in g.context is set up.

         'g.context!m.justselected' is unset (by g.nt.coni2) if
         entry has been made by return from an Item Examination
         State.

         PROGRAM DESIGN LANGUAGE:

         G.nt.contents ()
            if no key pressed turn off pointer
            if itemselected flag set
               set up screen as last exited [g.nt.coni2]
            if g.key is change=tab
               interpret tab key to Next/Previous
            case g.key of
               'Up':
                  read 'father' term
                  show father's screen of terms
               'Cross Ref':
                  show cross ref's for this term
               anything else (default)
                  highlight according to pointer position
               'Action':
                  if something highlighted
                     if level 2 node essay highlighted
                        set up for state change to Text
                     if showing Cross Refs or Items
                        update global itemrecord
                        set up for state change to Item Type
                     else
                        move selected descendent term to top
                        if new term is bottom level
                           show items [g.nt.show.items]
                        else
                           show terms [g.nt.show.terms]
               'Previous' or 'Next':
                  try to page back or forward [g.nt.trytopage]
            end of cases
            if global or local redraw flag set
               if global redraw or menubar changed
                  redraw menubar
               reset local redraw flag
            turn on pointer
         RETURN
**/

let g.nt.content () be
$(
   unless g.key = m.kd.noact do
      g.sc.pointer( m.sd.off )

   $<DEBUG
   //  This allows Contents to act as a boot-up state.  Contents is never
   //  invoked by PSC from another Item Selection State.
   if g.context!m.justselected do
   $(
      g.nt.conini()
      g.context!m.justselected := FALSE
   $)
   $>DEBUG

   if g.context!m.itemselected do   // return from Item Examination
   $(
      g.nt.coni2 ()
      g.context!m.itemselected := FALSE
   $)

   if g.key = m.kd.change do
      g.key := interpret.tab ()

   switchon g.key into
   $(
      case m.kd.Fkey2:        // Up
         $(    // unpack father record pointer and copy to static; read record
            let p32 = vec 1

            g.ut.unpack32 (g.nt.thes.data, m.nt.father, p32)
            g.nt.read.thes.recs (p32, g.nt.thes.data, 0, 1)
            g.nt.show.terms (m.nt.must.read.data)
         $)
      endcase

      case m.kd.Fkey5:        // Xref
         g.nt.show.xrefs (m.nt.must.read.data)
      endcase

      default:                // anything else
         // a list is displayed - deal with highlighting

         // if a cross reference page is being displayed, then test for
         // partially-full page

         test g.nt.s!m.nt.in.xref then
         $(
            let first = (g.nt.s!m.nt.xref.page.no - 1)*m.nt.max.items + 1 +
                                                         g.nt.s!m.nt.num.items
            // last is the lower of the number for the bottom line of this page
            // and the highest possible xref number for this term
            let last = first + g.nt.s!m.nt.num.lines - 1

            g.nt.s!m.nt.curr.high.no := g.sc.high (first, last, FALSE, 2)
         $)
         else           // not Xref: list starting from 1
         $(
                   // (special format for level 0: start list at line 8)
            let first.line.no = g.nt.thes.data%m.nt.level = 0 -> 8, 2
            g.nt.s!m.nt.curr.high.no :=
                    g.sc.high (1, g.nt.s!m.nt.num.lines, FALSE, first.line.no)
         $)
      endcase

      case m.kd.Action:          // Action = Return
         if g.nt.s!m.nt.curr.high.no = m.sd.hinvalid do  // no highlight so...
            ENDCASE                                      // ...ignore key

         if g.nt.thes.data%m.nt.level = 2 & g.nt.s!m.nt.curr.high.no = 1 &
                              ~g.nt.is.nill32 (g.nt.thes.data, m.nt.text) do
         $(           // type 6 for Nat. Essay to show node essay
            set.PSC (6, g.nt.thes.data, m.nt.text)

            // (can't update itemrecord: node essays don't have the details)
            ENDCASE
         $)

         test g.nt.s!m.nt.in.xref | bottom.level () then
         $(
            let itemoff = ?            // byte offset to item record
            let num.items = g.nt.s!m.nt.num.items

            test g.nt.s!m.nt.in.xref then
            $(     // make pointer to item record from xref highlight
                   // NB: item records are only stored for current page
               let irec = (g.nt.s!m.nt.curr.high.no - 1 - num.items) REM
                                                               m.nt.max.items
               itemoff := irec * m.nt.NAMES.rec.size  //MH 4.8.87
            $)
            else   // make pointer to item record from item highlight
               itemoff := (g.nt.s!m.nt.curr.high.no - 1) * m.nt.NAMES.rec.size   //MH 4.8.87

            // copy the relevant item record into g.context
            // (itemaddress will be unpacked and rewritten by set.PSC)
            g.ut.movebytes (g.nt.item.data, itemoff,
                                       g.context+m.itemrecord, 0,
                                                         m.nt.NAMES.rec.size) //MH 4.8.87
            // set up for Pending State Change to item
            set.PSC (g.nt.item.data % (itemoff + m.nt.itemtype),
                                       g.nt.item.data, itemoff + m.nt.itemaddr)
         $)

         else            // selecting a hierarchy term

         $(
            let recoff = g.nt.s!m.nt.curr.high.no * m.nt.thes.rec.size

            // special case: extra node essay, so highlight is one too many
            if g.nt.thes.data%m.nt.level = 2 &
                              ~g.nt.is.nill32 (g.nt.thes.data, m.nt.text) do
               recoff := recoff - m.nt.thes.rec.size

            // move record to top of thesaurus record area
            g.ut.movebytes (g.nt.thes.data, recoff,
                                       g.nt.thes.data, 0, m.nt.thes.rec.size)

            // check whether this change has brought us to bottom level
            test bottom.level () then
               g.nt.show.items (m.nt.must.read.data)
            else
               g.nt.show.terms (m.nt.must.read.data)
         $)
      endcase

      case m.kd.fkey7:           // Previous
      case m.kd.fkey8:           // Next
         g.nt.trytopage ()
      endcase
   $)

   if g.redraw | g.nt.s!m.nt.check.menu do
   $(
      let local.redraw = config.menu (g.nt.menubar)
      if g.redraw | local.redraw do
         g.sc.menu (g.nt.menubar)
      g.nt.s!m.nt.check.menu := FALSE
   $)

   G.sc.pointer (m.sd.on)
$)


/**
         function G.NT.MIN (a, b)
                  --------

         Returns the minimum of the two parameters.
**/

and g.nt.min (a, b) = a < b -> a, b



/**
         function G.NT.IS.NILL32 (source, source.offset)
                  --------------

         Returns TRUE if the 32 bits starting at 'source %
         source.offset' are all set, FALSE otherwise.
**/

and g.nt.is.nill32 (s, soff) = valof
$(
   for j = 0 to 3
      if s%(soff+j) ~= #XFF  RESULTIS FALSE
   RESULTIS TRUE
$)


/*
         proc SET.PSC (item.type, s, soff)
              -------

         Set up for Pending State Change according to the 'type'
         of the item selected.

         Sets globals:
         * itemaddress to unpacked 32 bit value from s%soff
         * itemaddr2, itemaddr3 to nill (-1)
         * g.key to state for item.type
         * itemselected flag TRUE
*/

and set.PSC (item.type, item, itemaddr.offset) be
$(
   let state = valof SWITCHON item.type into
   $(
      case 1: case 2: case 3:
         RESULTIS m.st.datmap
      case 4:
         RESULTIS m.st.chart
      case 5:
         g.sc.ermess ("Plan operation not available")
         RESULTIS -1
      case 6: case 7:
         RESULTIS m.st.ntext
      case 8:
         g.context!m.picture.no := 1
         RESULTIS m.st.nphoto
      default:
         g.sc.ermess ("Bad itemtype: %N", item.type)
         RESULTIS -1
   $)

   unless state = -1 do
   $(
      g.ut.unpack32 (item, itemaddr.offset, g.context+m.itemaddress)
      set.nill32 (g.context+m.itemadd2)
      set.nill32 (g.context+m.itemadd3)
      g.key := -(state)                   // kick state machine
      g.context!m.itemselected := TRUE    // flag for invoked state
   $)
$)


/*
         proc SET.NILL32 (dest)
              ----------

         sets a 32 bit value at dest to
         nill (= -1)
*/

and set.nill32 (d) be
   g.ut.set32 (-1, -1, d)


/*
         function INTERPRET.TAB ()
                  -------------

         Returns a key value manifest according to the screen
         pointer position within the display area.  Interprets
         the tab key as Next, Previous or invalid.

         Assumptions:
         * value of g.key is m.kd.change (= TAB key)
         * value of g.screen is m.sd.display (ie. display area)
*/

and interpret.tab () = valof
$(
   if g.screen = m.sd.display do    // only respond if in display area
   $(
      if g.xpoint < m.sd.disW/3
         RESULTIS m.kd.fkey7        // Previous
      if g.xpoint > m.sd.disW*2/3
         RESULTIS m.kd.fkey8        // Next
      g.sc.beep ()           // must be in the 'dead' region
   $)
   RESULTIS g.key
$)


/*
         function BOTTOM.LEVEL ()
                  ------------

         Returns TRUE if the current thesaurus term is at the
         bottom level: its descendents are items, not further
         terms.  The record must have been read in to the first
         thesaurus record slot before this function is called.
*/

and bottom.level () = g.nt.thes.data%m.nt.bottomflag = 128


/*
         function CONFIG.MENU (local menubar)
                  -----------

         Returns TRUE if menu bar needs a redraw because it has
         just changed.  It configures the local menubar before
         returning.
*/

and config.menu (mb) = valof
$(
   // initialise menuboxes
   mb!m.box1 := m.sd.act
   MOVE (mb, mb + 1, m.menubarsize)

   // remove 'Up' option if at level 0
   if g.nt.thes.data%m.nt.level = 0 do
      mb!m.box2 := m.sd.wBlank

   // remove 'Xref' option if in Xrefs now or no Xrefs exist for this term
   if g.nt.s!m.nt.in.xref | ~g.nt.xrefs.exist () do
      mb!m.box5 := m.sd.wBlank

   for j = 0 to m.menubarsize do
      unless mb!j = g.menubar!j RESULTIS TRUE
   RESULTIS FALSE                   // no change
$)
.
