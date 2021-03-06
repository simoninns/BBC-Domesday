//  AES SOURCE  4.87

/**
         CTEXT4 - COMMUNITY TEXT OPTIONS
         -------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         24.07.86  5       PAC         Leave out 'Contents' error message
         26.9.86   6       PAC         Add kbd flush after Write
         *******************************
         11.5.87   7       DNH      CHANGES FOR UNI
**/

SECTION "ctext4"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/kdhd.h"
get "H/uthd.h"
get "H/cphd.h"


/**
         G.CT.OTINI - initialization routine for entering textoptions
         ------------------------------------------------------------

         PROGRAM DESIGN LANGUAGE:

         Initialize menubar held in private data buffer
         RETURN
**/

Let g.ct.otini() be
$(
   g.cp.context!m.cp.write.pending := FALSE
   init.menu()
$)


And init.menu() be
$(
   let page = g.context!m.page.no

   g.cp.context!m.cp.box1 := m.sd.act
   MOVE (g.cp.context+m.cp.box1, g.cp.context+m.cp.box1+1, m.cp.box6-m.cp.box1)

   if page = 0 do                         // blank First
      g.cp.context!m.cp.box3 := m.wBlank
                                          // blank End
   if page = g.cp.context!m.cp.nopages do
      g.cp.context!m.cp.box4 := m.wBlank
$)


/**
         G.CT.TEXOPT - Specific action routine for text options
         -----------

         GLOBALS MODIFIED:
         G.context!m.page.no modified when FIRST and END calls made


         PROGRAM DESIGN LANGUAGE:

         IF reply to write question <> 'r' or 'R'
         THEN
            print reply character
            restore header
         ENDIF
         update menu
         CASE of g.key

         FIRST :  g.context!m.pageno = 0
                  IF ~inschools & no contents page
                  THEN
                     display 1st AA textpage
                  ELSE
                     IF inschools
                     THEN
                        display index
                     ELSE
                        display AA contents
                     ENDIF
                  ENDIF
         ENDCASE

         END :
                  display last textpage
                  restore FIRST option on menu
                  remove END option on menu
                  ENDCASE

         PRINT :  print page displayed on screen
                  ENDCASE

         WRITE :  save header
                  show write message
                  ENDCASE

         'R' or 'r' :
                  print reply character
                  restore header
                  IF ready to write
                  THEN
                     open file
                     write text to file
                  ENDIF
                  close file
                  ENDCASE
         Action key :
                  IF on Contents page
                  THEN
                     show message
                  ENDIF
                  ENDCASE
         RETURN
**/

And g.ct.texopt() be
$(
   let local.key = g.key

   if local.key = m.kd.change & g.screen = m.sd.display do
      local.key := g.cp.interpret.tab (local.key)     // convert to f7/f8


   // if reply to write question is not an 'r' then show character reply
   // and then restore header

   if g.cp.context!m.cp.write.pending then
      g.ct.check.for.write.abort ()  // looks at g.key; may unset write pending

   switchon local.key into
   $(
      case m.kd.Fkey3 :                      // "First"
         g.ct.display.index(m.cp.screen)
         endcase

      case m.kd.Fkey4 :                      // "End"
         g.context!m.page.no := g.cp.context!m.cp.nopages
         g.ct.display.text.page(m.cp.screen)
         endcase

      case m.kd.Fkey5 :                      // "Print"
         test g.context!m.page.no > 0 then
            g.ct.display.text.page(m.cp.print)
         else
            g.ct.display.index(m.cp.print)
         endcase

      case m.kd.Fkey6 :                      // "Write"
         g.ct.prompt.for.write ()
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

      case 'R' :
      case 'r' :
         if g.cp.context!m.cp.write.pending then
            if g.ct.set.up.for.write () do
            $(
               test g.context!m.page.no = 0 then
                  g.ct.display.index(m.cp.write)
               else
                  g.ct.display.text.page(m.cp.write)
               g.ut.close.file()
            $)
         g.sc.keyboard.flush()
         endcase

      case m.kd.return :
         if g.context!m.page.no = 0 & g.screen = m.sd.display do
            g.ct.warn.user ()       // can't select in Options
         endcase
   $)

   init.menu()
   if g.redraw | g.cp.check.menu (g.cp.context+m.cp.box1) do
      g.sc.menu(g.cp.context+m.cp.box1)
$)
.
