//  AES SOURCE  4.87

/**
         AATEXT2 - Display AA Contents Page
         ----------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         02/04/86    1     EAJ         Initial version
         27/05/86    2     EAJ         Fix printwrite bug
          15.9.86    3     PAC         Fix number of titles
         13.10.86    4     PAC         Update itemrecord for Help
         14.10.86    5     PAC         Initial blank line in Print
         *******************************
         12.5.87     6     DNH         CHANGES FOR UNI
                                       created from 4cttext
**/

SECTION "aatext2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/uthd.h"
get "H/cphd.h"


/**
         G.CT.DISPLAY.AA.CONTENTS
         ------------------------
         routine to output contents page to screen, printer or
         floppy

         INPUTS:

         type : screen, printer or floppy

         GLOBALS MODIFIED:

         SPECIAL NOTES FOR CALLERS:

         Should only be called when the 'index' buffer of section
         titles has been initialised.

         PROGRAM DESIGN LANGUAGE:
**/

let g.ct.display.AA.contents(type) be
$(
   let result = TRUE
   let s = g.cp.context+m.cp.index     // start of section titles

   g.sc.pointer(m.sd.off)
   g.sc.high(0,0,false,100)

   g.context!m.page.no := 0

   // set up screen and write essay title in menu bar
   // essay title is in the itemrecord in g.context

   switchon type into
   $(
      case m.cp.screen:
         g.sc.clear(m.sd.display)
         g.ct.draw.blue.bar()
         g.sc.selcol(m.sd.yellow)
         g.sc.movea(m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
         g.sc.oprop(g.context+m.itemrecord)
         g.sc.movea(m.sd.display,m.sd.disXtex,m.sd.disYtex-m.sd.linw)
         g.sc.selcol(m.sd.cyan)
         endcase

      case m.cp.print:
         result := g.ut.print( TABLE 0 )   // initial blank line
         if result then result := g.ut.print (g.context+m.itemrecord)
         if result then result := g.ut.print (TABLE 0)
         endcase

      case m.cp.write:
         result := g.ut.write ( (g.context+m.itemrecord)*BYTESPERWORD+1,
                                      (g.context+m.itemrecord)%0, m.ut.text)
         result := (result = m.ut.success)
         endcase
   $)

   // output the section titles with sequential section numbers as list items

   for title = 1 to g.cp.context!m.cp.numtitles do
   $(
      test type = m.cp.screen then
         g.sc.oplist (title, s)
      else
         if result do
            result := g.ct.2oplist (title, s, type)
      s := s + (m.cp.index.entry.size/BYTESPERWORD)
   $)

   g.cp.context!m.cp.box5 := m.wBlank     // no Index: we're at it
   g.sc.pointer(m.sd.on)
$)
.
