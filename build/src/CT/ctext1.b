//  AES SOURCE  4.87

/**
         CTEXT1 - community schools text
         -------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         22.9.86     11    PAC      Add defences for PICS no TEXT
                                    data bundles - GOTO map.
         25.9.86     12    PAC      Fix AA contents bug.
         *********************************
         7.5.87      13    DNH      CHANGES FOR UNI
**/

SECTION "ctext1"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/sthd.h"
get "H/vhhd.h"
get "H/uthd.h"
get "H/cphd.h"


/**
         G.CT.TEXINI - Initialisation routine for entry to text
         ------------------------------------------------------
                      by menubar transition
                      ---------------------

         Sets up for Schools text (Type byte 0; Level byte 0-5)
         If the data bundle specified by the logical frame number
         at which to find the data is duff (ie. no text) then the
         'phosub' flag is borrowed to flag an abort of the Text
         operation and send the user to Map.

         PDL:
         set micro only video mode
         find the data bundle and read a frame
         **** not completed
**/

Let g.ct.texini() be
$(
   g.vh.video(m.vh.micro.only)

   G.cp.find.data ()

   // if this fails, then data bundle has no text. Go to Map

   unless init.priv.buffer() do
   $( G.cp.context!m.cp.phosub := m.cp.data.error // signal bad data
      RETURN
   $)
                            // set up for schools text
   g.sc.setfont (m.sd.schools)
   init.menu ()
   init.title.buffer()
   test g.context!m.justselected then           // PSC from Find
      g.ct.display.text.page (m.cp.screen)      //  show page specified
   else
      g.ct.display.index (m.cp.screen)          //  else show first page
$)



/**
         G.CT.UNOPTINI - Ini back from textoptions
         -----------------------------------------

         INPUTS: None

         OUTPUTS: None

         reinitialise menu bar
**/

and g.ct.unoptini() be  init.menu ()



and init.menu () be
$(
   // set up the menu bar to all active
   G.cp.context!m.cp.box1 := m.sd.act
   MOVE (G.cp.context+m.cp.box1, G.cp.context+m.cp.box1+1, m.cp.box6-m.cp.box1)

   // now start to modify various boxes
   if g.cp.context!m.cp.level = 5 do         // if at level 5, then suppress
      g.cp.context!m.cp.box6 := m.wBlank     // FIND from the menu bar

   if g.cp.context!m.cp.picoff = 0 do        // no Photo
      g.cp.context!m.cp.box4 := m.wBlank
   if g.context!m.page.no = 0 do             // at Index
      g.cp.context!m.cp.box5 := m.wBlank
$)


/**
         init.priv.buffer - Initialises the private buffer
         ----------------

         a. Unconditionally resets 'data error' flag
         b. Returns TRUE if text data is in this bundle,
            FALSE otherwise

         PROGRAM DESIGN LANGUAGE:

         Initialise general context globals
         RETURN
**/

And init.priv.buffer() = VALOF
$(
   let xrefpos = ?

   // set up the header in G.cp.context
   G.cp.context!m.cp.level     := G.cp.buffA%0
   G.cp.context!m.cp.type      := G.cp.buffA%1
   G.cp.context!m.cp.picoff    := G.ut.unpack16 (G.cp.buffA, 2)
   G.cp.context!m.cp.textoff   := G.ut.unpack16 (G.cp.buffA, 4)
   G.cp.context!m.cp.map.no    := G.ut.unpack16 (G.cp.buffA, 6)
   G.cp.context!m.cp.maprec.no := G.ut.unpack16 (G.cp.buffA, 8)
   G.cp.context!m.cp.grbleast  := G.ut.unpack16 (G.cp.buffA, 10)
   G.cp.context!m.cp.grblnorth := G.ut.unpack16 (G.cp.buffA, 12)
   G.cp.context!m.cp.nopages   := G.ut.unpack16 (G.cp.buffA,
                                                   g.cp.context!m.cp.textoff)
   xrefpos := g.cp.context!m.cp.textoff + m.cp.sizepageno +
                              g.cp.context!m.cp.nopages * m.cp.titlelen
   G.cp.context!m.cp.crossref  := G.ut.unpack16 (G.cp.buffA, xrefpos)
   G.cp.context!m.cp.first.page.offset := xrefpos + m.cp.crossrefsize

   // a title page always exists for schools
   G.cp.context!m.cp.contents.exist := TRUE

   // check that there is text here
   if g.cp.context!m.cp.textoff = 0 do
   $( G.sc.ermess("Data error: no text for this map")
      RESULTIS FALSE
   $)

   // ensure photo sub flag is initialised to anything APART from data.error
   G.cp.context!m.cp.phosub := m.cp.none

   RESULTIS TRUE
$)


