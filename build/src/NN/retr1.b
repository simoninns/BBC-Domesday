//  PUK SOURCE  6.87

/**
         NM.RETR1 - RETRIEVE SUB-OPERATION FOR MAPPABLE DATA
         ---------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmRETR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         14.04.86 1        D.R.Freed   Initial version
         ********************************
         3.7.87   2        DNH         CHANGES FOR UNI
         11.08.87 3        SRY         Modified for DataMerge
         21.08.87 4        SRY         Added toggle video mode
         27.08.87 5        SRY         Added load RANK child

         g.nm.retrieve
**/

section "nmretr1"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/kdhd.h"
get "H/nmhd.h"

get "H/nmrehd.h"


/**
         G.NM.RETRIEVE - ACTION ROUTINE FOR RETRIEVE OPERATION
         -----------------------------------------------------

         Action routine for the whole retrieve operation; this
         is handled as a local state machine and thus is all
         contained within a single kernel state.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.retrieve []
         -------------

         IF (g.key = Help) THEN
            clear screen saved flag
         ENDIF

         IF (g.key = Main) THEN
            restore screen
         ENDIF

         IF (g.key = Clear) THEN
            restore screen
            zero sum total
            initialise flashing square
         ENDIF

         CASE OF (local.state) :
            Retrieve: Retrieve handler
            Unit    : Unit handler
            GridRef : Grid ref handler
            Sum     : Sum handler
            Values  : Values handler
            Write   : Write handler
         ENDCASE
**/

let g.nm.retrieve () be
$( let menu = g.nm.s + m.nm.menu
   if g.key = m.kd.tab & g.nm.s!m.local.state ~= m.wSum
      g.nm.toggle.video.mode()

   // if Help is visited, it will write over our saved screen
   if g.key = m.kd.fkey1 then
      g.nm.s!m.saved := FALSE

   // Main - do a Clear before exiting state if screen needs restoring
   if (g.key = m.kd.fkey2) & g.nm.s!m.restore then
      g.nm.restore.screen (NOT g.nm.s!m.saved)

   if ((g.key = m.kd.fkey3) & (menu!m.box3 = m.wclear)) |
      ((g.key = m.kd.fkey5) & (menu!m.box5 = m.wclear)) then
      $(
         test g.nm.s!m.restore then
            $(
               g.nm.restore.screen (NOT g.nm.s!m.saved)
               g.nm.s!m.restore := FALSE

               // quick restore leaves menu area blank
               if g.nm.s!m.saved then
                  g.sc.menu (menu)

               // initialise flashing square to 'none'
               g.nm.s!m.flash.colour := m.nm.flash.white
            $)
         else
            g.nm.restore.message.area ()

         g.ut.set48 (0,0,0, g.nm.s + m.sum.total)
      $)

   switchon g.nm.s!m.local.state into
      $( CASE m.wretrieve:
            switchon g.key into
            $( CASE m.kd.fkey3:  // Values or Sum function
                  g.nm.s!m.local.state := menu!m.box3
                  menu!m.box3 := m.wclear
                  g.sc.menu (menu)
               ENDCASE

               CASE m.kd.fkey4: // RANK
                  g.nm.load.child("cnmRANK")
               ENDCASE

               CASE m.kd.fkey5:  // Unit or Grid Ref function
                  g.nm.s!m.local.state := menu!m.box5
                  menu!m.box5 := m.wclear
                  g.sc.menu (menu)
               ENDCASE

               CASE m.kd.fkey6:  // Write function
                  if g.nm.check.download() g.nm.to.write (m.sd.act, m.sd.act)
            $)
         ENDCASE
         CASE m.wunit:
            g.nm.unit ()
         ENDCASE
         CASE m.wgridref:
            g.nm.gridref ()
         ENDCASE
         CASE m.wsum:
            g.nm.sum ()
         ENDCASE
         CASE m.wvalues:
            g.nm.value.func ()
         ENDCASE
         CASE m.wwrite:
            g.nm.write ()
         ENDCASE

         // DEFAULT           :  g.ut.trap ("NM", 2, TRUE, 1,
         //                                  g.nm.s!m.local.state, 0,
         //                                  m.nm.max.neg.high)
      $)
$)
.
