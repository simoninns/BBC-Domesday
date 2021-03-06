//  AES SOURCE  4.87

/**
         AATEXT3 - AA Text Page Display
         ------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         14.10.86   12     PAC      Initial blank line in Print page
         21.10.86   13     PAC      Fix leading zeroes bug AA text
         *******************************
         13.5.87     14    DNH      CHANGES FOR UNI
                                    created from 3cttext
         31.7.87     15    PAC      fix print bug
**/

SECTION "aatext3"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/uthd.h"
get "H/cphd.h"


/**
         G.CT.DISPLAY.AA.TEXT.PAGE - output AA text page to
         -------------------------
         screen, printer or floppy

         INPUTS:

         Type of output - screen, printer or floppy

         PROGRAM DESIGN LANGUAGE:
**/

Let g.ct.display.AA.text.page (type) be
$(
   let result = TRUE

   g.sc.pointer(m.sd.off)

   if type = m.cp.print do
      result := g.ut.print( TABLE 0 )     // newline

   if result do
      result := show.AA.title.head (type) // heading in message area

   if result do                           // the real text page
      result := g.ct.display.text.body (type)

   g.cp.context!m.cp.box4 := m.wBlank     // no Photo
   g.cp.context!m.cp.box5 :=              // Index
      g.cp.context!m.cp.contents.exist -> m.wIndex, m.wBlank

   g.sc.pointer (m.sd.on)
$)


and show.AA.title.head (type) = valof
$(
   let result = TRUE
   let special = (g.context!m.page.no = 1 & ~g.cp.context!m.cp.contents.exist)
   let essay.title = g.context + m.itemrecord

   test type = m.cp.screen then
   $(
      let pos = ?             // chars across message area for "Page 1..."

      g.ct.draw.blue.bar ()

      // if there is no contents page show the article title at the
      // top of page one.  This pushes the "Page 1 of..." further to
      // the right.

      test special then
      $(
         g.sc.movea (m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
         g.sc.selcol (m.sd.yellow)
         g.sc.oprop (essay.title)
         pos := 26
      $)
      else
         pos := 23

      g.sc.movea (m.sd.message, m.sd.mesXtex + m.sd.charwidth*pos,
                                                m.sd.mesYtex)
      g.sc.selcol (m.sd.cyan)
      g.sc.ofstr ("Page %n of %n", g.context!m.page.no,
                                                g.cp.context!m.cp.nopages)
   $)
   else           // Print or Write
   $(
      let buff = vec 40/BYTESPERWORD      // for "Page n of nn"
      let digits = ?       // significant digits from page number
      let doff = ?         // byte offset along buff

      if type = m.cp.print do               // newline
         result := g.ut.print( TABLE 0 )

      // if special print the essay title on banner line
      if special & result do
      $(
         test type = m.cp.print then
            result := g.ut.print (essay.title)
         else
            result := ( g.ut.write (essay.title*BYTESPERWORD + 1,
                                       essay.title%0,
                                          m.ut.text) = m.ut.success )
      $)

      // set length
      buff%0 := m.cp.header

      // clear to spaces
      buff%1 := '*S'
      g.ut.movebytes (buff, 1, buff, 2, m.cp.header-1)

      // put in "Page"
      g.ut.movebytes ("Page", 1, buff, 25, 4)
      doff := 30

      // put in the page number of this page...
      digits := fill.page.no (g.context!m.page.no, buff, doff)
      doff := doff + digits + 1

      // ...and the 'to'...
      g.ut.movebytes ("to", 1, buff, doff, 2)
      doff := doff + 3

      // ...and the number of pages
      digits := fill.page.no (g.cp.context!m.cp.nopages, buff, doff)

      if result then
         test type = m.cp.print then
            result := g.ut.print(buff)
         else
            result := ( g.ut.write (buff*BYTESPERWORD+1, buff%0,
                                                m.ut.text) = m.ut.success)
   $)
   RESULTIS result
$)


and fill.page.no (page.no, d, doff) = valof
$(
   let s = vec 6/BYTESPERWORD    // vector for ASCII page number
   let soff = 1                  // offset into s
   let significant.digits = ?    // number of digits copied

   g.vh.word.asc (page.no, s)

   // skip leading zero's, but not the last digit
   while soff < s%0 do
   $(
      if s%soff ~= '0' BREAK
      soff := soff + 1
   $)

   // copy the rest; return the number copied
   significant.digits := s%0 - soff + 1
   g.ut.movebytes (s, soff, d, doff, significant.digits)
   RESULTIS significant.digits
$)
.

