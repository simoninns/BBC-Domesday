//  AES SOURCE  4.87

/**
         AATEXT1 - community AA text
         ---------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         22.9.86     11    PAC      Add defences for PICS no TEXT
                                    data bundles - GOTO map.
         25.9.86     12    PAC      Fix AA contents bug.
         *********************************
         12.5.87     13    DNH      CHANGES FOR UNI
         19.5.87     14    DNH      kill off find.AA.contents ()
                                    create init.menu ()
          2.6.87     15    PAC      Modify diagnostics
**/

SECTION "aatext1"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/vhhd.h"
get "H/cphd.h"


/**
         G.CT.AA.TEXINI - Initialization routine
         ---------------------------------------

         INPUTS:
         None

         OUTPUTS:
         None

         GLOBALS MODIFIED:
         g.context!m.page.no :
**/

Let g.ct.AA.texini() be
$(
   g.vh.video(m.vh.micro.only)
   G.sc.setfont( m.sd.normal )      // set up AA text (normal) font

   G.cp.find.data ()                // find first frame (itemaddress) of essay
   init.AA.priv.buffer ()           // text statics from the first frame

   // Init article title and section titles in index region of context
   // Set up contents.exist flag according to existence of section titles

   g.cp.context!m.cp.contents.exist := init.AA.contents ()

   test g.cp.context!m.cp.contents.exist then
      g.ct.display.AA.contents (m.cp.screen)
   else
   $(
      g.context!m.page.no := 1
      g.ct.display.AA.text.page (m.cp.screen)
   $)

   init.menu ()         // set up menu bar
$)


/**
         init.AA.priv.buffer - Initialises the private buffer
         -------------------

         Initialises the CT statics in G.cp.context according to
         data found in G.cp.buffA.  See Videodisc Structures
         Spec.
         Sets g.context!m.page.no to 0.
**/

And init.AA.priv.buffer() be
$(
   G.cp.context!m.cp.level   := G.cp.buffA%0
   G.cp.context!m.cp.type    := G.cp.buffA%1
   g.cp.context!m.cp.textoff := m.cp.AA.textoff     // 228
   g.cp.context!m.cp.nopages := G.ut.unpack16 (g.cp.buffA, m.cp.AA.textoff)
   g.cp.context!m.cp.first.page.offset := m.cp.AA.textoff +
            m.cp.sizepageno + (1+g.cp.context!m.cp.nopages)*m.cp.titlelen
   g.context!m.page.no := 0      // Index page by default; may
                                 // become page 1 later
$)


/**
         function init.AA.contents ()
                  ----------------

         Sets up itemrecord with title of whole article and sets
         up section titles if these exist.  Returns true if there
         are any section titles (and hence Index page) exist,
         false otherwise.

         Only call this when the first frame of the essay is in
         buffA - ie. just after g.cp.find.data has been called
         for the first time.
**/

and init.AA.contents () = valof
$(
   let s = g.cp.buffA
   let soff = g.cp.context!m.cp.textoff + m.cp.sizepageno
                     // soff now points to whole article title
   let d = g.cp.context + m.cp.index      // destination vector
   let doff = 0
   let title = 0                          // no section titles found so far
   let extra.title = "Introduction"
   let p = g.cp.context + m.cp.numbers    // page numbers vector start addr

   // the title of the whole article is stored in the
   // itemrecord region of g.context.  It always exists.

   (g.context + m.itemrecord)%0 := 30       // length byte
   g.ut.movebytes (s, soff, g.context + m.itemrecord, 1, 30)

   d%doff := '*S'          // initialise to all spaces
   g.ut.movebytes (d, 0, d, 1, m.cp.max.titles*m.cp.index.entry.size - 1)

   // now copy the section titles which make up the contents page

   soff := soff + m.cp.titlelen  // get to first section title

   for page = 1 to g.cp.context!m.cp.nopages do
   $(
      unless s%soff = 0 do
      $(
         if title = 0 then       // none found so far: it's the first one
            unless (s%soff = '0' | s%soff = '*S') & s%(soff+1) = '1' do
            $(       // fake up an Introduction entry if 1st isn't for page 1
               d%doff := 34            // set length byte
               g.ut.movebytes (extra.title, 1, d, doff+3, extra.title%0)
               d%(doff+34) := '1'      // fake a page number

               title := title + 1      // title to 1
               p!title := 1            // page number for this section
               doff := doff + m.cp.index.entry.size
            $)

         // copy title and page number digits
         d%doff := 34            // set length byte
         g.ut.movebytes (s, soff+2, d, doff+3, 28)
         unless s%soff = '0' do        // leading space, not leading zero
            d%(doff+33) := s%soff
         d%(doff+34) := s%(soff+1)

         // increment variables and set page number in numbers vec
         title := title + 1
         p!title := page               // page number for this section
         doff := doff + m.cp.index.entry.size
      $)

      soff := soff + m.cp.titlelen     // next title to unpack
      if title = m.cp.max.titles BREAK          // defensive programming
   $)

   g.cp.context!m.cp.numtitles := title         // set static
   RESULTIS (title ~= 0)            // true if at least one section title exists
$)