/*
   init.title.buffer () initialises the title buffer with the
   titles from g.cp.buffA.  It should only be called if these
   are not all null.  Only non-null titles, of which there should
   be m.cp.max.titles or fewer, are copied.

   Two transformations are performed:

   1) The 28 title characters are moved into a true BCPL string
   with a constant length byte in front of it.  These are
   preceded by 3 spaces, making the total string length up to 31
   and the number of bytes including the length byte 32.

   2) The 2 digits for the page number for this title are
   converted from ascii to 16 bit binary and put into the
   'numbers' vector, part of g.cp.context.  This is used by
   the output routine as the list item number.
*/

And init.title.buffer() be
$(
   let title = 0
   let s = G.cp.buffA                     // source       (constant)
   let soff = g.cp.context!m.cp.textoff + m.cp.sizepageno   // source offset
   let d = g.cp.context+m.cp.index        // destination  (constant)
   let doff = 0                           // destination offset
   let p = g.cp.context+m.cp.numbers      // start of page numbers buffer

   for page = 1 to g.cp.context!m.cp.nopages do
   $(
      unless s%soff = 0 do          // only copy non-null titles
      $(
         title := title + 1
         d%doff := 31               // title string length
         for j=1 to 3 do
            d%(doff+j) := ' '       // 3 leading spaces
         g.ut.movebytes (s, soff+2, d, doff+4, 28)       // title bytes
         p!title := (s%soff-'0')*10 + s%(soff+1)-'0'     // convert page no.
         doff := doff + m.cp.index.entry.size            // next slot
      $)
      soff := soff+m.cp.titlelen    // next source title
      if title = m.cp.max.titles BREAK       // (defensive programming)
   $)
   g.cp.context!m.cp.numtitles := title
$)


/**
         G.CT.TEXT - Specific action routine for text overlay
         ----------------------------------------------------

         INPUTS : None

         OUTPUTS : None

         GLOBALS MODIFIED : g.context!m.page.no modified by paging
                                              and display routines

         SPECIAL CALLS TO USER : None

         PROGRAM DESIGN LANGUAGE:
         IF text selected from FIND (not via menubar)
         THEN
            call initialization routine
         ENDIF
         localkey := g.key
         IF (localkey = change) AND (pointer in display area)
         THEN
            IF pointer in first third of screen
            THEN
               localkey = F7
            ELSE
               IF pointer in last third of screen
               THEN
                  localkey = F8
               ENDIF
            ENDIF
         ELSE beep
         ENDIF
         IF on index or contents page
         THEN
            do highlighting
         ENDIF
         CASE of localkey
         F2 :         unhighlight ready for textoptions
                      display index
                      ENDCASE
         F7 :         trytopage
                      ENDCASE
         F8 :         trytopage
                      ENDCASE
         Action key : IF valid title selection
                      THEN
                         IF in index & 'see: ' (AA) selected
                         THEN
                            pending state change to AA text
                         ELSE
                            display selected textpage
                         ENDIF
                      ENDIF
                      ENDCASE
         IF menubar needs to be redrawn
         THEN
            redraw menu
         ENDIF
**/

