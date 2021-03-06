//  UNI SOURCE  4.87

/**
         CTEXT3 - third part of community text code
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.phtx

         GLOBALS DEFINED:

         G.ct.display.text.page

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         14.10.86   12     PAC      Initial blank line in Print
         21.10.86   13     PAC      Fix leading zeroes AA text
         ******************************
         8.5.87      14    DNH      CHANGES FOR UNI
         12.5.87     15    DNH      debug stuff
         13.5.87     16    DNH      move out main page stuff
         31.7.87     17    PAC      fix print bug
         18.8.87     18    DNH      Fix last page title bug
**/

SECTION "ctext3"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/uthd.h"
get "H/cphd.h"

/**
         G.CT.DISPLAY.TEXT.PAGE - routine to output textpage to screen,
         ----------------------   printer or floppy

         INPUTS:

         Type of output - screen, printer or floppy

         PROGRAM DESIGN LANGUAGE:

            IF type = print THEN newline
            output schools page header
            output schools text page
            update menubar
            RETURN
**/

Let g.ct.display.text.page (type) be
$(
   let result = TRUE          // internal status

   g.sc.pointer(m.sd.off)

   if type = m.cp.print do
      result := g.ut.print( TABLE 0 )  // newline

   // show the header in the message area
   if result do
      result := show.title.head (type)

   if result do
      result := g.ct.display.text.body (type)

   // boring menu bar stuff
   test g.cp.context!m.cp.picoff = 0 do
      g.cp.context!m.cp.box4 := m.wBlank
   else
      g.cp.context!m.cp.box4 := m.wPhoto
   g.cp.context!m.cp.box5 := m.wIndex        // always a schools text index

   g.sc.pointer(m.sd.on)
$)


/**
         function show.title.head (type)
                  ---------------
         Show the title for this text page - screen, print or
         write.  First it has to find the title in the 'index'
         region of the context area, then output it.  If there is
         no specified title for this page then the PREVIOUS title
         is used.
         Returns a boolean according to success.

         PDL
            find most appropriate title
            update itemrecord with this title
            construct header
            output header to type device specified
            RETURN
**/

And show.title.head(type) = VALOF
$(
   let number = ?                      // page number variable
   let buff = vec 44/BYTESPERWORD      // buffer for print/write
   let result = ?                      // boolean return status

   let s = g.cp.context + m.cp.index            // titles buffer start
   let soff = ?                                 // byte offset to title
   let numtitles = g.cp.context!m.cp.numtitles  // total number
   let page = g.context!m.page.no               // current page
   let this.title = g.context + m.itemrecord    // where to put it

   // First find the most appropriate title: the title for this page
   // or, if there isn't one for this page, the title for the nearest
   // lower page that has a title.

   let t = 2            // SECOND title
   let gotpage = FALSE

   while t <= numtitles & ~gotpage do
   $(
      number := (g.cp.context+m.cp.numbers)!t

      test number = page then       // unambiguously the correct title
         gotpage := TRUE
      else
         test number < page then    // we might have to use this
            test t < numtitles then
               t := t+1             // try the next one
            else
               gotpage := TRUE      // yes, we must use it: no more to try
         else                       //  number > page:  overshot
            $(
               t := t-1             // overshot: use previous
               gotpage := TRUE
            $)
   $)

   test gotpage then                // set offset into titles
      soff := (t-1) * m.cp.index.entry.size
   else
      soff := 0                     // special case: only one title - use it


   // update itemrecord in G.context with the title of this page
   // This is used again below because it is nicely word aligned.

   this.title%0 := 28    // set length byte
   G.ut.movebytes (s, soff+4, this.title, 1, 28)   // ignore leading spaces
                                                   // stored in index region

   // Finally output the title to the requested device

   test (type = m.cp.screen) then
   $(
      g.ct.draw.blue.bar()

      // output title and page number
      g.sc.selcol (m.sd.yellow)
      g.sc.movea (m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
      g.sc.oprop (this.title)     // use the short version
      g.sc.movea (m.sd.message,m.sd.mesXtex+m.sd.mesw-m.sd.charwidth*8,
                                                               m.sd.mesYtex)
      g.sc.selcol (m.sd.cyan)
      g.sc.ofstr ("Page %n", page)
      result := TRUE                // all ok
   $)
   else
   $(
      buff%0 := m.cp.header
      g.ut.movebytes (this.title, 1, buff, 1, 28)
      g.ut.movebytes ("*S*S*S*SPage*S", 1, buff, 29, 9)
      $(
         let num = vec 6/BYTESPERWORD
         g.vh.word.asc (page, num)                    // page in range 1-99
         buff%38 := (num%4) = '0' -> '*S', num%4      // ' 1', not '01'
         buff%39 := num%5
      $)
      test (type = m.cp.print) then
         result := g.ut.print(buff)
      else
         result := ( g.ut.write (buff*BYTESPERWORD+1, buff%0, m.ut.text) =
                                                                m.ut.success )
   $)
   resultis result
$)
.
