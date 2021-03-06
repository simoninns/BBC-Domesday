//  AES SOURCE  4.87

/**
         AATEXT4 - AA Text Options
         -------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         25/06/86  4       EAJ         Alter printing character check
         24.07.86  5       PAC         Leave out 'Contents' error message
         26.9.86   6       PAC         Add kbd flush after Write
         *******************************
         11.5.87   7       DNH      CHANGES FOR UNI
**/

SECTION "aatext4"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/kdhd.h"
get "H/uthd.h"
get "H/cphd.h"


/**
         G.CT.AA.OTINI - init for entering AA textoptions
         ------------------------------------------------

         PROGRAM DESIGN LANGUAGE:

         Initialize menubar held in private data buffer
         RETURN
**/

Let g.ct.AA.otini() be
$(
   g.cp.context!m.cp.write.pending := FALSE
   init.menu()
$)


And init.menu() be
$(
   let page = g.context!m.page.no

   g.cp.context!m.cp.box1 := m.sd.act
   MOVE (g.cp.context+m.cp.box1, g.cp.context+m.cp.box1+1, m.cp.box6-m.cp.box1)

   if page = 0 | (page = 1 & ~g.cp.context!m.cp.contents.exist) do
      g.cp.context!m.cp.box3 := m.wBlank           // blank First

   if page = g.cp.context!m.cp.nopages do          // blank End
      g.cp.context!m.cp.box4 := m.wBlank
$)


/**
         G.CT.AA.TEXOPT - Specific action for AA text options
         --------------

         INPUTS:
         None

         OUTPUTS:
         None

         GLOBALS MODIFIED:
         G.context!m.page.no modified when FIRST and END calls made

**/

And g.ct.AA.texopt() be
$(
   let local.key = g.key

   if local.key = m.kd.change & g.screen = m.sd.display do
      local.key := g.cp.interpret.tab (local.key)     // convert tab to f7/f8

   // if reply to write question is not an 'r' then show character reply
   // and then restore header

   if g.cp.context!m.cp.write.pending do
      g.ct.check.for.write.abort ()   // looks at g.key; may unset writepending

   switchon local.key into
   $(
      case m.kd.Fkey3:           // First
         test g.cp.context!m.cp.contents.exist then
            g.ct.display.AA.contents (m.cp.screen)
         else
         $(
             g.context!m.page.no := 1
             g.ct.display.AA.text.page (m.cp.screen)
         $)
         endcase

      case m.kd.Fkey4 :          // End
         g.context!m.page.no := g.cp.context!m.cp.nopages
         g.ct.display.AA.text.page (m.cp.screen)
         endcase

      case m.kd.Fkey5 :          // Print
         test g.context!m.page.no > 0 then
            g.ct.display.AA.text.page (m.cp.print)
         else
            g.ct.display.AA.contents (m.cp.print)
         endcase

      case m.kd.Fkey6 :          // Write
         g.ct.prompt.for.write ()
         endcase

      case m.kd.Fkey7:           // Previous
         test g.ct.try.to.page (m.cp.back) then
            test g.context!m.page.no = 0 then
               g.ct.display.AA.contents (m.cp.screen)
            else
               g.ct.display.AA.text.page (m.cp.screen)
         else
            g.sc.beep ()
         endcase

      case m.kd.Fkey8:           // Next
         test g.ct.try.to.page (m.cp.forwards) then
            g.ct.display.AA.text.page (m.cp.screen)
         else
            g.sc.beep ()
         endcase

      case 'R' :                 // may be reply to write prompt
      case 'r' :
         if g.cp.context!m.cp.write.pending then
            if g.ct.set.up.for.write () then
            $(
               test g.context!m.page.no > 0 then
                  g.ct.display.AA.text.page (m.cp.write)
               else
                  g.ct.display.AA.contents (m.cp.write)
               g.ut.close.file()
            $)

         g.sc.keyboard.flush()
         endcase

      case m.kd.return :         // Action
         if g.context!m.page.no = 0 & g.screen = m.sd.display do
            g.ct.warn.user ()
         endcase
   $)

   init.menu()
   if g.redraw | g.cp.check.menu (g.cp.context+m.cp.box1) do
      g.sc.menu(g.cp.context+m.cp.box1)
$)
.