let g.ct.text() be
$(
   let local.key = g.key
   let lastitem, firstitem = ?,1
   let AAtitle = ?                  // boolean
   let itemno = ?

   if g.context!m.justselected do
   $(
      g.ct.texini()                          // schools text init
      g.context!m.justselected := FALSE
   $)

   if (local.key = m.kd.change) & (g.screen = m.sd.display) do
      local.key := g.cp.interpret.tab (local.key)     // convert tab to f7/f8

   // defensive code added to check PICTURES no TEXT data
   // pinches one of PHOTO's flags to signal bad data

   if g.cp.context!m.cp.phosub = m.cp.data.error do
   $( local.key := m.kd.noact
      G.key := m.kd.Fkey3
   $)                         // scoot out to MAP

   // do the highlighting
   if g.context!m.page.no = 0 do
   $(
      lastitem := g.cp.context!m.cp.numtitles
      AAtitle := g.cp.context!m.cp.crossref ~= 0
      itemno := g.sc.2high (firstitem, lastitem, AAtitle,
                                             1, g.cp.context+m.cp.numbers)
   $)

   SWITCHON local.key INTO
   $(
      case m.kd.Fkey2:                    // Options: unhighlight item
         if g.context!m.page.no = 0 do
         $(
            let temp = g.screen
            g.screen := m.sd.message
            g.sc.2high(firstitem,lastitem,AAtitle,1,g.cp.context+m.cp.numbers)
            g.screen := temp
         $)
         endcase

      case m.kd.Fkey3:
         g.cp.init.globals ()             // for exit to Map
         endcase

      case m.kd.Fkey5:                    // Index
         g.ct.display.index(m.cp.screen)
         endcase

      case m.kd.Fkey7:                    // Previous
         test g.ct.try.to.page (m.cp.back) then
            test g.context!m.page.no = 0 then
               g.ct.display.index (m.cp.screen)
            else
               g.ct.display.text.page (m.cp.screen)
         else
            g.sc.beep ()
         endcase

      case m.kd.Fkey8:                    // Next
         test g.ct.try.to.page (m.cp.forwards) then
            g.ct.display.text.page (m.cp.screen)
         else
            g.sc.beep ()
         endcase

      case m.kd.return:                   // Action
         if g.context!m.page.no = 0 & itemno ~= m.sd.hinvalid do
         $(                      // selecting a page from Index
            test itemno = m.sd.seenumber then       // selecting AA Xref
            $(             // update itemaddress & invoke AA text
               g.sc.pointer (m.sd.off)
               g.context!m.itemaddress := g.cp.context!m.cp.crossref
               g.key := -m.st.AAtext      // PENDING STATE CHANGE
            $)
            else                    // selecting ordinary schools text page
            $(
               g.context!m.page.no := itemno
               g.ct.display.text.page(m.cp.screen)
            $)
         $)
         endcase
   $)             // (end of switchon

   if g.redraw | G.cp.check.menu(g.cp.context + m.cp.box1) do
      g.sc.menu(g.cp.context+m.cp.box1)
$)


/**
         G.CT.TRY.TO.PAGE - page through Community Text pages
         ----------------------------------------------------

         INPUTS:
         Direction : direction of paging

         OUTPUT:
         Returns a boolean, true if the page has been turned, false
         otherwise.

         GLOBALS MODIFIED:
         G.context!m.page.no incremented or decremented as appropriate
**/

let g.ct.try.to.page (direction) =
   (direction = m.cp.back) -> pagebackwards (), pageforwards ()


and pagebackwards () = valof
$(
   switchon g.context!m.page.no into
   $(
      case 0:  RESULTIS FALSE

      case 1:
         unless g.cp.context!m.cp.contents.exist   RESULTIS FALSE
   $)             // higher numbers are all OK to page back
   g.context!m.page.no := g.context!m.page.no - 1
   RESULTIS TRUE
$)


and pageforwards () = valof
$(
   if g.context!m.page.no < g.cp.context!m.cp.nopages do
   $(
      g.context!m.page.no := g.context!m.page.no + 1
      RESULTIS TRUE
   $)
   RESULTIS FALSE
$)


let g.ct.draw.blue.bar() be
$(
   g.sc.selcol(m.sd.blue)
   g.sc.movea(m.sd.message,0,0)
   g.sc.rect(m.sd.plot,m.sd.mesw-1,m.sd.mesh-1)
$)
.