/**
         G.CT.AA.UNOPTINI - Initialisation routine from options
         ------------------------------------------------------

         Initialise menubar
         RETURN
**/

And g.ct.AA.unoptini() be init.menu ()    // that's all!!


/**
         proc init.menu ()
              ---------

         set menu bar to all active
         set Photo box to blank
         IF at index page OR index page doesn't exist
            set Index box to blank
**/

and init.menu () be
$(
   // set up the menu bar to all active
   G.cp.context!m.cp.box1 := m.sd.act
   MOVE (G.cp.context+m.cp.box1, G.cp.context+m.cp.box1+1, m.cp.box6-m.cp.box1)

   // no Photo from AA text
   g.cp.context!m.cp.box4 := m.wBlank

   // blank Index if at it or it doesn't exist
   if g.context!m.page.no = 0 | ~g.cp.context!m.cp.contents.exist do
      g.cp.context!m.cp.box5 := m.wBlank
$)


/**
         G.CT.AA.TEXT - Specific action routine for text overlay
         ----------------------------------------------------

         INPUTS : None

         OUTPUTS : None

         GLOBALS MODIFIED : g.context!m.page.no modified by paging
                                              and display routines

         SPECIAL CALLS TO USER : None

**/

And g.ct.AA.text() be
$(
   let local.key = g.key
   let firstitem = 1
   let lastitem = ?
   let itemno = ?

   if g.context!m.justselected do
   $(
      g.ct.AA.texini()
      g.context!m.justselected := FALSE
   $)

   if local.key = m.kd.change & g.screen = m.sd.display do
      local.key := g.cp.interpret.tab (local.key)     // convert tab to f7/f8

   // highlighting of section numbers
   if g.context!m.page.no = 0 do
   $(
      lastitem := g.cp.context!m.cp.numtitles
      itemno := g.sc.high (firstitem, lastitem, FALSE, 1)
   $)

   SWITCHON local.key INTO
   $(
      case m.kd.Fkey2:              // Options: unhighlight
         if g.context!m.page.no = 0 do
         $(
            let temp = g.screen
            g.screen := m.sd.message
            g.sc.high (firstitem, lastitem, FALSE, 1)
            g.screen := temp
         $)
         endcase

//      case m.kd.Fkey3:        // let Map pass; cannot update details

      case m.kd.Fkey5:
         g.ct.display.AA.contents (m.cp.screen)
         endcase

      case m.kd.Fkey7:
         test g.ct.try.to.page (m.cp.back) then
            test g.context!m.page.no = 0 then
               g.ct.display.AA.contents (m.cp.screen)
            else
               g.ct.display.AA.text.page (m.cp.screen)
         else
            g.sc.beep ()
         endcase

      case m.kd.Fkey8:
         test g.ct.try.to.page (m.cp.forwards) then
            g.ct.display.AA.text.page (m.cp.screen)
         else
            g.sc.beep ()
         endcase

      case m.kd.return:
         if itemno ~= m.sd.hinvalid & g.context!m.page.no = 0 do
         $(       // selecting a page from Index: page number is in the vector
            g.context!m.page.no := (g.cp.context+m.cp.numbers)!itemno
            g.ct.display.AA.text.page(m.cp.screen)
         $)
         endcase

      $<DEBUG

      CASE 'D': CASE 'd':     // DEBUG STUFF to printer
      if g.ut.diag () do
      $(
         let op = output ()
         let pr = findoutput ("PRINTER:")
         selectoutput (pr)
         writef ("page.no=%N*N", g.context!m.page.no)
         writef ("numtitles=%N*N", g.cp.context!m.cp.numtitles)
         writef ("title and number:*N")
         for j = 1 to g.cp.context!m.cp.numtitles do
         $( writes (g.cp.context + m.cp.index +
                                 (j-1)*m.cp.index.entry.size/BYTESPERWORD)
            writef ("*S*S*S%N*N", (g.cp.context + m.cp.numbers)!j)
         $)
         endwrite ()
         selectoutput (op)
      $)
      endcase

      $>DEBUG

   $)             // (end of switchon

   if g.redraw | G.cp.check.menu (g.cp.context + m.cp.box1) do
      g.sc.menu (g.cp.context+m.cp.box1)
$)
.
