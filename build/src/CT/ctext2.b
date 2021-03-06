//  AES SOURCE  4.87

/**
         CTEXT2 - second part of community text code
         -------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         17/04/86    1     EAJ         Initial version
         27/05/86    2     EAJ         Checks for print/write success
          25.9.86    3     PAC         Add AA titles in code
         14.10.86    4     PAC         Initial blank line in Print
         *******************************
         7.5.87      5     DNH      CHANGES FOR UNI
**/

SECTION "ctext2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/uthd.h"
get "H/dhhd.h"
get "H/grhd.h"
get "H/cphd.h"

/**
         G.CT.DISPLAY.INDEX - routine to output schools index to screen,
         ------------------   or printer or floppy

         INPUTS:

         type of output - screen, printer or floppy

         GLOBALS MODIFIED:

         G.context!m.page.no set to 0


         PROGRAM DESIGN LANGUAGE:

         G.CT.DISPLAY INDEX (type)
         ------------------------
         IF nonzero crossref & not already got AAtitle THEN
            load AA title into context vector
         ENDIF
         output header
         copy page numbers into numbers context area
         copy title from index context area into textbuffer
         IF type = screen
         THEN
            output title on screen
         ELSE
            print/write title
         ENDIF
         update menu
         RETURN
**/

Let g.ct.display.index(type) be
$(
   let result = ?                   // print/write result status
   let numbers = g.cp.context + m.cp.numbers
   let index   = g.cp.context + m.cp.index

   g.sc.pointer (m.sd.off)
   g.sc.2high (0,0,false,100,g.cp.context+m.cp.numbers) // dummy call to highlight
   g.context!m.page.no := 0

   result := output.header (type)

   if type = m.cp.screen do
   $(
      g.sc.clear(m.sd.display)
      g.sc.movea(m.sd.display,m.sd.disXtex,m.sd.disYtex-m.sd.linw)
      g.sc.selcol(m.sd.cyan)
   $)

   for title = 1 to g.cp.context!m.cp.numtitles do
   $(
         // set string.ptr to the next title in the 'index region'
      let string.ptr = index + (title-1)*m.cp.index.entry.size/BYTESPERWORD

         // output the list line to screen or floppy/printer
      test (type = m.cp.screen) then
         g.sc.oplist (numbers!title, string.ptr)
      else                 // output index line to printer/floppydisc
         if result do
            result := g.ct.2oplist (numbers!title, string.ptr, type)
   $)

   if g.cp.context!m.cp.crossref ~= 0 do
   $(
      let crossref.str = get.crossref ()  // puts AA cross ref string
                                          // in temporary txtbuff, if exists
      test type = m.cp.screen then
      $(
         g.sc.selcol (m.sd.cyan)
         g.sc.oplist (m.sd.seenumber, crossref.str)
      $)
      else                 // output index line to printer/disc
         if result do
            g.ct.2oplist (m.sd.seenumber, crossref.str, type)
   $)

   g.cp.context!m.cp.box5 := m.wBlank
   test g.cp.context!m.cp.picoff = 0 then
      g.cp.context!m.cp.box4 := m.wBlank
   else
      g.cp.context!m.cp.box4 := m.wPhoto
   g.sc.pointer(m.sd.on)
$)


and get.crossref () = valof
$(
   let s = find.AA.title ()       // returns pointer to title string
   let d = g.cp.context+m.cp.txtbuff

   for doff = 1 to 3 do
      d%doff := '*S'
   g.ut.movebytes (s, 1, d, 4, s%0)    // copy in the AA title
   d%0 := s%0 + 3
   RESULTIS d
$)


And output.header (type) = VALOF
$(
   let region = ?
   let result = ?
   let gre = g.cp.context!m.cp.grbleast
   let grn = g.cp.context!m.cp.grblnorth
   let banner = "TEXT INDEX"

   // output header in message bar, or to printer or floppy

   region := g.ut.grid.region (gre, grn)

   test type = m.cp.screen then
   $(
      unless region = m.grid.invalid do      // (shouldn't be !!!)
      $(
         g.sc.clear (m.sd.display)
         g.ct.draw.blue.bar ()
         g.sc.selcol (m.sd.yellow)
         g.sc.movea (m.sd.message,m.sd.mesXtex+m.sd.charwidth*15,m.sd.mesYtex)
         g.sc.oprop (banner)
         g.sc.selcol (m.sd.cyan)

         test g.cp.context!m.cp.level > 1 then
         $(                // show eight digit and mixed gridrefs in header
            let str = vec 10/BYTESPERWORD

            g.ut.grid.eight.digits(gre,grn,str)
            $(
               g.sc.movea(m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
               g.sc.ofstr("%S",str)
            $)

            unless region = m.grid.is.channel do // no mixed gridref for CI
            $(
               g.ut.grid.mixed (gre, grn, str)
               g.sc.movea(m.sd.message,m.sd.mesXtex+m.sd.charwidth*31,m.sd.mesYtex)
               g.sc.ofstr("%S",str)
            $)
         $)
         else                             // level 0 or 1:  show region name
         $(
            let str = find.region.name (region)
            let lenword = g.sc.width (str) + m.cp.charwidth

            g.sc.selcol (m.sd.cyan)
            g.sc.movea (m.sd.message, m.sd.mesXtex + m.sd.mesW - lenword,
                                                                  m.sd.mesYtex)
            g.sc.oprop (str)
         $)
      $)
      result := TRUE
   $)
   else
   $(                            // print or write
      let buff = vec 44/BYTESPERWORD

      buff%1 := '*S'
      g.ut.movebytes (buff, 1, buff, 2, 43)     // clear it

      g.ut.movebytes (banner, 1, buff, 15, banner%0)

      test g.cp.context!m.cp.level > 1 then
      $(                   // show eight digit and mixed gridrefs in header
         g.ut.grid.eight.digits (gre, grn, buff)
         buff%0 := 39               // correct the length byte

         unless region = m.grid.is.channel do // no mixed gridref for Channel Isles
         $(
            let str = vec 10/BYTESPERWORD
            g.ut.grid.mixed (gre, grn, str)
            g.ut.movebytes (str, 1, buff, 31, 8)
         $)
      $)
      else                 // put regional names in header
      $(
         let str = find.region.name (region)

         g.ut.movebytes (str, 1, buff, 44-str%0, str%0)
         buff%0 := 43
      $)

      test type = m.cp.print then      // print header
      $(
         result := g.ut.print( TABLE 0 )     // newline
         if result then result := g.ut.print( buff )
         if result then result := g.ut.print( TABLE 0 )
      $)
      else
      $(                               // write header to floppy
         result := g.ut.write (buff*BYTESPERWORD+1, buff%0, m.ut.text)
         result := (result = m.ut.success)
      $)
   $)
   RESULTIS result
$)


and find.region.name (region.id) = valof
$(
   test g.cp.context!m.cp.level = 0 then RESULTIS "United Kingdom"
   else                             // level1
      SWITCHON region.id INTO
      $(
         case m.grid.is.south   : RESULTIS "Southern Britain"
         case m.grid.is.north   : RESULTIS "Northern Britain"
         case m.grid.is.IOM     : RESULTIS "Isle of Man"
         case m.grid.is.shet    : RESULTIS "Orkneys/Shetlands"
         case m.grid.is.NI      : RESULTIS "Northern Ireland"
         case m.grid.is.channel : RESULTIS "Channel Isles"
         case m.grid.is.domesday.wall :
         $(
            test (g.context!m.discid = m.dh.south) then
               RESULTIS "Southern Britain"
            else
               RESULTIS "Northern Britain"
         $)
      $)
$)


/**
   find.AA.title()
   ---------------

   This horrible little bit of code avoids the need to read
   a whole frame of data in order to display the AA article
   title on a level 2 contents page.

   It also simplifies extraction of titles for the AA contents
   page itself.

   It finds the right title by using the cross reference article
   pointer (a logical frame number) to index into a lookup table
   of strings.  Returns a pointer to a word aligned string.

   The calculation is: string ptr = (Xref ptr + 12 -18700) / 22

   This relies on 4 things :

   1) logical frames are 12 less than physical frames
   2) the first AA essay starts at physical frame number 18700
   3) AA essays are 22 frames apart
   4) The order of titles shown below is the order of essays
      on the disc

**/

and find.AA.title() = valof
$(
   let pointer = (g.cp.context!m.cp.crossref + 12 - 18700) / 22
   switchon pointer into
   $(
   case  0: resultis "The Outer Hebrides"
   case  1: resultis "Cornwall and the Tamar Valley"
   case  2: resultis "S-Western Highlands & Islands"
   case  3: resultis "Skye & The Small Isles"
   case  4: resultis "The Firth of Clyde"
   case  5: resultis "The Western Highlands and Mull"
   case  6: resultis "Pembroke And Gower"
   case  7: resultis "South West Scotland & Galloway"
   case  8: resultis "Inverness & the Moray Firth"
   case  9: resultis "North-west Highlands-Scotland"
   case 10: resultis "Southwestern Borderlands"
   case 11: resultis "North Wales"
   case 12: resultis "Central Highlands of Scotland"
   case 13: resultis "Lake District & Isle of Man"
   case 14: resultis "The Lands of the Severn Sea"
   case 15: resultis "Central Wales"
   case 16: resultis "Central Lowlands of Scotland"
   case 17: resultis "Between Forth and Tay"
   case 18: resultis "Caithness and the North-East"
   case 19: resultis "Southern Uplands of Scotland"
   case 20: resultis "Eastern Scotland From Dee/Tay"
   case 21: resultis "Orkney and Shetland"
   case 22: resultis "SOUTH CENTRAL ENGLAND"
   case 23: resultis "Avon And Somerset"
   case 24: resultis "West Midlands & the Marches"
   case 25: resultis "Potteries & South Pennines"
   case 26: resultis "Northwest England"
   case 27: resultis "North Pennines & the Solway"
   case 28: resultis "Aberdeen and The North-East"
   case 29: resultis "North-Eastern England"
   case 30: resultis "Oxford & The Chilterns"
   case 31: resultis "The Cotswolds And Northampton"
   case 32: resultis "The West Riding"
   case 33: resultis "The East Midlands"
   case 34: resultis "South Downs & The Sussex Coast"
   case 35: resultis "North Downs & Weald of Kent"
   case 36: resultis "London on Thames"
   case 37: resultis "The Southern Fenland Basin"
   case 38: resultis "Lincolnshire and Humberside"
   case 39: resultis "SUFFOLK AND ESSEX"
   $)
$)
.
